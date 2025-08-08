import 'package:drippsafe/db/hive/initial_data.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TipScreen extends StatefulWidget {
  const TipScreen({super.key});

  @override
  State<TipScreen> createState() => _TipScreenState();
}

class _TipScreenState extends State<TipScreen> {
  List tips = [];
  // display tips detail alert dialog
  void _showTipsDetailDialog(tip, description, tipNo, fav) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.tips_and_updates,
                size: 50,
                color: Colors.greenAccent,
              ),
              const Divider(),
              Text(
                'Tip # $tipNo',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(tip),
            ],
          ),
          content: Text(description),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
            IconButton(
                onPressed: () {
                  addFavTip(tipNo);
                },
                icon: Icon(
                  Icons.favorite,
                  color: fav ? Colors.red : Colors.grey,
                )),
          ],
        );
      },
    );
  }

  void addFavTip(id) {
    // change the favourite status of the tip in the box to true
    var mybox = Hive.box('drippsafe_db');
    var tipsData = mybox.get('tips').toList();
    var tipIndex = tipsData.indexWhere((tip) => tip['id'] == id);
    tipsData[tipIndex]['favourite'] = true;
    mybox.put('tips', tipsData);
    initializeTips();

    // show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Tip added to favourites!'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        width: MediaQuery.of(context).size.width * 0.8,
      ),
    );
    Navigator.of(context).pop();
  }

  void initializeTips() async {
    var mybox = Hive.box('drippsafe_db');
    // construct list of tips as tip model
    List tipsModelData = [];

    if (mybox.get('tips') == null || mybox.get('tips').isEmpty) {
      for (var tip in initialTips) {
        tipsModelData.add({
          "id": (initialTips.indexOf(tip) + 1).toString(),
          "title": tip['tip'],
          "description": tip['description'],
          "created_at": DateTime.now().toString(),
          "favourite": false,
        });
      }
      mybox.put('tips', tipsModelData);
    }

    // get the tips data from the box
    List tipsData = mybox.get('tips').toList();

    setState(() {
      tips = tipsData;
    });
  }

  @override
  void initState() {
    super.initState();
    initializeTips();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tips'),
        backgroundColor: Colors.pink[900],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Here are some tips to help you through your period!",
              style: TextStyle(fontSize: 16),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: tips.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () => _showTipsDetailDialog(
                      tips[index]['title'],
                      tips[index]['description'],
                      tips[index]['id'],
                      tips[index]['favourite'],
                    ),
                    child: Card(
                      elevation: 2,
                      child: Container(
                        color: Colors.grey[100],
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.lightbulb,
                                  color: tips[index]['favourite']
                                      ? const Color.fromARGB(255, 110, 177, 66)
                                      : Colors.grey,
                                  size: 40,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Tip #${index + 1}",
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      tips[index]['title'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Tips Refreshed!'),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              width: MediaQuery.of(context).size.width * 0.8,
            ),
          );
        },
        shape: const CircleBorder(),
        backgroundColor: Colors.pink[900],
        foregroundColor: Colors.white,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
