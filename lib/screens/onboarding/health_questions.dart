import 'package:flutter/material.dart';
import '../../db/database_helper.dart'; // adjust if needed

class HealthQuestions extends StatefulWidget {
  @override
  _HealthQuestionsState createState() => _HealthQuestionsState();
}

class _HealthQuestionsState extends State<HealthQuestions> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Doctor check-ups
  bool? hasCheckups;
  String doctorType = "";

  // Medications
  bool? takesMeds;
  List<Map<String, String>> medications = [];

  // Natural remedies
  bool? usesRemedies;
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
                // Save answers before moving forward
                if (_currentPage == 0) {
                  await DatabaseHelper.instance.insertOnboardingAnswer(
                    "Health",
                    "Do you have Dr. check-ups?",
                    hasCheckups == true ? "Yes - $doctorType" : "No",
                  );
                } else if (_currentPage == 1) {
                  if (takesMeds == true) {
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
                    usesRemedies == true ? "Yes - $remedies" : "No",
                  );
                }

                // Navigate forward
                if (_currentPage < 2) {
                  setState(() => _currentPage++);
                  _pageController.jumpToPage(_currentPage);
                } else {
                  Navigator.pop(context); // Later: go to VitaminsQuestions
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
              value: hasCheckups == true,
              onChanged: (val) {
                setState(() => hasCheckups = true);
              },
            ),
            const Text("Yes"),
            const SizedBox(width: 20),
            Checkbox(
              value: hasCheckups == false,
              onChanged: (val) {
                setState(() => hasCheckups = false);
              },
            ),
            const Text("No"),
          ],
        ),
        if (hasCheckups == true)
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
              value: takesMeds == true,
              onChanged: (val) {
                setState(() => takesMeds = true);
              },
            ),
            const Text("Yes"),
            const SizedBox(width: 20),
            Checkbox(
              value: takesMeds == false,
              onChanged: (val) {
                setState(() => takesMeds = false);
              },
            ),
            const Text("No"),
          ],
        ),
        if (takesMeds == true)
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
                      decoration:
                      const InputDecoration(labelText: "Medication name"),
                      onChanged: (val) => medications[index]["name"] = val,
                    ),
                    TextField(
                      decoration:
                      const InputDecoration(labelText: "How often?"),
                      onChanged: (val) => medications[index]["frequency"] = val,
                    ),
                    TextField(
                      decoration: const InputDecoration(
                          labelText: "How do you feel after taking it?"),
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
              value: usesRemedies == true,
              onChanged: (val) {
                setState(() => usesRemedies = true);
              },
            ),
            const Text("Yes"),
            const SizedBox(width: 20),
            Checkbox(
              value: usesRemedies == false,
              onChanged: (val) {
                setState(() => usesRemedies = false);
              },
            ),
            const Text("No"),
          ],
        ),
        if (usesRemedies == true)
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
