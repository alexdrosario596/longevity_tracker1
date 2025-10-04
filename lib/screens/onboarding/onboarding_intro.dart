import 'package:flutter/material.dart';
import 'health_questions.dart';

class OnboardingIntro extends StatefulWidget {
  @override
  _OnboardingIntroState createState() => _OnboardingIntroState();
}

class _OnboardingIntroState extends State<OnboardingIntro> {
  String goal = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Welcome")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "What would you like this app to help you with?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              decoration: const InputDecoration(
                hintText: "Enter your goal",
              ),
              onChanged: (val) => goal = val,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text("Next"),
              onPressed: () {
                // TODO: Save this to DB if you want
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HealthQuestions()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
