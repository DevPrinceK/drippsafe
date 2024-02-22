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
  bool noSetup = true;
  var box = Hive.box('drippsafe_db');

  void calculateNextPeriodDates() {
    var box = Hive.box('drippsafe_db');
    var settings = box.get('settings', defaultValue: {});
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
      try {
        settings['nextStartDate'] = nextStartDate;
        settings['nextEndDate'] = nextEndDate;
        box.put('settings', settings);
        setState(() {
          noSetup = false;
        });
      } catch (e) {
        print(e);
        setState(() {
          noSetup = true;
        });
      }
      setState(() {
        username = settings['name'] ?? 'Ghost';
      });
    }
  }

  // show dismissible snackbar
  void showDismissableSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        // width: MediaQuery.of(context).size.width * 0.9,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),

        content: Center(child: Text(message)),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Close',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    calculateNextPeriodDates();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (box.get('settings') == null) {
        showDismissableSnackBar(context, "Configure your app in Settings");
      }
    });
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Tooltip(
                    message: "Days till next period",
                    child: InfoCard(
                      title: 'Year',
                      value: '2024',
                    ),
                  ),
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
                      title: 'Day',
                      value: currentDay,
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
                  Tooltip(
                    message: "Red circles means period",
                    child: InfoRect(
                      title: "Period",
                      color: Colors.pink[500],
                    ),
                  ),
                  Tooltip(
                    message: "Green circles means ovulation",
                    child: InfoRect(title: "Ovulation", color: Colors.green),
                  ),
                  Tooltip(
                    message: "Grey circles means safe",
                    child: InfoRect(title: "Safe", color: Colors.grey[300]),
                  ),
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
                      var settings = box.get(
                        'settings',
                        defaultValue: {
                          'nextStartDate': now,
                          'nextEndDate': now.add(const Duration(days: 5)),
                          'startDate': now.add(const Duration(days: 5)),
                          'endDate': now.add(const Duration(days: 10)),
                        },
                      );
                      DateTime? nextStartDate = settings['nextStartDate'];
                      DateTime? nextEndDate = settings['nextEndDate'];
                      DateTime? startDate = settings['startDate'];
                      DateTime? endDate = settings['endDate'];

                      DateTime nextDate = now.add(Duration(days: index));
                      String nextDay = DateFormat('dd').format(nextDate);

                      // current ovulation period
                      DateTime currentOvulStart =
                          startDate!.add(const Duration(days: 14));
                      DateTime currentOvulEnd =
                          currentOvulStart.add(const Duration(days: 6));

                      // next ovulation period
                      DateTime nextOvulStart =
                          nextStartDate!.add(const Duration(days: 14));

                      DateTime nextOvulEnd =
                          nextOvulStart.add(const Duration(days: 6));

                      print("Next Start Date is: $nextStartDate");
                      print("Next End Date is: $nextEndDate");
                      print("Ovulation Start Date is: $nextOvulStart");
                      print("Ovulation End Date is: $nextOvulEnd");

                      // check if the next date is within the next period
                      if ((nextDate.isAfter(startDate) &&
                              nextDate.isBefore(endDate!)) ||
                          (nextDate.isAfter(nextStartDate) &&
                              nextDate.isBefore(nextEndDate!))) {
                        return InfoCircle(
                          day: nextDay,
                          active: true,
                          boxColor: Colors.pink[500],
                          textColor: Colors.white,
                        );
                      } else if ((nextDate.isAfter(currentOvulStart) &&
                              nextDate.isBefore(currentOvulEnd)) ||
                          (nextDate.isAfter(nextOvulStart) &&
                              nextDate.isBefore(nextOvulEnd))) {
                        return InfoCircle(
                          day: nextDay,
                          active: false,
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
