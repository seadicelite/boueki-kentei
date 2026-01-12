import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';

class MockTradeDai1Screen extends StatefulWidget {
  final String title;
  final String fileName;
  final int limit;
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

  bool? selected; // true / false
  List<Map<String, dynamic>> answers = [];
  bool isLoading = true;

  // 🎨 ChatGPT風カラー
  static const bgColor = Color(0xFF0F0F0F);
  static const cardColor = Color(0xFF1E1E1E);
  static const accentColor = Color(0xFF10A37F);

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
      questions = q.take(widget.limit).toList();
      isLoading = false;
    });
  }

  void nextQuestion() {
    final q = questions[current];
    final correct = q["answer"] == selected;

    answers.add({
      "question": q["question"] ?? "",
      "selected": selected == null ? "-" : (selected! ? "○" : "×"),
      "correct": q["answer"] ? "○" : "×",
      "isCorrect": correct,
      "points": correct ? 1.5 : 0.0,
    });

    if (current < questions.length - 1) {
      setState(() {
        current++;
        selected = null;
      });
    } else {
      final totalScore = answers.fold<double>(0, (s, a) => s + a["points"]);
      widget.onComplete(answers, totalScore);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: bgColor,

        body: Center(child: CircularProgressIndicator()),
      );
    }

    final q = questions[current];
    final questionText = q["question"] ?? "（問題文がありません）";

    return Scaffold(
      backgroundColor: bgColor,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // タイトル
              Text(
                widget.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // 問題カード
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  "Q${current + 1}. $questionText",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ○ × ボタン
              Row(
                children: [
                  Expanded(child: _selectButton(label: "○ 正しい", value: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _selectButton(label: "× 誤り", value: false)),
                ],
              ),

              const Spacer(),

              // 次へ
              ElevatedButton(
                onPressed: selected == null ? null : nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  current == questions.length - 1 ? "結果へ" : "次へ",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===============================
  // ○ × 選択ボタン
  // ===============================
  Widget _selectButton({required String label, required bool value}) {
    final isSelected = selected == value;

    return GestureDetector(
      onTap: () => setState(() => selected = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withOpacity(0.25) : cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? accentColor : Colors.white24,
            width: 1.4,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
