import 'package:flutter/material.dart';

class TipCard extends StatelessWidget {
  final String title;
  final String imgName;
  const TipCard({super.key, required this.title, required this.imgName});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: MediaQuery.of(context).size.width * 0.9,
        width: MediaQuery.of(context).size.width * 0.9,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(children: [
              Text(
                title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Image(
                image: AssetImage(imgName),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
