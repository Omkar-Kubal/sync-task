import 'package:flutter_riverpod/flutter_riverpod.dart';

final localClockProvider = Provider<DateTime>((ref) => DateTime.now());
