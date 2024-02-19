import 'package:drippsafe/screens/constants/widgets/custombtn.dart';
import 'package:drippsafe/screens/constants/widgets/textFields.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final TextEditingController _nameController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = selectedDate;
        } else {
          _endDate = selectedDate;
        }
      });
    }
  }

  // display tips detail alert dialog
  void _showSuccessDialog(bool isSaved) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                isSaved
                    ? 'assets/images/success.png'
                    : 'assets/images/error.png',
                width: 100,
                height: 100,
              ),
              Text(
                isSaved ? 'Saved' : "Not Saved",
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  final mybox = Hive.box('drippsafe_db');

  // save settings
  void saveSettings(name, startDate, endDate) {
    // check if the data is not empty
    if (name.isEmpty || startDate == null || endDate == null) {
      // show snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('All fields are required'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          width: MediaQuery.of(context).size.width * 0.8,
        ),
      );
      return;
    }
    try {
      mybox.put('settings', {
        'name': name,
        'startDate': startDate,
        'endDate': endDate,
      });
      // test print the data
      
      _showSuccessDialog(true);
      return;
    } catch (e) {
      
      _showSuccessDialog(false);
      return;
    }
  }

  void getSettings() {
    var settings = mybox.get('settings');
    if (settings != null) {
      setState(() {
        _nameController.text = settings['name'];
        _startDate = settings['startDate'];
        _endDate = settings['endDate'];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.pink[900],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Column(
          children: [
            const Center(
              child: Text(
                "Setup your app here",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // username
            CustomTextField(
              controller: _nameController,
              hintText: 'e.g. Kate',
              labelText: 'How Should We Call You?',
              keyboardType: TextInputType.name,
            ),
            const SizedBox(height: 20),
            // start date
            InkWell(
              onTap: () => _selectDate(context, true),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Last Month Period Start Date',
                  hintText: 'Select start date',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  _startDate != null
                      ? DateFormat('yyyy-MM-dd').format(_startDate!)
                      : 'Select start date',
                ),
              ),
            ),
            const SizedBox(height: 20),
            // end date
            InkWell(
              onTap: () => _selectDate(context, false),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Last Month Period End Date',
                  hintText: 'Select end date',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  _endDate != null
                      ? DateFormat('yyyy-MM-dd').format(_endDate!)
                      : 'Select end date',
                ),
              ),
            ),
            const Spacer(),
            // save button
            CustomButton(
              text: 'Save',
              onPressed: () {
                saveSettings(
                  _nameController.text,
                  _startDate,
                  _endDate,
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
