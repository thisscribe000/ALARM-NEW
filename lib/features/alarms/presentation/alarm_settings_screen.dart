import 'package:flutter/material.dart';

import '../data/alarm_settings_store.dart';
import '../domain/alarm_settings.dart';

class AlarmSettingsScreen extends StatefulWidget {
  const AlarmSettingsScreen({super.key});

  @override
  State<AlarmSettingsScreen> createState() => _AlarmSettingsScreenState();
}

class _AlarmSettingsScreenState extends State<AlarmSettingsScreen> {
  final _store = AlarmSettingsStore();

  bool _loading = true;
  AlarmSettings _settings = AlarmSettings.defaultValue;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final s = await _store.load();
    if (!mounted) return;
    setState(() {
      _settings = s;
      _loading = false;
    });
  }

  Future<void> _save(AlarmSettings s) async {
    setState(() => _settings = s);
    await _store.save(s);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alarm Settings'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Snooze limit',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: RadioGroup<int?>(
                      groupValue: _settings.snoozeLimit,
                      onChanged: (v) {
                        if (v == null) {
                          _save(_settings.copyWith(snoozeLimitToNull: true));
                        } else {
                          _save(_settings.copyWith(snoozeLimit: v));
                        }
                      },
                      child: Column(
                        children: const [
                          RadioListTile<int?>(
                            value: 3,
                            title: Text('3 times'),
                          ),
                          RadioListTile<int?>(
                            value: 5,
                            title: Text('5 times'),
                          ),
                          RadioListTile<int?>(
                            value: null,
                            title: Text('Unlimited'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Dismiss method',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: RadioGroup<DismissMethod>(
                      groupValue: _settings.dismissMethod,
                      onChanged: (v) {
                        if (v == null) return;
                        _save(_settings.copyWith(dismissMethod: v));
                      },
                      child: const Column(
                        children: [
                          RadioListTile<DismissMethod>(
                            value: DismissMethod.normal,
                            title: Text('Normal'),
                            subtitle: Text(
                                'Dismiss button stops the alarm immediately'),
                          ),
                          RadioListTile<DismissMethod>(
                            value: DismissMethod.ticTacToe,
                            title: Text('Tic-Tac-Toe'),
                            subtitle: Text(
                              'Dismiss opens Tic-Tac-Toe. Win or lose dismisses.\n'
                              '(We build the game next step)',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Tip: We’re in DEV mode for snooze timing so you can test quickly.\n'
                  'Android real scheduling comes after the UI + logic is solid.',
                ),
              ],
            ),
    );
  }
}
