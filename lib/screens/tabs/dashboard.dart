import 'dart:ffi';

import 'package:drippsafe/screens/constants/widgets/infocircle.dart';
import 'package:drippsafe/screens/constants/widgets/infocard.dart';
import 'package:drippsafe/screens/constants/widgets/tipcard.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String username = 'Ghost';
  var box = Hive.box('drippsafe_db');

  // get username from hive
  void getUsername() {
    var settings = box.get('settings');
    setState(() {
      username = settings['name'] ?? 'Ghost';
    });
  }

  @override
  void initState() {
    super.initState();
    getUsername();
  }

  @override
  Widget build(BuildContext context) {
    // Get the current date and time
    DateTime now = DateTime.now();
    // current year
    String currentYear = DateFormat('yyyy').format(now);
    // current month in number
    String currentMonth = DateFormat('MM').format(now);
    // current month in text
    String currentMonthText = DateFormat('MMMM').format(now);
    // current day in number
    String currentDay = DateFormat('dd').format(now);
    // current day as int
    int currentDayInt = int.parse(currentDay);

    return Scaffold(
      appBar: AppBar(
        title: const Text('drippsafe'),
        backgroundColor: Colors.pink[900],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hi, $username!",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Center(
                child: Text(
                  "Welcome to drippsafe!",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Tooltip(
                    message: "Current month",
                    child: InfoCard(
                      title: 'Month',
                      value: currentMonth,
                    ),
                  ),
                  Tooltip(
                    message: "Current day",
                    child: InfoCard(
                      title: 'Days',
                      value: currentDay,
                    ),
                  ),
                  const Tooltip(
                    message: "Days till next period",
                    child: InfoCard(
                      title: 'Left',
                      value: '6',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  "Your next period is in 6 days",
                  style: TextStyle(
                    fontSize: 16,
                    // color: Colors.pink,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "$currentDay - ${currentDayInt + 6} $currentMonthText $currentYear",
                style: const TextStyle(
                  fontSize: 16,
                  // color: Colors.pink,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              // next 7 days
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(width: 10),
                    InfoCircle(
                      active: true,
                      day: (currentDayInt).toString(),
                    ),
                    SizedBox(width: 5),
                    InfoCircle(
                      active: true,
                      day: (currentDayInt + 1).toString(),
                    ),
                    SizedBox(width: 5),
                    InfoCircle(
                      active: true,
                      day: (currentDayInt + 2).toString(),
                    ),
                    SizedBox(width: 5),
                    InfoCircle(
                      active: false,
                      day: (currentDayInt + 3).toString(),
                    ),
                    SizedBox(width: 5),
                    InfoCircle(
                      active: false,
                      day: (currentDayInt + 4).toString(),
                    ),
                    SizedBox(width: 5),
                    InfoCircle(
                      active: false,
                      day: (currentDayInt + 5).toString(),
                    ),
                    SizedBox(width: 5),
                    InfoCircle(
                      active: false,
                      day: (currentDayInt + 6).toString(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Tips for you",
                    style: TextStyle(
                      fontSize: 16,
                      // color: Colors.pink,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: null,
                    child: Text("More"),
                  )
                ],
              ),
              const SizedBox(height: 20),
              const SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    TipCard(
                      title: 'Exercise regularly to keep fit',
                      imgName: 'assets/images/workout.png',
                    ),
                    TipCard(
                      title: 'Have enough sleep to stay healthy',
                      imgName: 'assets/images/sleep.png',
                    ),
                    TipCard(
                      title: 'Eat healthy to stay healthy',
                      imgName: 'assets/images/eat.png',
                    ),
                    TipCard(
                      title: 'Medidate to stay calm',
                      imgName: 'assets/images/yoga.png',
                    ),
                    TipCard(
                      title: 'Read to keep your mind sharp',
                      imgName: 'assets/images/read.png',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
