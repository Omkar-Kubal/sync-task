import 'package:flutter/material.dart';

class SyncIcons {
  const SyncIcons._();

  static const IconData upcoming = Icons.event_rounded;
  static const IconData lists = Icons.checklist_rounded;
  static const IconData settings = Icons.settings_rounded;
  static const IconData search = Icons.search_rounded;
  static const IconData insights = Icons.insights_rounded;

  static const IconData create = Icons.add_rounded;
  static const IconData submit = Icons.arrow_upward_rounded;
  static const IconData completed = Icons.task_alt_rounded;
  static const IconData receipt = Icons.receipt_long_outlined;
  static const IconData premium = Icons.diamond_outlined;
  static const IconData folder = Icons.folder_rounded;
  static const IconData reminder = Icons.notifications_none_rounded;
  static const IconData appearance = Icons.format_paint_rounded;
  static const IconData notifications = Icons.notifications_none_rounded;
  static const IconData sound = Icons.volume_up_rounded;
  static const IconData vibration = Icons.vibration_rounded;
  static const IconData storage = Icons.storage_rounded;
  static const IconData sync = Icons.sync_rounded;
  static const IconData version = Icons.info_rounded;
  static const IconData privacy = Icons.lock_rounded;
  static const IconData feedback = Icons.help_rounded;

  static const IconData date = Icons.event_rounded;
  static const IconData time = Icons.schedule_rounded;
  static const IconData duration = Icons.timer_rounded;
  static const IconData repeat = Icons.repeat_rounded;

  static const IconData tomorrow = Icons.wb_sunny_rounded;
  static const IconData nextWeek = Icons.arrow_forward_rounded;
  static const IconData noDate = Icons.close_rounded;

  static const IconData more = Icons.more_horiz_rounded;
  static const IconData close = Icons.close_rounded;
  static const IconData viewOptions = Icons.tune_rounded;
  static const IconData selectTasks = Icons.checklist_rounded;
  static const IconData check = Icons.check_rounded;
  static const IconData chevron = Icons.chevron_right_rounded;
  static const IconData dropdown = Icons.unfold_more_rounded;

  static Color premiumSilver(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFD8DCE2)
        : const Color(0xFF8F96A3);
  }

  static Color premiumSilverOnFilled(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF6F7680)
        : const Color(0xFFE8EAEE);
  }
}
