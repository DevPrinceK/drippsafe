import 'package:drippsafe/screens/loading.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // initialize the hive
  await Hive.initFlutter();

  // open the box
  await Hive.openBox('drippsafe_db');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'drippsafe',
      theme: ThemeData(
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CustomPageTransitionsBuilder(),
            TargetPlatform.iOS: CustomPageTransitionsBuilder(),
          },
        ),
      ),
      home: FutureBuilder(
        future: Hive.openBox('drippsafe_db'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return const LoadingScreen();
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

// smooth scroll transition
class CustomPageTransitionsBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.easeInOutCubic;

    var curveTween = CurveTween(curve: curve);
    var tween = Tween(begin: begin, end: end).chain(curveTween);

    var offsetAnimation = animation.drive(tween);

    return SlideTransition(
      position: offsetAnimation,
      child: child,
    );
  }
}



// import 'package:drippsafe/screens/loading.dart';
// import 'package:flutter/material.dart';
// import 'package:hive_flutter/hive_flutter.dart';

// void main() async {
//   // initialize the hive
//   await Hive.initFlutter();

//   // open the box
//   var box = Hive.openBox('drippsafe_db');
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'drippsafe',
//       theme: ThemeData(
//         pageTransitionsTheme: PageTransitionsTheme(
//           builders: {
//             TargetPlatform.android: CustomPageTransitionsBuilder(),
//             TargetPlatform.iOS: CustomPageTransitionsBuilder(),
//           },
//         ),
//       ),
//       home: const LoadingScreen(),
//     );
//   }
// }

// // smooth scroll transition
// class CustomPageTransitionsBuilder extends PageTransitionsBuilder {
//   @override
//   Widget buildTransitions<T>(
//     PageRoute<T> route,
//     BuildContext context,
//     Animation<double> animation,
//     Animation<double> secondaryAnimation,
//     Widget child,
//   ) {
//     const begin = Offset(1.0, 0.0);
//     const end = Offset.zero;
//     const curve = Curves.easeInOutCubic;

//     var curveTween = CurveTween(curve: curve);
//     var tween = Tween(begin: begin, end: end).chain(curveTween);

//     var offsetAnimation = animation.drive(tween);

//     return SlideTransition(
//       position: offsetAnimation,
//       child: child,
//     );
//   }
// }
