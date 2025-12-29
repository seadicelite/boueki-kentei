import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';

class MockTradeDai1Screen extends StatefulWidget {
  final String title;
  final String fileName;
  final int limit; // ← 大問ごとの問題数
  final Function(List<Map<String, dynamic>>, double) onComplete;

  const MockTradeDai1Screen({
    super.key,
    required this.title,
    required this.fileName,
    required this.limit,
    required this.onComplete,
  });

  @override
  State<MockTradeDai1Screen> createState() => _MockTradeDai1ScreenState();
}

class _MockTradeDai1ScreenState extends State<MockTradeDai1Screen> {
  List<dynamic> questions = [];
  int current = 0;

  bool? selected; // true/false
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
      questions = q.take(widget.limit).toList(); // limit の数だけ使用
      isLoading = false;
    });
  }

  void nextQuestion() {
    final q = questions[current];
    final correct = q["answer"] == selected;

    answers.add({
      "question": q["sentence"],
      "selected": selected == null ? "-" : (selected! ? "○" : "×"),
      "correct": q["answer"] ? "○" : "×",
      "isCorrect": correct,
      "points": correct ? 1.0 : 0.0, // 大問1は1点×20問
      "explanation": "", // 模試は解説なし
    });

    if (current < questions.length - 1) {
      setState(() {
        current++;
        selected = null;
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
          Text(
            widget.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          Text(
            "Q${current + 1}. ${q["sentence"]}",
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(child: _selectButton(label: "○ 正しい", value: true)),
              const SizedBox(width: 12),
              Expanded(child: _selectButton(label: "× 誤り", value: false)),
            ],
          ),

          const Spacer(),

          ElevatedButton(
            onPressed: selected == null ? null : nextQuestion,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              backgroundColor: Colors.orange,
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

  Widget _selectButton({required String label, required bool value}) {
    final isSelected = selected == value;

    return GestureDetector(
      onTap: () => setState(() => selected = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade400,
            width: 2,
          ),
        ),
        child: Center(child: Text(label, style: const TextStyle(fontSize: 16))),
      ),
    );
  }
}
