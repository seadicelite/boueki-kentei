import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EnglishThreeChoiceScreen extends StatefulWidget {
  final String title;
  final String fileName;
  final int limit; // ランダム出題数（10）
  final Function(List<Map<String, dynamic>>, double) onComplete;

  const EnglishThreeChoiceScreen({
    super.key,
    required this.title,
    required this.fileName,
    required this.limit,
    required this.onComplete,
  });

  @override
  State<EnglishThreeChoiceScreen> createState() =>
      _EnglishThreeChoiceScreenState();
}

class _EnglishThreeChoiceScreenState extends State<EnglishThreeChoiceScreen> {
  List<dynamic> questions = [];

  int current = 0;
  bool loading = true;

  String? selected;
  bool showExplanation = false;

  final List<Map<String, dynamic>> answerLog = [];

  @override
  void initState() {
    super.initState();
    loadJson();
  }

  Future<void> loadJson() async {
    final jsonString = await rootBundle.loadString(widget.fileName);
    final data = jsonDecode(jsonString);

    List<dynamic> list = List.from(data["questions"]);
    list.shuffle(Random());

    // ランダムで10問
    questions = list.take(widget.limit).toList();

    setState(() => loading = false);
  }

  void selectAnswer(String key) {
    if (showExplanation) return;

    final q = questions[current];
    final correct = q["answer"];
    final isCorrect = (key == correct);

    selected = key;
    showExplanation = true;

    answerLog.add({
      "sentence": q["sentence"],
      "user": key,
      "correct": isCorrect,
      "points": isCorrect ? 1.0 : 0.0,
      "correctAnswer": correct,
      "options": {"A": q["A"], "B": q["B"], "C": q["C"]},
      "explanation": q["explanation"],
    });

    setState(() {});
  }

  void next() {
    if (current + 1 < questions.length) {
      setState(() {
        current++;
        selected = null;
        showExplanation = false;
      });
    } else {
      // 大問終了
      final score = answerLog.fold<double>(0, (s, e) => s + e["points"]);
      widget.onComplete(answerLog, score);
    }
  }

  bool get isLast => current == questions.length - 1;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final q = questions[current];

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔵 問題文
              Text(
                "Q${current + 1}. ${q["sentence"]}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 24),

              _buildChoiceButton("A", q["A"]),
              const SizedBox(height: 12),
              _buildChoiceButton("B", q["B"]),
              const SizedBox(height: 12),
              _buildChoiceButton("C", q["C"]),

              const SizedBox(height: 30),

              if (showExplanation) _buildExplanation(q),
              if (showExplanation) const SizedBox(height: 16),

              if (showExplanation)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  onPressed: next,
                  child: Text(isLast ? "大問を終了する" : "次の問題へ"),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // 🔵 3択ボタン
  // ---------------------------------------------------------
  Widget _buildChoiceButton(String key, String text) {
    final isSelected = selected == key;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blueAccent : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton(
        onPressed: () => selectAnswer(key),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: isSelected ? Colors.white : Colors.black,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.radio_button_checked : Icons.circle_outlined,
                color: isSelected ? Colors.white : Colors.grey,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "$key. $text",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // 🔵 解説
  // ---------------------------------------------------------
  Widget _buildExplanation(Map<String, dynamic> q) {
    final correct = q["answer"];
    final isCorrect = selected == correct;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.circle : Icons.close,
                color: isCorrect ? Colors.green : Colors.red,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect ? "正解！" : "不正解…",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isCorrect ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            "正解：$correct → ${q[correct]}",
            style: const TextStyle(fontSize: 16, color: Colors.blue),
          ),

          const SizedBox(height: 8),

          Text(
            q["explanation"],
            style: const TextStyle(fontSize: 16, height: 1.6),
          ),
        ],
      ),
    );
  }
}
