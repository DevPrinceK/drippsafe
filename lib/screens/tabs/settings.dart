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
  final TextEditingController _loadingNameController = TextEditingController();
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

  final mybox = Hive.box('drippsafe_db');

  // save settings
  void saveSettings(name, startDate, endDate, loadingName) {
    // check if the data is not empty
    if (name.isEmpty ||
        startDate == null ||
        endDate == null ||
        loadingName.isEmpty) {
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
        'loadingName': loadingName,
      });
      // test print the data

      // show snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Settings Saved Successfully'),
          backgroundColor: Colors.pink[200],
          behavior: SnackBarBehavior.floating,
          width: MediaQuery.of(context).size.width * 0.8,
        ),
      );
      return;
    } catch (e) {
      // show snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          width: MediaQuery.of(context).size.width * 0.8,
        ),
      );
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
        _loadingNameController.text =
            settings['loadingName'] ?? 'Afia Kyeremaah-Yeboah';
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
            const SizedBox(height: 20),
            const Divider(),
            // loading name
            CustomTextField(
              controller: _loadingNameController,
              hintText: 'e.g. Afia Kyeremaah-Yeboah',
              labelText: 'What name should we display on loading?',
              keyboardType: TextInputType.name,
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
                  _loadingNameController.text,
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
