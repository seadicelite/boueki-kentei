import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';

class MockTradeDai2Screen extends StatefulWidget {
  final String title;
  final String fileName;
  final int limit; // 20問
  final Function(List<Map<String, dynamic>>, double) onComplete;

  const MockTradeDai2Screen({
    super.key,
    required this.title,
    required this.fileName,
    required this.limit,
    required this.onComplete,
  });

  @override
  State<MockTradeDai2Screen> createState() => _MockTradeDai2ScreenState();
}

class _MockTradeDai2ScreenState extends State<MockTradeDai2Screen> {
  List<dynamic> questions = [];
  int current = 0;

  String? selectedAnswer; // "A" or "B"

  List<Map<String, dynamic>> answers = [];

  bool isLoading = true;

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

    List<dynamic> q = List.from(data["questions"]);
    q.shuffle(Random());

    setState(() {
      questions = q.take(widget.limit).toList(); // 20問
      isLoading = false;
    });
  }

  void nextQuestion() {
    final q = questions[current];
    final correct = q["answer"] == selectedAnswer;

    answers.add({
      "question": q["sentence"],
      "selected": selectedAnswer ?? "-",
      "correct": q["answer"],
      "isCorrect": correct,
      "points": correct ? 1.0 : 0.0, // 大問2：1点 × 20問
      "explanation": "",
    });

    if (current < questions.length - 1) {
      setState(() {
        current++;
        selectedAnswer = null;
      });
    } else {
      // 全問終了
      double totalScore = answers.fold(0, (s, a) => s + a["points"]);
      widget.onComplete(answers, totalScore);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

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

          // 問題文
          Text(
            "Q${current + 1}. ${q["sentence"]}",
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),

          // A & B
          _buildOption("A", q["optionA"]),
          const SizedBox(height: 12),
          _buildOption("B", q["optionB"]),

          const Spacer(),

          // 次へボタン
          ElevatedButton(
            onPressed: selectedAnswer == null ? null : nextQuestion,
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

  // -------------------------------------------------------
  // UI：選択肢ボタン（A / B）
  // -------------------------------------------------------
  Widget _buildOption(String key, String text) {
    final bool isSelected = selectedAnswer == key;

    return GestureDetector(
      onTap: () => setState(() => selectedAnswer = key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade100 : Colors.grey.shade200,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade400,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? Colors.blue : Colors.grey,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text("$key. $text", style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
