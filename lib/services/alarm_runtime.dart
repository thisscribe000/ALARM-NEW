import 'dart:async';

import '../features/alarms/domain/alarm.dart';

class AlarmRuntime {
  AlarmRuntime._();
  static final AlarmRuntime instance = AlarmRuntime._();

  final StreamController<Alarm?> _ringingController =
      StreamController<Alarm?>.broadcast();

  Stream<Alarm?> get ringingStream => _ringingController.stream;

  Alarm? _current;
  Timer? _autoStopTimer;
  Timer? _snoozeTimer;

  // Snooze tracking for the current alarm ring cycle
  int _snoozeCount = 0;

  Alarm? get current => _current;
  bool get isRinging => _current != null;

  /// DEV: Keep short so you can test quickly in FlutLab.
  /// Switch to Duration(minutes: 5) when ready.
  static const Duration unattendedAutoStop = Duration(seconds: 20);

  /// DEV: Snooze minutes mapped to seconds (so you can SEE it).
  /// Later we switch to real minutes.
  static const bool devModeFastSnooze = true;

  int get snoozeCount => _snoozeCount;

  void startRinging(Alarm alarm) {
    stopRinging(reason: 'replaced');

    _current = alarm;
    _ringingController.add(_current);

    _autoStopTimer?.cancel();
    _autoStopTimer = Timer(unattendedAutoStop, () {
      stopRinging(reason: 'auto_stop');
    });
  }

  /// Snooze the current alarm.
  ///
  /// [minutes] is 5/10/15/30.
  /// [maxSnoozes] can be 3, 5, or null for unlimited.
  ///
  /// Returns:
  /// - true if snooze scheduled
  /// - false if blocked (limit reached or no current alarm)
  bool snooze({
    required int minutes,
    int? maxSnoozes,
  }) {
    final currentAlarm = _current;
    if (currentAlarm == null) return false;

    if (maxSnoozes != null && _snoozeCount >= maxSnoozes) {
      return false;
    }

    _snoozeCount++;

    // Stop current ringing UI (caller will pop)
    _autoStopTimer?.cancel();
    _autoStopTimer = null;

    _current = null;
    _ringingController.add(null);

    // Schedule re-ring
    _snoozeTimer?.cancel();

    final delay = _devDelayForMinutes(minutes);
    _snoozeTimer = Timer(delay, () {
      startRinging(currentAlarm);
    });

    return true;
  }

  Duration _devDelayForMinutes(int minutes) {
    if (!devModeFastSnooze) return Duration(minutes: minutes);

    // DEV mapping: minutes -> seconds (5 -> 5s, 10 -> 10s ...)
    return Duration(seconds: minutes);
  }

  void resetSnoozeCount() {
    _snoozeCount = 0;
  }

  void stopRinging({String reason = 'dismissed'}) {
    _autoStopTimer?.cancel();
    _autoStopTimer = null;

    _snoozeTimer?.cancel();
    _snoozeTimer = null;

    _current = null;
    _ringingController.add(null);

    // Reset snooze cycle when alarm is dismissed/fully stopped
    resetSnoozeCount();
  }

  void dispose() {
    _autoStopTimer?.cancel();
    _snoozeTimer?.cancel();
    _ringingController.close();
  }
}
