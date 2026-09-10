import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart';
import '../../../core/theme/synctasks_color_scheme.dart';
import '../../../shared/icons/sync_icons.dart';
import '../../../shared/services/sync_haptics.dart';
import '../../../shared/widgets/sync_empty_state.dart';
import '../../tasks/providers/folders_provider.dart';
import '../../tasks/providers/task_controller.dart';
import '../data/receipt_repository.dart';
import '../domain/receipt_composer_seed.dart';
import '../providers/receipt_feature_provider.dart';
import '../providers/receipt_repository_provider.dart';
import '../widgets/receipt_paper.dart';

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
              isGenerating: _isGenerating,
              onIncludeFolderLabelsChanged: (value) {
                setState(() => _includeFolderLabels = value);
              },
              onPersonalise: _showPersonaliseSheet,
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
    setState(() => _isGenerating = true);
    try {
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
              artworkType: _drawingStrokesJson == null ? null : 'drawing',
              drawingStrokesJson: _drawingStrokesJson,
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
      await _showQuotaSheet(error.status);
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

  Future<void> _openDetailAfterReveal(String receiptId) async {
    await Future<void>.delayed(const Duration(milliseconds: 850));
    if (mounted) {
      context.go('/receipts/$receiptId');
    }
  }

  Future<void> _showQuotaSheet(ReceiptQuotaStatus status) {
    final colors = SyncTasksColorScheme.of(context);
    final reset = DateFormat('EEE, d MMM').format(status.weekEndExclusive);
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        final textTheme = Theme.of(context).textTheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekly receipt limit reached',
                  style: textTheme.titleLarge?.copyWith(
                    color: colors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'More free receipts reset on $reset.',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colors.textSecondary,
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showPersonaliseSheet() async {
    SyncHaptics.selection();
    final drawing = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: SyncTasksColorScheme.of(context).surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.92,
          child: ReceiptPersonaliseSheet(
            initialDrawingJson: _drawingStrokesJson,
          ),
        );
      },
    );
    if (!mounted || drawing == null) {
      return;
    }
    setState(() => _drawingStrokesJson = drawing);
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
    required this.isGenerating,
    required this.onIncludeFolderLabelsChanged,
    required this.onPersonalise,
    required this.onGenerate,
    required this.onBack,
  });

  final ReceiptComposerSeed seed;
  final List<Task> tasks;
  final TextEditingController titleController;
  final bool includeFolderLabels;
  final String? drawingStrokesJson;
  final bool isGenerating;
  final ValueChanged<bool> onIncludeFolderLabelsChanged;
  final VoidCallback onPersonalise;
  final VoidCallback? onGenerate;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = SyncTasksColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    final quotaValue = ref.watch(receiptQuotaProvider);
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 12, 8),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Back',
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Create receipt',
                  style: textTheme.titleLarge?.copyWith(
                    color: colors.textPrimary,
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 112),
            children: [
              quotaValue.when(
                data: _quotaLabel,
                loading: () => const Text('Checking free receipts...'),
                error: (_, _) =>
                    const Text('Free receipt allowance unavailable'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: titleController,
                maxLength: 80,
                decoration: const InputDecoration(counterText: ''),
                style: textTheme.titleMedium?.copyWith(
                  color: colors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              Row(
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
              const SizedBox(height: 10),
              ListenableBuilder(
                listenable: titleController,
                builder: (context, _) {
                  return ReceiptPaperPreview(
                    title: titleController.text,
                    items: previewItems,
                    includeFolderLabels: includeFolderLabels,
                    drawingStrokesJson: drawingStrokesJson,
                  );
                },
              ),
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: onPersonalise,
                icon: const Icon(Icons.image_outlined),
                label: Text(
                  drawingStrokesJson == null
                      ? 'Add photo or drawing'
                      : 'Drawing added',
                ),
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Show folder labels'),
                value: includeFolderLabels,
                onChanged: onIncludeFolderLabelsChanged,
              ),
            ],
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.scaffold,
            border: Border(top: BorderSide(color: colors.divider)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
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
          ),
        ),
      ],
    );
  }

  Widget _quotaLabel(ReceiptQuotaStatus status) {
    final label = status.isExhausted
        ? '${status.usedThisWeek} of ${status.freeLimit} free receipts used'
        : '${status.remainingThisWeek} of ${status.freeLimit} free receipts left this week';
    return Text(label);
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

class _ReceiptPrintingView extends StatefulWidget {
  const _ReceiptPrintingView({required this.receipt});

  final SavedReceipt receipt;

  @override
  State<_ReceiptPrintingView> createState() => _ReceiptPrintingViewState();
}

class _ReceiptPrintingViewState extends State<_ReceiptPrintingView> {
  bool _paperVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _paperVisible = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 34, 24, 0),
          child: Text(
            'Your receipt',
            style: textTheme.headlineSmall?.copyWith(
              color: colors.textPrimary,
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 46),
        Container(
          height: 22,
          margin: const EdgeInsets.symmetric(horizontal: 70),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.20),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
        ),
        Expanded(
          child: ClipRect(
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              offset: _paperVisible ? Offset.zero : const Offset(0, -0.95),
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: ReceiptPaperPreview(
                    title: widget.receipt.title,
                    items: widget.receipt.items,
                    includeFolderLabels: widget.receipt.includeFolderLabels,
                    createdAt: widget.receipt.createdAt,
                    displayNumber: widget.receipt.displayNumber,
                    drawingStrokesJson: widget.receipt.drawingStrokesJson,
                  ),
                ),
              ),
            ),
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

class ReceiptPersonaliseSheet extends StatefulWidget {
  const ReceiptPersonaliseSheet({this.initialDrawingJson, super.key});

  final String? initialDrawingJson;

  @override
  State<ReceiptPersonaliseSheet> createState() =>
      _ReceiptPersonaliseSheetState();
}

class _ReceiptPersonaliseSheetState extends State<ReceiptPersonaliseSheet> {
  final List<List<Offset>> _strokes = [];
  String _mode = 'drawing';

  @override
  void initState() {
    super.initState();
    if (widget.initialDrawingJson != null) {
      _strokes.addAll(_decodeStrokes(widget.initialDrawingJson!));
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
          10,
          20,
          18 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 54,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.divider,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Personalise',
                    style: textTheme.titleLarge?.copyWith(
                      color: colors.textPrimary,
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
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
            const SizedBox(height: 14),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'drawing', label: Text('Hand drawn')),
                ButtonSegment(value: 'photo', label: Text('Photo')),
              ],
              selected: {_mode},
              onSelectionChanged: (selected) {
                setState(() => _mode = selected.single);
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _mode == 'drawing'
                  ? _DrawingCanvas(
                      strokes: _strokes,
                      onChanged: () => setState(() {}),
                    )
                  : Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: colors.divider),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Photo personalisation comes next.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton.icon(
                  onPressed: _mode == 'drawing' && _strokes.isNotEmpty
                      ? () => setState(() => _strokes.removeLast())
                      : null,
                  icon: const Icon(Icons.undo_rounded),
                  label: const Text('Undo'),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _mode == 'drawing' && _strokes.isNotEmpty
                      ? () => setState(_strokes.clear)
                      : null,
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _mode == 'drawing'
                  ? 'A signature, a doodle, anything you like.'
                  : 'Photo support is intentionally out of this pass.',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: colors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: _mode == 'drawing' && _strokes.isNotEmpty
                  ? () => Navigator.of(context).pop(_encodeStrokes(_strokes))
                  : null,
              child: const Text('Use drawing'),
            ),
          ],
        ),
      ),
    );
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

class _DrawingCanvas extends StatelessWidget {
  const _DrawingCanvas({required this.strokes, required this.onChanged});

  final List<List<Offset>> strokes;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return GestureDetector(
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
      child: CustomPaint(
        key: const ValueKey('receipt-drawing-canvas'),
        size: const Size.fromHeight(300),
        painter: _DrawingCanvasPainter(
          strokes: strokes,
          ink: colors.textPrimary,
          border: colors.divider,
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
      const Radius.circular(12),
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
