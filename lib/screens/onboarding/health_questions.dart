import 'package:flutter/material.dart';
import '../../db/database_helper.dart'; // adjust path if needed

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
      body: Column(
        children: [
          // Page content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                _buildDoctorCheckupPage(),
                _buildMedicationPage(),
                _buildRemediesPage(),
              ],
            ),
          ),

          // Navigation row
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage >= 0)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.arrow_back),
                      label: const Text("Back"),
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ElevatedButton.icon(
                    icon: Icon(
                        _currentPage < 2 ? Icons.arrow_forward : Icons.check),
                    label: Text(_currentPage < 2 ? "Next" : "Finish"),
                    onPressed: () async {
                      await _saveAnswerForPage();
                      if (_currentPage < 2) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        Navigator.pop(context); // Later → go to next category
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ Saves the answer for the current page
  Future<void> _saveAnswerForPage() async {
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
  }

  Widget _buildDoctorCheckupPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
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
      ),
    );
  }

  Widget _buildMedicationPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Medication ${index + 1}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                decoration: const InputDecoration(
                                    labelText: "Medication name"),
                                onChanged: (val) =>
                                medications[index]["name"] = val,
                              ),
                              TextField(
                                decoration: const InputDecoration(
                                    labelText: "How often?"),
                                onChanged: (val) =>
                                medications[index]["frequency"] = val,
                              ),
                              TextField(
                                decoration: const InputDecoration(
                                    labelText:
                                    "How do you feel after taking it?"),
                                onChanged: (val) =>
                                medications[index]["feeling"] = val,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(), // ✅ important: close the map() and convert to list
                ],
              ),
          ],
        ),
      ),
    );
  }


  Widget _buildRemediesPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
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
      ),
    );
  }
}
