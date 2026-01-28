import 'dart:async';

import '../features/alarms/domain/alarm.dart';

/// Holds current ringing state + auto-stop timer.
/// In later steps, Android scheduling will call into this flow.
class AlarmRuntime {
  AlarmRuntime._();
  static final AlarmRuntime instance = AlarmRuntime._();

  final StreamController<Alarm?> _ringingController =
      StreamController<Alarm?>.broadcast();

  Stream<Alarm?> get ringingStream => _ringingController.stream;

  Alarm? _current;
  Timer? _autoStopTimer;

  Alarm? get current => _current;

  /// DEV: set to 20 seconds so you can verify quickly in FlutLab.
  /// Change to Duration(minutes: 5) when you're ready.
  static const Duration unattendedAutoStop = Duration(seconds: 20);

  bool get isRinging => _current != null;

  void startRinging(Alarm alarm) {
    // If something is already ringing, stop it first.
    stopRinging(reason: 'replaced');

    _current = alarm;
    _ringingController.add(_current);

    _autoStopTimer?.cancel();
    _autoStopTimer = Timer(unattendedAutoStop, () {
      stopRinging(reason: 'auto_stop');
    });
  }

  void stopRinging({String reason = 'dismissed'}) {
    _autoStopTimer?.cancel();
    _autoStopTimer = null;

    _current = null;
    _ringingController.add(null);
  }

  void dispose() {
    _autoStopTimer?.cancel();
    _ringingController.close();
  }
}
