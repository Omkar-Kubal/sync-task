import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/theme/synctasks_color_scheme.dart';
import '../../receipts/providers/receipt_feature_provider.dart';
import '../../../shared/sheets/app_bottom_sheet.dart';
import '../../../shared/icons/sync_icons.dart';
import '../../../shared/services/sync_haptics.dart';
import '../../../shared/services/sync_sounds.dart';
import '../../../shared/widgets/sync_grouped_section.dart';
import '../domain/app_settings.dart';
import '../providers/settings_controller.dart';
import '../../tasks/providers/folders_provider.dart';

const syncTasksPrivacyPolicyUrl =
    'https://sites.google.com/view/my-todos/privacy-policy';
const syncTasksFeatureRequestsUrl =
    'mailto:support@appylab.org?subject=Feature%20Request';
const syncTasksSupportEmailUrl = 'mailto:support@appylab.org';

typedef PrivacyPolicyUrlLauncher = Future<bool> Function(Uri uri);

final privacyPolicyUrlLauncherProvider = Provider<PrivacyPolicyUrlLauncher>((
  ref,
) {
  return (uri) => launchUrl(uri, mode: LaunchMode.externalApplication);
});

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({this.backToToday = true, this.onClose, super.key});

  final bool backToToday;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = SyncTasksColorScheme.of(context);
    final receiptFeatureEnabled = ref.watch(receiptFeatureEnabledProvider);
    final settings = ref
        .watch(settingsProvider)
        .maybeWhen(
          data: (settings) => settings,
          orElse: () => const AppSettings(),
        );
    final controller = ref.watch(settingsControllerProvider);
    final folders = ref.watch(foldersProvider).value ?? const <Folder>[];
    final defaultFolderLabel = _defaultFolderLabel(
      settings.defaultFolderId,
      folders,
    );
    final content = Scaffold(
      backgroundColor: colors.scaffold,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SettingsHeader(
                showClose: _showsBack,
                onClose: () => _returnToToday(context),
              ),
              const SizedBox(height: 36),
              const _SectionLabel('General'),
              const SizedBox(height: 10),
              SyncGroupedSection(
                dividerIndent: 84,
                children: [
                  _SettingsRow(
                    iconTileKey: Key('settings-theme-icon-tile'),
                    icon: SyncIcons.appearance,
                    title: 'Theme',
                    value: _themeLabel(settings.themeMode),
                    onTap: () => _showThemeSheet(context, controller),
                  ),
                  _SettingsRow(
                    iconWidget: const _SettingsHugeIcon(
                      icon: HugeIcons.strokeRoundedFolder02,
                    ),
                    title: 'Default Folder',
                    value: defaultFolderLabel,
                    onTap: () => _showDefaultFolderSheet(
                      context,
                      folders,
                      settings,
                      controller,
                    ),
                  ),
                  _SettingsRow(
                    iconWidget: const _SettingsHugeIcon(
                      icon: HugeIcons.strokeRoundedVolumeUp,
                    ),
                    title: 'Sound Effects',
                    value: settings.soundEffects ? 'On' : 'Off',
                    onTap: () =>
                        _showSoundEffectsSheet(context, settings, controller),
                  ),
                  _SettingsRow(
                    iconWidget: const _SettingsHugeIcon(
                      icon: HugeIcons.strokeRoundedBellDot,
                    ),
                    title: 'Notifications',
                    value: settings.notificationsEnabled ? 'On' : 'Off',
                    onTap: () =>
                        _showNotificationsSheet(context, settings, controller),
                  ),
                ],
              ),
              if (receiptFeatureEnabled) ...[
                const SizedBox(height: 28),
                const _SectionLabel('Pro'),
                const SizedBox(height: 10),
                SyncGroupedSection(
                  dividerIndent: 84,
                  children: [
                    _SettingsRow(
                      icon: SyncIcons.receipt,
                      title: 'SyncTasks Pro',
                      value: 'Internal',
                      onTap: () => _showProSheet(context),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 28),
              const _SectionLabel('Support'),
              const SizedBox(height: 10),
              SyncGroupedSection(
                dividerIndent: 84,
                children: [
                  _SettingsRow(
                    iconWidget: const _SettingsHugeIcon(
                      icon: HugeIcons.strokeRoundedBadgeAlert,
                    ),
                    title: "What's New",
                    onTap: () => _showWhatsNewSheet(context),
                  ),
                  _SettingsRow(
                    iconWidget: const _SettingsHugeIcon(
                      icon: HugeIcons.strokeRoundedCommentAdd01,
                    ),
                    title: 'Help & Feedback',
                    onTap: () => _showHelpFeedbackSheet(context),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              const _AppIdentityCard(),
              const SizedBox(height: 28),
              const _SectionLabel('About'),
              const SizedBox(height: 10),
              SyncGroupedSection(
                dividerIndent: 84,
                children: [
                  _SettingsRow(
                    iconWidget: const _SettingsHugeIcon(
                      icon: HugeIcons.strokeRoundedBiometricAccess,
                    ),
                    title: 'Privacy Policy',
                    trailingIcon: Icons.open_in_new_rounded,
                    onTap: () => _openPrivacyPolicy(context, ref),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (!_showsBack) {
      return content;
    }

    final popScope = PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _returnToToday(context);
        }
      },
      child: content,
    );

    if (Router.maybeOf(context) == null) {
      return popScope;
    }

    return BackButtonListener(
      onBackButtonPressed: () async {
        _returnToToday(context);
        return true;
      },
      child: popScope,
    );
  }

  bool get _showsBack => backToToday || onClose != null;

  void _returnToToday(BuildContext context) {
    final close = onClose;
    if (close == null) {
      context.go('/today');
    } else {
      close();
    }
  }

  String _themeLabel(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => 'System',
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
    };
  }

  String _defaultFolderLabel(int? folderId, List<Folder> folders) {
    if (folderId == null) {
      return 'Inbox';
    }
    for (final folder in folders) {
      if (folder.id == folderId) {
        return folder.name;
      }
    }
    return 'Inbox';
  }

  void _showThemeSheet(BuildContext context, SettingsController controller) {
    _showSettingsSheet(
      context,
      _SettingsActionSheet(
        title: 'Choose Theme',
        children: [
          _SheetOption(
            label: 'System',
            onTap: () async {
              await controller.setThemeMode(ThemeMode.system);
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
          _SheetOption(
            label: 'Light',
            onTap: () async {
              await controller.setThemeMode(ThemeMode.light);
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
          _SheetOption(
            label: 'Dark',
            onTap: () async {
              await controller.setThemeMode(ThemeMode.dark);
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showNotificationsSheet(
    BuildContext context,
    AppSettings settings,
    SettingsController controller,
  ) {
    var notifications = settings.notificationsEnabled;
    var sound = settings.notificationSound;
    var vibration = settings.notificationVibration;

    _showSettingsSheet(
      context,
      StatefulBuilder(
        builder: (context, setSheetState) {
          return _SettingsActionSheet(
            title: 'Notification Alerts',
            children: [
              Material(
                color: Colors.transparent,
                child: SwitchListTile(
                  value: notifications,
                  title: const Text('Notifications'),
                  contentPadding: EdgeInsets.zero,
                  onChanged: (value) async {
                    setSheetState(() => notifications = value);
                    await controller.setNotificationsEnabled(value);
                  },
                ),
              ),
              Material(
                color: Colors.transparent,
                child: SwitchListTile(
                  value: sound,
                  title: const Text('Sound'),
                  contentPadding: EdgeInsets.zero,
                  onChanged: (value) async {
                    setSheetState(() => sound = value);
                    await controller.setNotificationSound(value);
                  },
                ),
              ),
              Material(
                color: Colors.transparent,
                child: SwitchListTile(
                  value: vibration,
                  title: const Text('Vibration'),
                  contentPadding: EdgeInsets.zero,
                  onChanged: (value) async {
                    setSheetState(() => vibration = value);
                    await controller.setNotificationVibration(value);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSoundEffectsSheet(
    BuildContext context,
    AppSettings settings,
    SettingsController controller,
  ) {
    var soundEffects = settings.soundEffects;

    _showSettingsSheet(
      context,
      StatefulBuilder(
        builder: (context, setSheetState) {
          return _SettingsActionSheet(
            title: 'Sound Effects',
            children: [
              Material(
                color: Colors.transparent,
                child: SwitchListTile(
                  value: soundEffects,
                  title: const Text('Sound Effects'),
                  contentPadding: EdgeInsets.zero,
                  onChanged: (value) async {
                    setSheetState(() => soundEffects = value);
                    SyncSounds.enabled = value;
                    await controller.setSoundEffects(value);
                  },
                ),
              ),
              Material(
                color: Colors.transparent,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(SyncIcons.sound),
                  title: const Text('Preview'),
                  onTap: soundEffects
                      ? () {
                          SyncHaptics.selection();
                          SyncSounds.play(SyncSoundEffect.complete);
                        }
                      : null,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDefaultFolderSheet(
    BuildContext context,
    List<Folder> folders,
    AppSettings settings,
    SettingsController controller,
  ) {
    _showSettingsSheet(
      context,
      _SettingsActionSheet(
        title: 'Choose Default Folder',
        children: [
          _SheetOption(
            label: 'Inbox',
            selected: settings.defaultFolderId == null,
            onTap: () async {
              await controller.setDefaultFolder(null);
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
          for (final folder in folders.where(
            (folder) => folder.name != 'Inbox',
          ))
            _SheetOption(
              label: folder.name,
              selected: settings.defaultFolderId == folder.id,
              onTap: () async {
                await controller.setDefaultFolder(folder.id);
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
        ],
      ),
    );
  }

  void _showWhatsNewSheet(BuildContext context) {
    _showSettingsSheet(
      context,
      const _WhatsNewSheet(),
      padding: const EdgeInsets.fromLTRB(20, 42, 20, 26),
      handleGap: 0,
      showHandle: false,
    );
  }

  void _showHelpFeedbackSheet(BuildContext context) {
    _showSettingsSheet(
      context,
      _HelpFeedbackSheet(
        onFeatureRequests: () => _openSupportUri(
          context,
          Uri.parse(syncTasksFeatureRequestsUrl),
          'Could not open feature requests',
        ),
        onSupportEmail: () => _openSupportUri(
          context,
          Uri.parse(syncTasksSupportEmailUrl),
          'Could not open support email',
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 42, 20, 28),
      handleGap: 0,
      showHandle: false,
    );
  }

  void _showProSheet(BuildContext context) {
    _showSettingsSheet(
      context,
      const _ProPreviewSheet(),
      padding: const EdgeInsets.fromLTRB(20, 42, 20, 28),
      handleGap: 0,
      showHandle: false,
    );
  }

  Future<void> _openSupportUri(
    BuildContext context,
    Uri uri,
    String failureMessage,
  ) async {
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failureMessage)));
    }
  }

  Future<void> _openPrivacyPolicy(BuildContext context, WidgetRef ref) async {
    final launched = await ref.read(privacyPolicyUrlLauncherProvider)(
      Uri.parse(syncTasksPrivacyPolicyUrl),
    );
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Privacy Policy')),
      );
    }
  }

  void _showSettingsSheet(
    BuildContext context,
    Widget child, {
    EdgeInsetsGeometry padding = const EdgeInsets.fromLTRB(24, 12, 24, 28),
    double handleGap = 20,
    bool showHandle = true,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Theme.of(context).bottomSheetTheme.modalBarrierColor,
      builder: (context) => AppBottomSheet(
        padding: padding,
        handleGap: handleGap,
        showHandle: showHandle,
        child: child,
      ),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader({required this.showClose, required this.onClose});

  final bool showClose;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return SizedBox(
      height: 46,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              'Settings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 29,
                color: colors.textPrimary,
              ),
            ),
          ),
          if (showClose)
            Semantics(
              button: true,
              label: 'Close settings',
              child: ExcludeSemantics(
                child: IconButton(
                  onPressed: () {
                    SyncHaptics.selection();
                    onClose();
                  },
                  tooltip: 'Close settings',
                  style: IconButton.styleFrom(
                    fixedSize: const Size(46, 46),
                    minimumSize: const Size(46, 46),
                    padding: EdgeInsets.zero,
                    side: BorderSide.none,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: const CircleBorder(),
                    backgroundColor: colors.surface,
                  ),
                  icon: Icon(
                    Icons.close_rounded,
                    size: 24,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: colors.textSecondary,
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.title,
    this.icon,
    this.iconWidget,
    this.iconTileKey,
    this.value,
    this.onTap,
    this.trailingIcon = SyncIcons.chevron,
  });

  final String title;
  final IconData? icon;
  final Widget? iconWidget;
  final Key? iconTileKey;
  final String? value;
  final VoidCallback? onTap;
  final IconData trailingIcon;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap == null
            ? null
            : () {
                SyncHaptics.selection();
                onTap!();
              },
        minVerticalPadding: 6,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: _IconTile(key: iconTileKey, icon: icon, child: iconWidget),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: colors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (value != null) ...[
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 116),
                child: Text(
                  value!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 4),
            ],
            Icon(trailingIcon, color: colors.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}

class _SettingsActionSheet extends StatelessWidget {
  const _SettingsActionSheet({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: colors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Semantics(
              button: true,
              label: 'Dismiss',
              child: ExcludeSemantics(
                child: IconButton(
                  tooltip: 'Dismiss',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}

class _WhatsNewSheet extends StatelessWidget {
  const _WhatsNewSheet();

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return KeyedSubtree(
      key: const Key('whats-new-bottom-sheet'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _CenteredSheetTitle("What's New"),
          const SizedBox(height: 36),
          Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  child: Text(
                    'v1.0.0',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Text(
                'September 8, 2026',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colors.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          const _ChangelogItem(
            icon: Icons.rocket_launch_outlined,
            title: 'SyncTasks launch',
            body:
                'SyncTasks now has the core Android task planner in place '
                'with Today, Upcoming, Lists, Search, Settings, and Insights.',
          ),
          const _SheetDivider(),
          const _ChangelogItem(
            icon: Icons.add_task_rounded,
            title: 'Quick Add Polish',
            body:
                'Quick Add now understands natural dates, uses your default '
                'folder, and confirms saved tasks with clear feedback.',
          ),
          const _SheetDivider(),
          const _ChangelogItem(
            icon: Icons.calendar_month_outlined,
            title: 'Upcoming Views',
            body:
                'Upcoming now includes agenda, week, overdue, no-date, and '
                'folder-grouped views for cleaner planning.',
          ),
          const _SheetDivider(),
          const _ChangelogItem(
            icon: Icons.notifications_active_outlined,
            title: 'Local Reminders',
            body:
                'Task reminders are handled with local notifications while '
                'your task data stays on this device.',
          ),
        ],
      ),
    );
  }
}

class _HelpFeedbackSheet extends StatelessWidget {
  const _HelpFeedbackSheet({
    required this.onFeatureRequests,
    required this.onSupportEmail,
  });

  final VoidCallback onFeatureRequests;
  final VoidCallback onSupportEmail;

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: const Key('help-feedback-bottom-sheet'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _CenteredSheetTitle('Help & Feedback'),
          const SizedBox(height: 32),
          const _SheetSectionLabel('Support'),
          const SizedBox(height: 20),
          _SupportActionRow(
            icon: Icons.lightbulb_outline_rounded,
            title: 'Feature Requests',
            onTap: onFeatureRequests,
          ),
          const _SheetDivider(),
          _SupportActionRow(
            icon: Icons.mail_outline_rounded,
            title: 'Support Email',
            onTap: onSupportEmail,
          ),
        ],
      ),
    );
  }
}

class _ProPreviewSheet extends StatelessWidget {
  const _ProPreviewSheet();

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return Column(
      key: const Key('synctasks-pro-preview-sheet'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _CenteredSheetTitle('SyncTasks Pro'),
        const SizedBox(height: 28),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _IconTile(icon: SyncIcons.receipt),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Unlimited receipts',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Purchasing arrives in Phase 2.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colors.textSecondary,
                      fontSize: 14,
                      height: 1.34,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CenteredSheetTitle extends StatelessWidget {
  const _CenteredSheetTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return Text(
      title,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: colors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
    );
  }
}

class _SheetSectionLabel extends StatelessWidget {
  const _SheetSectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return Text(
      label,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: colors.textSecondary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
    );
  }
}

class _ChangelogItem extends StatelessWidget {
  const _ChangelogItem({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _IconTile(icon: icon),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colors.textSecondary,
                    fontSize: 15,
                    height: 1.32,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SupportActionRow extends StatelessWidget {
  const _SupportActionRow({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          SyncHaptics.selection();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              _IconTile(icon: icon),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
              ),
              Icon(
                Icons.open_in_new_rounded,
                color: colors.textPrimary,
                size: 24,
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetDivider extends StatelessWidget {
  const _SheetDivider();

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 56, top: 14, bottom: 14),
      child: Divider(height: 1, color: colors.divider),
    );
  }
}

class _SheetOption extends StatelessWidget {
  const _SheetOption({
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(label),
        trailing: Icon(
          selected ? SyncIcons.check : SyncIcons.chevron,
          size: 18,
        ),
        onTap: onTap,
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({this.icon, this.child, super.key});

  final IconData? icon;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child ?? Icon(icon, color: colors.textPrimary, size: 20),
    );
  }
}

class _SettingsHugeIcon extends StatelessWidget {
  const _SettingsHugeIcon({required this.icon});

  final List<List<dynamic>> icon;

  @override
  Widget build(BuildContext context) {
    return HugeIcon(
      icon: icon,
      size: 20,
      color: SyncTasksColorScheme.of(context).textPrimary,
      strokeWidth: 1.5,
    );
  }
}

class _AppIdentityCard extends StatelessWidget {
  const _AppIdentityCard();

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            const _AppLogoCircle(),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppConstants.appName,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: colors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Fast, local-first task planning',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Version 1.0.0+1',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary.withValues(alpha: 0.74),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppLogoCircle extends StatelessWidget {
  const _AppLogoCircle();

  @override
  Widget build(BuildContext context) {
    final colors = SyncTasksColorScheme.of(context);
    return Container(
      key: const Key('settings-app-logo-circle'),
      width: 44,
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.controlPrimary,
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/logo-whitebackground.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
