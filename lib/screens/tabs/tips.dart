import 'package:flutter/material.dart';

class TipScreen extends StatefulWidget {
  const TipScreen({super.key});

  @override
  State<TipScreen> createState() => _TipScreenState();
}

class _TipScreenState extends State<TipScreen> {
  final tips = [
    {
      "tip": "Be Prepared",
      "description":
          "Always keep a few sanitary pads or tampons in your backpack or purse."
    },
    {
      "tip": "Learn About Menstrual Products",
      "description":
          "Explore different types of menstrual products and find what works best for you."
    },
    {
      "tip": "Track Your Menstrual Cycle",
      "description":
          "Use a period tracker app or calendar to keep track of your menstrual cycle."
    },
    {
      "tip": "Stay Hygienic",
      "description":
          "Change your sanitary products regularly to maintain good hygiene."
    },
    {
      "tip": "Pain Relief",
      "description":
          "Consider taking over-the-counter pain relievers like ibuprofen for menstrual cramps."
    },
    {
      "tip": "Stay Active",
      "description":
          "Exercise can help alleviate menstrual cramps and improve your overall mood."
    },
    {
      "tip": "Stay Hydrated",
      "description":
          "Drink plenty of water to help with bloating and overall well-being."
    },
    {
      "tip": "Healthy Diet",
      "description":
          "Consume a balanced diet with plenty of fruits, vegetables, and whole grains."
    },
    {
      "tip": "Comfortable Clothing",
      "description":
          "Wear comfortable, loose-fitting clothes during your period."
    },
    {
      "tip": "Communication",
      "description":
          "Talk to a trusted adult, friend, or family member about your experiences and concerns."
    },
    {
      "tip": "Educate Yourself",
      "description":
          "Learn about the menstrual cycle, reproductive health, and menstrual hygiene."
    },
    {
      "tip": "Know Signs of Abnormalities",
      "description":
          "Be aware of signs of abnormal menstrual cycles and consult a healthcare professional if concerned."
    },
    {
      "tip": "Mindful Rest",
      "description":
          "Allow yourself some rest and relaxation during your period."
    },
    {
      "tip": "Stay Positive",
      "description":
          "Don't let your period interfere with your self-esteem; it's a natural part of being a woman."
    },
    {
      "tip": "Carry Extra Supplies",
      "description":
          "Always carry extra sanitary products in case of emergencies or to help a friend."
    },
    {
      "tip": "Discreet Disposal",
      "description": "Learn proper disposal methods for used sanitary products."
    },
    {
      "tip": "Heating Pads",
      "description":
          "Consider using a heating pad for soothing relief from menstrual cramps."
    },
    {
      "tip": "Understand PMS",
      "description":
          "Recognize premenstrual syndrome (PMS) symptoms and find strategies to manage them."
    },
    {
      "tip": "Emotional Well-being",
      "description":
          "Pay attention to your emotional well-being and practice self-care during your period."
    },
    {
      "tip": "Seek Guidance",
      "description":
          "If you have questions or concerns, seek guidance from a healthcare professional or school nurse."
    },
    {
      "tip": "Be Patient with Your Body",
      "description":
          "Understand that your menstrual cycle may take time to regulate."
    },
    {
      "tip": "Be Eco-Friendly",
      "description":
          "Consider environmentally friendly menstrual products, such as reusable cloth pads or menstrual cups."
    },
    {
      "tip": "Plan Ahead for Outings",
      "description":
          "Wear comfortable clothing and bring extra supplies if you have plans during your period."
    },
    {
      "tip": "Yoga and Stretching",
      "description":
          "Gentle yoga or stretching exercises can help alleviate tension and discomfort."
    },
    {
      "tip": "Stay Informed About Reproductive Health",
      "description":
          "Learn about reproductive health, contraception, and safe practices."
    },
    {
      "tip": "Keep a Personal Diary",
      "description":
          "Maintain a diary to track your emotions, physical symptoms, and menstrual cycle patterns."
    },
    {
      "tip": "Know When to Seek Help",
      "description":
          "If you experience severe pain or concerning symptoms, consult a healthcare professional promptly."
    },
    {
      "tip": "Connect with Peers",
      "description":
          "Talk to friends who have already experienced menstruation for additional support and advice."
    },
    {
      "tip": "Celebrate Milestones",
      "description":
          "Celebrate each milestone in your menstrual journey as a positive step toward adulthood."
    },
    {
      "tip": "Be Kind to Yourself",
      "description":
          "Menstruation is a natural part of life; be kind to yourself and take things at your own pace."
    }
  ];

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
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: Colors.pink[900],
          foregroundColor: Colors.white,
          child: const Icon(Icons.favorite),
        ));
  }
}
