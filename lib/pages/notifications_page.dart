import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // switches
  bool _dailyReminder = true;
  bool _activityOnPoll = false;
  bool _newPollInInterests = true;

  // Helper widget for row with switch
  Widget _buildSwitchRow(String title, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, color: Color(0xFF1A4D4D)),
            ),
          ),
          //set switch color
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF4EE06D),
            inactiveTrackColor: Color(0xFF1A4D4D),
            inactiveThumbColor: Color(0xFF4EE06D),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // style AppBar
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Notifications',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A4D4D)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // section header
            const Text(
              'System notifications',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A4D4D)),
            ),
            const Divider(height: 20, thickness: 1),

            // Daily reminder
            _buildSwitchRow(
              'Daily reminder',
              _dailyReminder,
                  (bool newValue) {
                setState(() {
                  _dailyReminder = newValue;
                });
              },
            ),

            // Activity on your poll
            _buildSwitchRow(
              'Activity on your poll',
              _activityOnPoll,
                  (bool newValue) {
                setState(() {
                  _activityOnPoll = newValue;
                });
              },
            ),

            // New poll in your interests
            _buildSwitchRow(
              'New poll in your interests',
              _newPollInInterests,
                  (bool newValue) {
                setState(() {
                  _newPollInInterests = newValue;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}