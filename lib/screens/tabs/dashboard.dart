import 'package:drippsafe/screens/constants/widgets/info_rect.dart';
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

  void calculateNextPeriodDates() {
    var box = Hive.box('drippsafe_db');
    var settings = box.get('settings');
    DateTime? startDate = settings['startDate'];
    DateTime? endDate = settings['endDate'];
    if (startDate != null && endDate != null) {
      // Assuming a menstrual cycle of 28 days
      int cycleLength = 28;

      // Calculate the days between the start and end dates
      int daysBetween = endDate.difference(startDate).inDays;

      // Calculate the next start date and end date based on the average cycle length
      var nextStartDate = startDate.add(Duration(days: cycleLength + 1));
      var nextEndDate = nextStartDate.add(Duration(days: daysBetween));

      // Save the next start date and end date to the settings
      settings['nextStartDate'] = nextStartDate;
      settings['nextEndDate'] = nextEndDate;
      box.put('settings', settings);
      setState(() {
        username = settings['name'] ?? 'Ghost';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    calculateNextPeriodDates();
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
                  "This is what the colors mean",
                  style: TextStyle(
                    fontSize: 16,
                    // color: Colors.pink,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InfoRect(title: "Period", color: Colors.pink[500]),
                  InfoRect(title: "Ovulation", color: Colors.green),
                  InfoRect(title: "Safe", color: Colors.grey[300]),
                ],
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
                // chil
                child: Row(
                  children: List.generate(
                    7,
                    (index) {
                      var settings = box.get('settings');
                      DateTime? nextStartDate = settings['nextStartDate'];
                      DateTime? nextEndDate = settings['nextEndDate'];

                      DateTime nextDate = now.add(Duration(days: index));
                      String nextDay = DateFormat('dd').format(nextDate);

                      // ovulation period
                      DateTime ovulStart =
                          nextStartDate!.add(Duration(days: 14));

                      DateTime ovulEnd = ovulStart.add(Duration(days: 6));

                      // check if the next date is within the next period
                      if (nextDate.isAfter(nextStartDate!) &&
                          nextDate.isBefore(nextEndDate!)) {
                        return InfoCircle(
                          day: nextDay,
                          active: true,
                          boxColor: Colors.pink[500],
                          textColor: Colors.white,
                        );
                      } else if (nextDate.isAfter(ovulStart!) &&
                          nextDate.isBefore(ovulEnd!)) {
                        return InfoCircle(
                          day: nextDay,
                          active: true,
                          boxColor: Colors.green,
                          textColor: Colors.black,
                        );
                      } else {
                        return InfoCircle(
                          day: nextDay,
                          active: false,
                          boxColor: Colors.grey[300],
                          textColor: Colors.black,
                        );
                      }
                    },
                  ),
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
