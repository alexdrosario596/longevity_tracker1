import 'package:flutter/material.dart';
import '../../db/database_helper.dart'; // make sure this path matches your project

class HealthQuestions extends StatefulWidget {
  @override
  _HealthQuestionsState createState() => _HealthQuestionsState();
}

class _HealthQuestionsState extends State<HealthQuestions> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Doctor check-ups
  bool hasCheckups = false;
  String doctorType = "";

  // Medications
  bool takesMeds = false;
  List<Map<String, String>> medications = [];

  // Natural remedies
  bool usesRemedies = false;
  String remedies = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Health Questions")),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildDoctorCheckupPage(),
          _buildMedicationPage(),
          _buildRemediesPage(),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_currentPage > 0)
              ElevatedButton(
                onPressed: () {
                  setState(() => _currentPage--);
                  _pageController.jumpToPage(_currentPage);
                },
                child: const Text("Back"),
              ),
            ElevatedButton(
              onPressed: () async {
                // ✅ Save answers to DB before moving forward
                if (_currentPage == 0) {
                  await DatabaseHelper.instance.insertOnboardingAnswer(
                    "Health",
                    "Do you have Dr. check-ups?",
                    hasCheckups ? "Yes - $doctorType" : "No",
                  );
                } else if (_currentPage == 1) {
                  if (takesMeds) {
                    for (var med in medications) {
                      await DatabaseHelper.instance.insertOnboardingAnswer(
                        "Health",
                        "Medication",
                        "${med["name"]}, ${med["frequency"]}, ${med["feeling"]}",
                      );
                    }
                  } else {
                    await DatabaseHelper.instance.insertOnboardingAnswer(
                      "Health",
                      "Do you take medication?",
                      "No",
                    );
                  }
                } else if (_currentPage == 2) {
                  await DatabaseHelper.instance.insertOnboardingAnswer(
                    "Health",
                    "Do you like natural remedies?",
                    usesRemedies ? "Yes - $remedies" : "No",
                  );
                }

                // ✅ Move forward or finish
                if (_currentPage < 2) {
                  setState(() => _currentPage++);
                  _pageController.jumpToPage(_currentPage);
                } else {
                  Navigator.pop(context); // later → go to VitaminsQuestions
                }
              },
              child: Text(_currentPage < 2 ? "Next" : "Finish"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorCheckupPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Do you have Dr. check-ups?",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Checkbox(
              value: hasCheckups,
              onChanged: (val) {
                setState(() => hasCheckups = val!);
              },
            ),
            const Text("Yes"),
          ],
        ),
        if (hasCheckups)
          TextField(
            decoration: const InputDecoration(
              labelText: "Which Dr. do you visit more often?",
            ),
            onChanged: (val) => doctorType = val,
          ),
      ],
    );
  }

  Widget _buildMedicationPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Do you take medication?",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Checkbox(
              value: takesMeds,
              onChanged: (val) {
                setState(() => takesMeds = val!);
              },
            ),
            const Text("Yes"),
          ],
        ),
        if (takesMeds)
          Column(
            children: [
              ElevatedButton(
                child: const Text("Add Medication"),
                onPressed: () {
                  setState(() {
                    medications.add({
                      "name": "",
                      "frequency": "",
                      "feeling": "",
                    });
                  });
                },
              ),
              ...medications.asMap().entries.map((entry) {
                int index = entry.key;
                return Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(labelText: "Medication name"),
                      onChanged: (val) => medications[index]["name"] = val,
                    ),
                    TextField(
                      decoration: const InputDecoration(labelText: "How often?"),
                      onChanged: (val) => medications[index]["frequency"] = val,
                    ),
                    TextField(
                      decoration: const InputDecoration(labelText: "How do you feel after taking it?"),
                      onChanged: (val) => medications[index]["feeling"] = val,
                    ),
                  ],
                );
              }),
            ],
          ),
      ],
    );
  }

  Widget _buildRemediesPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Do you like natural remedies?",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Checkbox(
              value: usesRemedies,
              onChanged: (val) {
                setState(() => usesRemedies = val!);
              },
            ),
            const Text("Yes"),
          ],
        ),
        if (usesRemedies)
          TextField(
            decoration: const InputDecoration(
              labelText: "Which natural remedies do you use?",
            ),
            onChanged: (val) => remedies = val,
          ),
      ],
    );
  }
}
