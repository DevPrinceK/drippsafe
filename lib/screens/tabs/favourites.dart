import 'package:flutter/material.dart';

class FavouritScreen extends StatefulWidget {
  const FavouritScreen({super.key});

  @override
  State<FavouritScreen> createState() => _FavouritScreenState();
}

class _FavouritScreenState extends State<FavouritScreen> {
  final tips = [];

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
              Divider(),
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
        child: tips.isEmpty
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
                      itemCount: tips.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () => _showTipsDetailDialog(
                            tips[index]["tip"],
                            tips[index]["description"],
                            index + 1,
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
                                        color: Colors.pink[500],
                                        size: 40,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Tip #${index + 1}",
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            tips[index]["tip"]!,
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
    );
  }
}
