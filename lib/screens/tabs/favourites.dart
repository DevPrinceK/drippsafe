import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class FavouritScreen extends StatefulWidget {
  const FavouritScreen({super.key});

  @override
  State<FavouritScreen> createState() => _FavouritScreenState();
}

class _FavouritScreenState extends State<FavouritScreen> {
  List favTips = [];

  // display tips detail alert dialog
  void _showTipsDetailDialog(tip, description, tipNo) {
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
          ],
        );
      },
    );
  }

  void getFavTips() async {
    // get the favourite tips from the database
    List tips = await Hive.box('drippsafe_db').get('tips');
    // filter the tips to get the favourite ones
    List filteredTips = tips.where((tip) => tip['favourite'] == true).toList();
    setState(() {
      favTips = filteredTips;
    });
  }

  void removeFavoriteTip(id) {
    // change the favourite status of the tip in the box to false
    var mybox = Hive.box('drippsafe_db');
    var tipsData = mybox.get('tips').toList();
    var index = tipsData.indexWhere((tip) => tip['id'] == id);
    tipsData[index]['favourite'] = false;
    mybox.put('tips', tipsData);
    // show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Tip removed from favourites!'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        width: MediaQuery.of(context).size.width * 0.8,
      ),
    );
    getFavTips();
  }

  @override
  void initState() {
    super.initState();
    getFavTips();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favourite Tips'),
        backgroundColor: Colors.pink[900],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: favTips.isEmpty
            ? const Center(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.heart_broken, size: 70, color: Colors.grey),
                  Text(
                    "No tips added to favourites yet!",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Here are your favourite tips!",
                    style: TextStyle(fontSize: 16),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: favTips.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () => _showTipsDetailDialog(
                            favTips[index]["title"],
                            favTips[index]["description"],
                            favTips[index]["id"],
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
                                        color:
                                            Color.fromARGB(255, 110, 177, 66),
                                        size: 40,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Tip #${favTips[index]["id"]}",
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            favTips[index]["title"],
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        onPressed: () {
                                          removeFavoriteTip(
                                              favTips[index]["id"]);
                                        },
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
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
    );
  }
}
