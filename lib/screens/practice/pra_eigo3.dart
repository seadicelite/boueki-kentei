import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PracticeEigoImageABCScreen extends StatefulWidget {
  final String title;
  final String fileName;

  const PracticeEigoImageABCScreen({
    super.key,
    required this.title,
    required this.fileName,
  });

  @override
  State<PracticeEigoImageABCScreen> createState() =>
      _PracticeEigoImageABCScreenState();
}

class _PracticeEigoImageABCScreenState
    extends State<PracticeEigoImageABCScreen> {
  Map<String, dynamic>? data;
  List<dynamic> questions = [];
  List<String?> userAnswers = [];
  String? imagePath;

  bool showResult = false;

  @override
  void initState() {
    super.initState();
    loadJson();
  }

  Future<void> loadJson() async {
    final jsonString = await rootBundle.loadString(widget.fileName);
    final decoded = json.decode(jsonString);

    setState(() {
      data = decoded;
      imagePath = decoded["image"];
      questions = decoded["questions"];
      userAnswers = List<String?>.filled(questions.length, null);
    });
  }

  void checkResults() {
    setState(() {
      showResult = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🔵 画像を一度だけ表示
          if (imagePath != null && imagePath!.isNotEmpty)
            Image.asset(imagePath!, height: 200, fit: BoxFit.contain),

          const SizedBox(height: 20),

          // 🔶 質問を2つループ表示
          ...List.generate(questions.length, (index) {
            final q = questions[index];

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Q${index + 1}. ${q["sentence"]}",
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 🔵 A/B/C ボタン
                    Column(
                      children: [
                        _choiceButton(index, "A", q["A"]),
                        const SizedBox(height: 8),
                        _choiceButton(index, "B", q["B"]),
                        const SizedBox(height: 8),
                        _choiceButton(index, "C", q["C"]),
                      ],
                    ),

                    // 🔥 解説
                    if (showResult)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          userAnswers[index] == q["answer"]
                              ? "✅ 正解！ ${q["explanation"]}"
                              : "❌ 不正解… 正解は ${q["answer"]}：${q["explanation"]}",
                          style: TextStyle(
                            color: userAnswers[index] == q["answer"]
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: checkResults,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text("答え合わせ"),
          ),
        ],
      ),
    );
  }

  // -----------------------------
  // 🔵 ABC選択肢ボタン
  // -----------------------------
  Widget _choiceButton(int index, String key, String text) {
    final isSelected = userAnswers[index] == key;

    return InkWell(
      onTap: showResult
          ? null
          : () {
              setState(() {
                userAnswers[index] = key;
              });
            },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Text("$key. $text", style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
