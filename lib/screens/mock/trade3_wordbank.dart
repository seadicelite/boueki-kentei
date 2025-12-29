import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';

class MockTradeDai3WordbankScreen extends StatefulWidget {
  final String title;
  final String fileName;
  final int limit; // 10問
  final Function(List<Map<String, dynamic>>, double) onComplete;

  const MockTradeDai3WordbankScreen({
    super.key,
    required this.title,
    required this.fileName,
    required this.limit,
    required this.onComplete,
  });

  @override
  State<MockTradeDai3WordbankScreen> createState() =>
      _MockTradeDai3WordbankScreenState();
}

class _MockTradeDai3WordbankScreenState
    extends State<MockTradeDai3WordbankScreen> {
  List<dynamic> questions = [];
  List<String> wordbank = [];

  int current = 0;
  String? selectedWord;

  bool isLoading = true;
  List<Map<String, dynamic>> answers = [];

  @override
  void initState() {
    super.initState();
    loadJson();
  }

  Future<void> loadJson() async {
    final jsonString = await DefaultAssetBundle.of(
      context,
    ).loadString(widget.fileName);
    final data = jsonDecode(jsonString);

    List<dynamic> qs = List.from(data["questions"]);
    List<String> wb = List<String>.from(data["wordbank"]);

    qs.shuffle(Random());
    wb.shuffle(Random());

    setState(() {
      questions = qs.take(widget.limit).toList(); // 10問
      wordbank = wb.take(20).toList(); // 語群20個
      isLoading = false;
    });
  }

  void nextQuestion() {
    final q = questions[current];
    final correct = selectedWord == q["answer"];

    answers.add({
      "question": q["sentence"].replaceAll("___", "_____"),
      "selected": selectedWord ?? "-",
      "correct": q["answer"],
      "isCorrect": correct,
      "points": correct ? 1.0 : 0.0, // 1問1点 × 10問
      "explanation": "",
    });

    if (current < questions.length - 1) {
      setState(() {
        current++;
        selectedWord = null;
      });
    } else {
      double totalScore = answers.fold(0, (s, a) => s + a["points"]);
      widget.onComplete(answers, totalScore);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    final q = questions[current];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // タイトル
          Text(
            widget.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // 問題文（穴埋め表示）
          Text(
            "Q${current + 1}. ${q["sentence"].replaceAll("___", "_____")}",
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 12),

          // 選んだ単語を表示
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              selectedWord == null ? "選択：なし" : "あなたの選択：$selectedWord",
              style: const TextStyle(fontSize: 16),
            ),
          ),

          const SizedBox(height: 20),

          // 語群一覧（20個）
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: wordbank.map((w) {
                final bool isSelected = selectedWord == w;

                return GestureDetector(
                  onTap: () => setState(() => selectedWord = w),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.orange.shade100
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Colors.orange
                            : Colors.grey.shade400,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        w,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 10),

          // 次へボタン
          ElevatedButton(
            onPressed: selectedWord == null ? null : nextQuestion,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              minimumSize: const Size(double.infinity, 52),
            ),
            child: Text(
              (current == questions.length - 1) ? "結果へ" : "次へ",
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
