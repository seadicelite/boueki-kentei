import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';

class MockTradeDai4ABCScreen extends StatefulWidget {
  final String title;
  final String fileName;
  final int limit; // ← 15問
  final Function(List<Map<String, dynamic>>, double) onComplete;

  const MockTradeDai4ABCScreen({
    super.key,
    required this.title,
    required this.fileName,
    required this.limit,
    required this.onComplete,
  });

  @override
  State<MockTradeDai4ABCScreen> createState() => _MockTradeDai4ABCScreenState();
}

class _MockTradeDai4ABCScreenState extends State<MockTradeDai4ABCScreen> {
  List<dynamic> questions = [];
  int current = 0;
  String? selected;
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

    List<dynamic> q = List.from(data["questions"]);
    q.shuffle(Random());

    setState(() {
      questions = q.take(widget.limit).toList(); // ← 15問だけ使う
      isLoading = false;
    });
  }

  /// 次の問題へ進む or 結果を返す
  void nextQuestion() {
    final q = questions[current];
    final bool correct = selected == q["answer"];

    answers.add({
      "question": q["sentence"],
      "selected": selected ?? "-",
      "correct": q["answer"],
      "isCorrect": correct,
      "points": correct ? 1.0 : 0.0, // ← 1問1点
      "explanation": "", // 模試では不要
    });

    if (current < questions.length - 1) {
      setState(() {
        current++;
        selected = null;
      });
    } else {
      // 終了 → Runnerへ返す
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
          // 🔵 タイトル
          Text(
            widget.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // 🔵 問題文
          Text(
            "Q${current + 1}. ${q["sentence"]}",
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 20),

          // 🔵 選択肢 A / B / C
          _option("A", q["optionA"]),
          const SizedBox(height: 12),
          _option("B", q["optionB"]),
          const SizedBox(height: 12),
          _option("C", q["optionC"]),

          const Spacer(),

          // 🔵 次へボタン / 結果へ
          ElevatedButton(
            onPressed: selected == null ? null : nextQuestion,
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

  /// 選択肢ボタンUI
  Widget _option(String key, String text) {
    final bool isSelected = selected == key;

    return GestureDetector(
      onTap: () => setState(() => selected = key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade400,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? Colors.blue : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text("$key. $text", style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
