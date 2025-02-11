import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:plant_book/constants.dart';

class PlantReminderPage extends StatefulWidget {
  const PlantReminderPage({super.key});

  @override
  _PlantReminderPageState createState() => _PlantReminderPageState();
}

class _PlantReminderPageState extends State<PlantReminderPage> {
  final List<Map<String, dynamic>> _reminders = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _selectedDateTime = DateTime.now();
  String _selectedFrequency = 'Once';
  String _selectedPlantType = 'General';
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        const InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _scheduleNotification(Map<String, dynamic> reminder) async {
    try {
      // Handle both DateTime and Timestamp types
      DateTime scheduledDate = reminder['dateTime'] is Timestamp
          ? (reminder['dateTime'] as Timestamp).toDate()
          : reminder['dateTime'];

      // Create Android-specific notification details
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'plant_reminders',
        'Plant Care Reminders',
        importance: Importance.max,
        priority: Priority.high,
        colorized: true,
        color: Colors.green,
      );

      // Create notification details
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      // Schedule notification
      // await _notificationsPlugin.schedule(
      //   reminder['id'] as int,
      //   '🌱 Plant Reminder: ${reminder['title']}',
      //   reminder['description'],
      //   scheduledDate,
      //   platformChannelSpecifics,
      // );
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _addReminder() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title for the reminder')),
      );
      return;
    }

    final newReminder = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'title': _titleController.text,
      'description': _descriptionController.text,
      'dateTime': _selectedDateTime,
      'frequency': _selectedFrequency,
      'plantType': _selectedPlantType,
    };

    setState(() {
      _reminders.add(newReminder);
      _reminders.sort((a, b) => a['dateTime'].compareTo(b['dateTime']));
    });

    _scheduleNotification(newReminder);
    _titleController.clear();
    _descriptionController.clear();
  }

  void _deleteReminder(int index) async {
    await _notificationsPlugin.cancel(_reminders[index]['id']);
    setState(() {
      _reminders.removeAt(index);
    });
  }

  Widget _buildFrequencySelector() {
    const frequencies = ['Once', 'Daily', 'Weekly', 'Monthly'];
    return Wrap(
      spacing: 8,
      children: frequencies.map((frequency) {
        return ChoiceChip(
          label: Text(frequency),
          selected: _selectedFrequency == frequency,
          selectedColor: Constants.primaryColor,
          labelStyle: TextStyle(
            color: _selectedFrequency == frequency
                ? Colors.white
                : Colors.green[800],
          ),
          onSelected: (selected) {
            setState(() {
              _selectedFrequency = frequency;
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildPlantTypeSelector() {
    final plantTypes = {
      'General': Icons.spa,
      'Succulent': Icons.grass,
      'Flower': Icons.local_florist,
      'Tree': Icons.park,
    };
    return Wrap(
      spacing: 8,
      children: plantTypes.entries.map((entry) {
        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(entry.value, size: 18),
              const SizedBox(width: 4),
              Text(entry.key),
            ],
          ),
          selected: _selectedPlantType == entry.key,
          selectedColor: Constants.primaryColor,
          labelStyle: TextStyle(
            color: _selectedPlantType == entry.key
                ? Colors.white
                : Colors.green[800],
          ),
          onSelected: (selected) {
            setState(() {
              _selectedPlantType = entry.key;
            });
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Plant Reminders',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Constants.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _showCalendarOverview(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.green[50]!,
                    Colors.green[100]!,
                  ],
                ),
              ),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              TextField(
                                controller: _titleController,
                                decoration: InputDecoration(
                                  labelText: 'Reminder Title',
                                  labelStyle:
                                      TextStyle(color: Colors.green[800]),
                                  prefixIcon: Icon(Icons.title,
                                      color: Colors.green[800]),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              TextField(
                                controller: _descriptionController,
                                maxLines: 2,
                                decoration: InputDecoration(
                                  labelText: 'Description',
                                  labelStyle:
                                      TextStyle(color: Colors.green[800]),
                                  prefixIcon: Icon(Icons.description,
                                      color: Colors.green[800]),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              ListTile(
                                leading: Icon(Icons.calendar_today,
                                    color: Colors.green[800]),
                                title: Text(
                                  'Date & Time',
                                  style: TextStyle(color: Colors.green[800]),
                                ),
                                subtitle: Text(
                                  DateFormat('MMM dd, yyyy - hh:mm a')
                                      .format(_selectedDateTime),
                                  style: TextStyle(color: Colors.green[600]),
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.edit,
                                      color: Colors.green[800]),
                                  onPressed: () => _selectDateTime(context),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Frequency:',
                                      style:
                                          TextStyle(color: Colors.green[800])),
                                  _buildFrequencySelector(),
                                  const SizedBox(height: 10),
                                  Text('Plant Type:',
                                      style:
                                          TextStyle(color: Colors.green[800])),
                                  _buildPlantTypeSelector(),
                                ],
                              ),
                              const SizedBox(height: 15),
                              ElevatedButton.icon(
                                icon:
                                    const Icon(Icons.add_alarm, color: Colors.white),
                                label: const Text('Create Reminder'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Constants.primaryColor,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: _addReminder,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final reminder = _reminders[index];
                        return _buildReminderCard(reminder, index);
                      },
                      childCount: _reminders.length,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(Map<String, dynamic> reminder, int index) {
    final daysRemaining =
        reminder['dateTime'].difference(DateTime.now()).inDays;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(
          _getPlantTypeIcon(reminder['plantType']),
          color: Colors.green[800],
          size: 32,
        ),
        title: Text(
          reminder['title'],
          style: TextStyle(
            color: Colors.green[900],
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(reminder['description']),
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.green[600]),
                const SizedBox(width: 5),
                Text(
                  DateFormat('MMM dd, yyyy - hh:mm a')
                      .format(reminder['dateTime']),
                  style: TextStyle(color: Colors.green[600]),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.repeat, size: 14, color: Colors.green[600]),
                const SizedBox(width: 5),
                Text(
                  'Repeats: ${reminder['frequency']}',
                  style: TextStyle(color: Colors.green[600]),
                ),
              ],
            ),
            if (daysRemaining > 0)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  '$daysRemaining days remaining',
                  style: TextStyle(color: Colors.green[800], fontSize: 12),
                ),
              ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red[300]),
          onPressed: () => _deleteReminder(index),
        ),
      ),
    );
  }

  IconData _getPlantTypeIcon(String type) {
    switch (type) {
      case 'Succulent':
        return Icons.grass;
      case 'Flower':
        return Icons.local_florist;
      case 'Tree':
        return Icons.park;
      default:
        return Icons.spa;
    }
  }

  void _showCalendarOverview() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reminder Calendar',
            style: TextStyle(color: Colors.green[800])),
        content: SizedBox(
          width: double.maxFinite,
          child: CalendarDatePicker(
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2100),
            onDateChanged: (date) {},
          ),
        ),
        actions: [
          TextButton(
            child: Text('Close', style: TextStyle(color: Colors.green[800])),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
