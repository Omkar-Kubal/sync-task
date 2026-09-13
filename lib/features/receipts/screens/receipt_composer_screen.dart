import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/theme/synctasks_color_scheme.dart';
import '../../../shared/icons/sync_icons.dart';
import '../../../shared/services/sync_haptics.dart';
import '../../../shared/services/sync_sounds.dart';
import '../../../shared/widgets/sync_empty_state.dart';
import '../../tasks/providers/folders_provider.dart';
import '../../tasks/providers/task_controller.dart';
import '../data/receipt_repository.dart';
import '../domain/receipt_composer_seed.dart';
import '../providers/receipt_feature_provider.dart';
import '../providers/receipt_repository_provider.dart';
import '../pro/receipt_pro_entitlement.dart';
import '../services/receipt_photo_capture_service.dart';
import '../services/receipt_photo_processor.dart';
import '../services/receipt_printing_feedback.dart';
import '../widgets/receipt_paper.dart';
import '../widgets/receipt_pro_paywall_sheet.dart';
import '../widgets/receipt_screen_chrome.dart';

class ReceiptComposerScreen extends ConsumerStatefulWidget {
  const ReceiptComposerScreen({required this.seed, super.key});

  final ReceiptComposerSeed seed;

  @override
  ConsumerState<ReceiptComposerScreen> createState() =>
      _ReceiptComposerScreenState();
}

class _ReceiptComposerScreenState extends ConsumerState<ReceiptComposerScreen> {
  late final TextEditingController _titleController;
  late final String _operationId;
  bool _includeFolderLabels = false;
  bool _isGenerating = false;
  String? _drawingStrokesJson;
  String? _photoPath;
  SavedReceipt? _printingReceipt;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.seed.defaultTitle);
    _operationId = 'op-${DateTime.now().microsecondsSinceEpoch}';
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = ref.watch(receiptFeatureEnabledProvider);
    if (!enabled) {
      return const _ReceiptUnavailableScreen();
    }
    final taskFuture = _loadSelectedTasks(widget.seed.selectedTaskIds);
    final content = Scaffold(
      backgroundColor: SyncTasksColorScheme.of(context).scaffold,
      body: SafeArea(
        child: FutureBuilder<List<Task>>(
          future: taskFuture,
          builder: (context, snapshot) {
            final tasks = snapshot.data ?? const <Task>[];
            if (_printingReceipt != null) {
              return _ReceiptPrintingView(receipt: _printingReceipt!);
            }
            return _ReceiptComposerBody(
              seed: widget.seed,
              tasks: tasks,
              titleController: _titleController,
              includeFolderLabels: _includeFolderLabels,
              drawingStrokesJson: _drawingStrokesJson,
              photoPath: _photoPath,
              isGenerating: _isGenerating,
              onIncludeFolderLabelsChanged: (value) {
                setState(() => _includeFolderLabels = value);
              },
              onPersonalise: _showPersonaliseSheet,
              onOpenPro: () => _showReceiptProSheet(tasks: tasks),
              onGenerate: tasks.isEmpty ? null : _generate,
              onBack: _goBack,
            );
          },
        ),
      ),
    );
    return BackButtonListener(
      onBackButtonPressed: () async {
        _goBack();
        return true;
      },
      child: PopScope<void>(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) {
            _goBack();
          }
        },
        child: content,
      ),
    );
  }

  Future<List<Task>> _loadSelectedTasks(List<int> ids) async {
    if (ids.isEmpty) {
      return const <Task>[];
    }
    final repository = ref.read(taskRepositoryProvider);
    final tasks = <Task>[];
    for (final id in ids) {
      final task = await repository.getTask(id);
      if (task != null && task.isCompleted) {
        tasks.add(task);
      }
    }
    tasks.sort((a, b) {
      final completedCompare = (a.completedAt ?? DateTime(0)).compareTo(
        b.completedAt ?? DateTime(0),
      );
      if (completedCompare != 0) {
        return completedCompare;
      }
      return a.id.compareTo(b.id);
    });
    return tasks;
  }

  Future<void> _generate() async {
    if (_isGenerating) {
      return;
    }
    SyncSounds.play(SyncSoundEffect.action);
    setState(() => _isGenerating = true);
    try {
      final hasUnlimitedReceipts =
          ref.read(receiptProEntitlementProvider).value?.isPro ?? false;
      final receipt = await ref
          .read(receiptRepositoryProvider)
          .generateReceipt(
            ReceiptCreateRequest(
              operationId: _operationId,
              source: widget.seed.source,
              defaultTitle: widget.seed.defaultTitle,
              title: _titleController.text,
              selectedTaskIds: widget.seed.selectedTaskIds,
              periodStart: widget.seed.periodStart,
              periodEndExclusive: widget.seed.periodEndExclusive,
              includeFolderLabels: _includeFolderLabels,
              artworkType: _artworkType,
              drawingStrokesJson: _artworkType == 'drawing'
                  ? _drawingStrokesJson
                  : null,
              photoPath: _artworkType == 'photo' ? _photoPath : null,
              hasUnlimitedReceipts: hasUnlimitedReceipts,
            ),
          );
      ref.invalidate(receiptHistoryProvider);
      ref.invalidate(receiptQuotaProvider);
      if (!mounted) {
        return;
      }
      setState(() {
        _printingReceipt = receipt;
        _isGenerating = false;
      });
      unawaited(_openDetailAfterReveal(receipt.id));
    } on ReceiptQuotaExceededException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _isGenerating = false);
      final tasks = await _loadSelectedTasks(widget.seed.selectedTaskIds);
      if (!mounted) {
        return;
      }
      final unlocked = await _showReceiptProSheet(
        status: error.status,
        tasks: tasks,
      );
      if (mounted && unlocked == true) {
        await _generate();
      }
    } on ReceiptSelectionChangedException {
      if (!mounted) {
        return;
      }
      setState(() => _isGenerating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review the selected tasks before generating.'),
        ),
      );
    }
  }

  Future<bool?> _showReceiptProSheet({
    ReceiptQuotaStatus? status,
    List<Task>? tasks,
  }) async {
    final selectedTasks =
        tasks ?? await _loadSelectedTasks(widget.seed.selectedTaskIds);
    if (!mounted) {
      return false;
    }
    return showReceiptProPaywallSheet(
      context: context,
      status: status,
      tasks: selectedTasks,
      title: _titleController.text,
    );
  }

  Future<void> _openDetailAfterReveal(String receiptId) async {
    await Future<void>.delayed(const Duration(milliseconds: 3000));
    if (mounted) {
      context.go('/receipts/$receiptId');
    }
  }

  Future<void> _showPersonaliseSheet() async {
    SyncHaptics.selection();
    final artwork = await showModalBottomSheet<_ReceiptArtworkResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: SyncTasksColorScheme.of(context).surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SizedBox(
          height: MediaQuery.sizeOf(context).height,
          child: ReceiptPersonaliseSheet(
            initialDrawingJson: _drawingStrokesJson,
            initialPhotoPath: _photoPath,
          ),
        );
      },
    );
    if (!mounted || artwork == null) {
      return;
    }
    setState(() {
      _drawingStrokesJson = artwork.drawingStrokesJson;
      _photoPath = artwork.photoPath;
    });
    await _generate();
  }

  String? get _artworkType {
    if (_photoPath != null && _photoPath!.isNotEmpty) {
      return 'photo';
    }
    if (_drawingStrokesJson != null && _drawingStrokesJson!.isNotEmpty) {
      return 'drawing';
    }
    return null;
  }

  void _goBack() {
    SyncHaptics.selection();
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(_fallbackBackRoute);
    }
  }

  String get _fallbackBackRoute {
    return switch (widget.seed.source) {
      ReceiptEntrySource.today => '/today',
      ReceiptEntrySource.completedSelection => '/lists/completed',
      ReceiptEntrySource.insightsPeriod => '/lists/insights',
      ReceiptEntrySource.history => '/receipts',
    };
  }
}

class _ReceiptComposerBody extends ConsumerWidget {
  const _ReceiptComposerBody({
    required this.seed,
    required this.tasks,
    required this.titleController,
    required this.includeFolderLabels,
    required this.drawingStrokesJson,
    required this.photoPath,
    required this.isGenerating,
    required this.onIncludeFolderLabelsChanged,
    required this.onPersonalise,
    required this.onOpenPro,
    required this.onGenerate,
    required this.onBack,
  });

  final ReceiptComposerSeed seed;
  final List<Task> tasks;
  final TextEditingController titleController;
  final bool includeFolderLabels;
  final String? drawingStrokesJson;
  final String? photoPath;
  final bool isGenerating;
  final ValueChanged<bool> onIncludeFolderLabelsChanged;
  final VoidCallback onPersonalise;
  final VoidCallback onOpenPro;
  final VoidCallback? onGenerate;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = SyncTasksColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    final quotaValue = ref.watch(receiptQuotaProvider);
    final proValue = ref.watch(receiptProEntitlementProvider);
    final isPro = proValue.value?.isPro == true;
    final folderNamesById = {
      for (final folder in ref.watch(foldersProvider).value ?? const <Folder>[])
        folder.id: folder.name,
    };
    final previewItems = [
      for (var i = 0; i < tasks.length; i++)
        SavedReceiptItem(
          taskId: tasks[i].id,
          position: i,
          title: tasks[i].title,
          folderName: folderNamesById[tasks[i].folderId],
          completedAt: tasks[i].completedAt ?? DateTime.now(),
        ),
    ];
    final previewHeight = (MediaQuery.sizeOf(context).height * 0.48)
        .clamp(320.0, 430.0)
        .toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ReceiptScreenHeader(title: 'Create receipt', onBack: onBack),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 104),
            children: [
              quotaValue.when(
                data: (status) => _ReceiptQuotaProBanner(
                  status: status,
                  isPro: isPro,
                  onOpenPro: onOpenPro,
                ),
                loading: () => Text(
                  'Checking receipts created this week...',
                  style: _supportingStyle(textTheme, colors),
                ),
                error: (_, _) => Text(
                  'Receipt count unavailable',
                  style: _supportingStyle(textTheme, colors),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Title',
                style: textTheme.labelLarge?.copyWith(
                  color: colors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 56,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.divider),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Center(
                      child: TextField(
                        controller: titleController,
                        maxLength: 80,
                        decoration: const InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          isCollapsed: true,
                        ),
                        style: textTheme.titleMedium?.copyWith(
                          color: colors.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.divider),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 5, 8, 5),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          tasks.isEmpty
                              ? _emptySelectionLabel(seed.source)
                              : _taskCountLabel(tasks.length),
                          style: textTheme.bodyLarge?.copyWith(
                            color: colors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      TextButton(onPressed: null, child: const Text('Edit')),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: previewHeight,
                child: ListenableBuilder(
                  listenable: titleController,
                  builder: (context, _) {
                    return FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.topCenter,
                      child: ReceiptPaperPreview(
                        title: titleController.text,
                        items: previewItems,
                        includeFolderLabels: includeFolderLabels,
                        drawingStrokesJson: drawingStrokesJson,
                        photoPath: photoPath,
                        showArtworkPlaceholder:
                            drawingStrokesJson == null && photoPath == null,
                        showReceiptMetadata: false,
                        onAddArtwork: onPersonalise,
                      ),
                    );
                  },
                ),
              ),
              if (drawingStrokesJson != null || photoPath != null) ...[
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: onPersonalise,
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(
                    photoPath == null ? 'Drawing added' : 'Photo added',
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Material(
                color: colors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: colors.divider),
                ),
                child: SwitchListTile.adaptive(
                  contentPadding: const EdgeInsets.fromLTRB(14, 0, 10, 0),
                  title: const Text('Show folder labels'),
                  value: includeFolderLabels,
                  onChanged: onIncludeFolderLabelsChanged,
                ),
              ),
            ],
          ),
        ),
        ReceiptBottomActionBar(
          child: FilledButton.icon(
            onPressed: isGenerating ? null : onGenerate,
            icon: isGenerating
                ? SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.controlForeground,
                    ),
                  )
                : Icon(SyncIcons.receipt),
            label: const Text('Generate receipt'),
          ),
        ),
      ],
    );
  }

  TextStyle? _supportingStyle(
    TextTheme textTheme,
    SyncTasksColorScheme colors,
  ) {
    return textTheme.bodySmall?.copyWith(
      color: colors.textSecondary,
      fontSize: 13,
      fontWeight: FontWeight.w600,
    );
  }

  String _taskCountLabel(int count) {
    return count == 1 ? '1 task selected' : '$count tasks selected';
  }

  String _emptySelectionLabel(ReceiptEntrySource source) {
    return source == ReceiptEntrySource.insightsPeriod
        ? 'No completions in this period'
        : 'No completed tasks selected';
  }
}

class _ReceiptQuotaProBanner extends StatelessWidget {
  const _ReceiptQuotaProBanner({
    required this.status,
    required this.isPro,
    required this.onOpenPro,
  });

  final ReceiptQuotaStatus status;
  final bool isPro;
  final VoidCallback onOpenPro;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    final title = isPro
        ? 'Unlimited receipts active'
        : '${status.usedThisWeek} of ${status.freeLimit} free receipts used';
    final subtitle = isPro
        ? 'Every receipt you generate is covered by Pro.'
        : 'Pro unlocks unlimited receipts';

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: isPro ? null : onOpenPro,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(SyncIcons.receipt, color: colors.textPrimary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.bodyLarge?.copyWith(
                        color: colors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isPro) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: colors.textPrimary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'PRO',
                    style: textTheme.labelSmall?.copyWith(
                      color: colors.surface,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ReceiptPrintingView extends ConsumerStatefulWidget {
  const _ReceiptPrintingView({required this.receipt});

  final SavedReceipt receipt;

  @override
  ConsumerState<_ReceiptPrintingView> createState() =>
      _ReceiptPrintingViewState();
}

class _ReceiptPrintingViewState extends ConsumerState<_ReceiptPrintingView> {
  static const _printDuration = Duration(milliseconds: 2600);

  bool _paperVisible = false;
  ReceiptPrintingFeedbackHandle? _feedbackHandle;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _feedbackHandle = ref.read(receiptPrintingFeedbackProvider).start();
        setState(() => _paperVisible = true);
      }
    });
  }

  @override
  void dispose() {
    _feedbackHandle?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ReceiptScreenHeader(title: 'Your receipt'),
        Expanded(
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Positioned.fill(
                top: 58,
                child: ClipRect(
                  child: AnimatedSlide(
                    duration: _printDuration,
                    curve: Curves.easeOutQuart,
                    offset: _paperVisible
                        ? Offset.zero
                        : const Offset(0, -0.42),
                    child: AnimatedRotation(
                      duration: _printDuration,
                      curve: Curves.easeOutCubic,
                      turns: _paperVisible ? -0.004 : 0.012,
                      child: AnimatedScale(
                        duration: _printDuration,
                        curve: Curves.easeOutCubic,
                        scale: _paperVisible ? 1 : 0.985,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.topCenter,
                          child: KeyedSubtree(
                            key: const ValueKey('receipt-printing-paper'),
                            child: ReceiptPaperPreview(
                              title: widget.receipt.title,
                              items: widget.receipt.items,
                              includeFolderLabels:
                                  widget.receipt.includeFolderLabels,
                              createdAt: widget.receipt.createdAt,
                              displayNumber: widget.receipt.displayNumber,
                              drawingStrokesJson:
                                  widget.receipt.drawingStrokesJson,
                              photoPath: widget.receipt.photoPath,
                              paperScale: ReceiptPaperScale.printing,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 44,
                left: 72,
                right: 72,
                child: Container(
                  key: const ValueKey('receipt-printer-slot'),
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.24),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      height: 6,
                      margin: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 42),
          child: Text(
            'Printing your wins...',
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: colors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

class _ReceiptArtworkResult {
  const _ReceiptArtworkResult.drawing(this.drawingStrokesJson)
    : photoPath = null;

  const _ReceiptArtworkResult.photo(this.photoPath) : drawingStrokesJson = null;

  final String? drawingStrokesJson;
  final String? photoPath;
}

class ReceiptPersonaliseSheet extends ConsumerStatefulWidget {
  const ReceiptPersonaliseSheet({
    this.initialDrawingJson,
    this.initialPhotoPath,
    super.key,
  });

  final String? initialDrawingJson;
  final String? initialPhotoPath;

  @override
  ConsumerState<ReceiptPersonaliseSheet> createState() =>
      _ReceiptPersonaliseSheetState();
}

class _ReceiptPersonaliseSheetState
    extends ConsumerState<ReceiptPersonaliseSheet> {
  final List<List<Offset>> _strokes = [];
  String _mode = 'drawing';
  String? _photoPath;
  bool _isCapturingPhoto = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialDrawingJson != null) {
      _strokes.addAll(_decodeStrokes(widget.initialDrawingJson!));
    }
    _photoPath = widget.initialPhotoPath;
    if (_photoPath != null && _photoPath!.isNotEmpty) {
      _mode = 'photo';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          6,
          20,
          10 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.divider,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Personalise',
                    style: textTheme.titleLarge?.copyWith(
                      color: colors.textPrimary,
                      fontSize: 29,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _ReceiptPersonaliseTabs(
              value: _mode,
              onChanged: (value) => setState(() => _mode = value),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final panelHeight = constraints.maxHeight
                      .clamp(300.0, 440.0)
                      .toDouble();
                  return Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: double.infinity,
                      height: panelHeight,
                      child: _mode == 'drawing'
                          ? _DrawingCanvas(
                              strokes: _strokes,
                              onChanged: () => setState(() {}),
                            )
                          : _PhotoCapturePanel(
                              photoPath: _photoPath,
                              isCapturing: _isCapturingPhoto,
                              onCapture: _capturePhoto,
                            ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 4),
            if (_mode == 'drawing')
              Row(
                children: [
                  TextButton.icon(
                    style: _toolbarButtonStyle(),
                    onPressed: _strokes.isNotEmpty
                        ? () => setState(() => _strokes.removeLast())
                        : null,
                    icon: const Icon(Icons.undo_rounded),
                    label: const Text('Undo'),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    style: _toolbarButtonStyle(),
                    onPressed: _strokes.isNotEmpty
                        ? () => setState(_strokes.clear)
                        : null,
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('Clear'),
                  ),
                ],
              )
            else if (_photoPath != null)
              Row(
                children: [
                  TextButton.icon(
                    style: _toolbarButtonStyle(),
                    onPressed: _isCapturingPhoto ? null : _capturePhoto,
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: Text(_photoPath == null ? 'Open camera' : 'Retake'),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    style: _toolbarButtonStyle(),
                    onPressed: _photoPath == null || _isCapturingPhoto
                        ? null
                        : () => setState(() => _photoPath = null),
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('Clear'),
                  ),
                ],
              ),
            const SizedBox(height: 2),
            Text(
              _mode == 'drawing'
                  ? 'A signature, a doodle, anything you like.'
                  : 'Snap a photo to add it to your receipt.',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: colors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              key: const ValueKey('receipt-personalise-generate'),
              onPressed: _primaryAction,
              child: const Text('Generate receipt'),
            ),
          ],
        ),
      ),
    );
  }

  VoidCallback? get _primaryAction {
    if (_mode == 'drawing') {
      if (_strokes.isEmpty) {
        return null;
      }
      return () => Navigator.of(
        context,
      ).pop(_ReceiptArtworkResult.drawing(_encodeStrokes(_strokes)));
    }
    if (_photoPath == null || _isCapturingPhoto) {
      return null;
    }
    return () =>
        Navigator.of(context).pop(_ReceiptArtworkResult.photo(_photoPath));
  }

  ButtonStyle _toolbarButtonStyle() {
    return TextButton.styleFrom(
      minimumSize: const Size(0, 40),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Future<void> _capturePhoto() async {
    setState(() => _isCapturingPhoto = true);
    try {
      final path = await ref
          .read(receiptPhotoCaptureServiceProvider)
          .capturePhoto();
      if (!mounted) {
        return;
      }
      if (path == null || path.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No photo captured.')));
        return;
      }
      final processedPath = await ref
          .read(receiptPhotoProcessorProvider)
          .processPhoto(path);
      if (!mounted) {
        return;
      }
      setState(() => _photoPath = processedPath);
    } on PlatformException catch (error) {
      if (!mounted) {
        return;
      }
      final message = switch (error.code) {
        'camera_unavailable' => 'No camera app is available.',
        'permission_denied' => 'Camera permission was denied.',
        _ => 'Could not open the camera.',
      };
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not prepare photo.')));
    } finally {
      if (mounted) {
        setState(() => _isCapturingPhoto = false);
      }
    }
  }

  List<List<Offset>> _decodeStrokes(String value) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is! List) {
        return const [];
      }
      return [
        for (final stroke in decoded)
          if (stroke is List)
            [
              for (final point in stroke)
                if (point is List && point.length == 2)
                  Offset(
                    ((point[0] as num).toDouble()).clamp(0, 1).toDouble(),
                    ((point[1] as num).toDouble()).clamp(0, 1).toDouble(),
                  ),
            ],
      ];
    } catch (_) {
      return const [];
    }
  }

  String _encodeStrokes(List<List<Offset>> strokes) {
    return jsonEncode([
      for (final stroke in strokes)
        [
          for (final point in stroke)
            [
              double.parse(point.dx.toStringAsFixed(4)),
              double.parse(point.dy.toStringAsFixed(4)),
            ],
        ],
    ]);
  }
}

class _ReceiptPersonaliseTabs extends StatelessWidget {
  const _ReceiptPersonaliseTabs({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          _ReceiptPersonaliseTab(
            label: 'Hand drawn',
            icon: Icons.check_rounded,
            selected: value == 'drawing',
            onTap: () => onChanged('drawing'),
          ),
          _ReceiptPersonaliseTab(
            label: 'Photo',
            icon: Icons.photo_camera_outlined,
            selected: value == 'photo',
            onTap: () => onChanged('photo'),
          ),
        ],
      ),
    );
  }
}

class _ReceiptPersonaliseTab extends StatelessWidget {
  const _ReceiptPersonaliseTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    final foreground = selected ? colors.controlForeground : colors.textPrimary;
    return Expanded(
      child: Material(
        color: selected ? colors.textPrimary : Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: foreground),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: textTheme.bodyLarge?.copyWith(
                    color: foreground,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PhotoCapturePanel extends StatelessWidget {
  const _PhotoCapturePanel({
    required this.photoPath,
    required this.isCapturing,
    required this.onCapture,
  });

  final String? photoPath;
  final bool isCapturing;
  final VoidCallback onCapture;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: colors.divider),
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: photoPath == null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.photo_camera_outlined,
                    color: colors.textPrimary,
                    size: 42,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Take photo',
                    style: textTheme.titleMedium?.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Use your camera for this receipt.',
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  OutlinedButton.icon(
                    onPressed: isCapturing ? null : onCapture,
                    icon: isCapturing
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.photo_camera_outlined),
                    label: Text(isCapturing ? 'Opening...' : 'Open camera'),
                  ),
                ],
              ),
            )
          : Stack(
              fit: StackFit.expand,
              children: [
                Image.file(
                  File(photoPath!),
                  key: const ValueKey('receipt-photo-preview'),
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.none,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: colors.textSecondary,
                        size: 32,
                      ),
                    );
                  },
                ),
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: FilledButton.icon(
                    onPressed: isCapturing ? null : onCapture,
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: const Text('Retake'),
                  ),
                ),
              ],
            ),
    );
  }
}

class _DrawingCanvas extends StatelessWidget {
  const _DrawingCanvas({required this.strokes, required this.onChanged});

  final List<List<Offset>> strokes;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: (details) {
        strokes.add([_normalizedPoint(context, details.localPosition)]);
        onChanged();
      },
      onPanUpdate: (details) {
        if (strokes.isEmpty) {
          strokes.add([]);
        }
        strokes.last.add(_normalizedPoint(context, details.localPosition));
        onChanged();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: RepaintBoundary(
          child: CustomPaint(
            key: const ValueKey('receipt-drawing-canvas'),
            painter: _DrawingCanvasPainter(
              strokes: [for (final stroke in strokes) List<Offset>.of(stroke)],
              ink: Colors.black,
              border: colors.divider,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }

  Offset _normalizedPoint(BuildContext context, Offset point) {
    final box = context.findRenderObject()! as RenderBox;
    final size = box.size;
    return Offset(
      (point.dx / size.width).clamp(0, 1).toDouble(),
      (point.dy / size.height).clamp(0, 1).toDouble(),
    );
  }
}

class _DrawingCanvasPainter extends CustomPainter {
  const _DrawingCanvasPainter({
    required this.strokes,
    required this.ink,
    required this.border,
  });

  final List<List<Offset>> strokes;
  final Color ink;
  final Color border;

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()..color = Colors.white;
    final outline = Paint()
      ..color = border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(18),
    );
    canvas.drawRRect(rect, background);
    canvas.drawRRect(rect, outline);

    final paint = Paint()
      ..color = ink
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    for (final stroke in strokes) {
      if (stroke.length < 2) {
        continue;
      }
      final path = Path()
        ..moveTo(stroke.first.dx * size.width, stroke.first.dy * size.height);
      for (final point in stroke.skip(1)) {
        path.lineTo(point.dx * size.width, point.dy * size.height);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DrawingCanvasPainter oldDelegate) {
    return oldDelegate.strokes != strokes ||
        oldDelegate.ink != ink ||
        oldDelegate.border != border;
  }
}

class _ReceiptUnavailableScreen extends StatelessWidget {
  const _ReceiptUnavailableScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SyncTasksColorScheme.of(context).scaffold,
      body: const SafeArea(
        child: SyncEmptyState(
          icon: SyncIcons.receipt,
          title: 'Receipts are not available',
          message: 'This internal feature is hidden in this build.',
        ),
      ),
    );
  }
}
