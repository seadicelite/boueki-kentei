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

    final List<dynamic> q = List.from(data["questions"])..shuffle(Random());

    setState(() {
      questions = q.take(widget.limit).toList();
      isLoading = false;
    });
  }

  void nextQuestion() {
    final q = questions[current];
    final bool correct = q["answer"] == selectedAnswer;

    answers.add({
      "question": q["sentence"] ?? "",
      "selected": selectedAnswer ?? "-",
      "correct": q["answer"],
      "isCorrect": correct,
      "points": correct ? 2.25 : 0.0,
      "explanation": q["explanation"] ?? "",
    });

    if (current < questions.length - 1) {
      setState(() {
        current++;
        selectedAnswer = null;
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
    final String questionText = q["sentence"] ?? "（問題文がありません）";

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

              // 問題文カード
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

              // A / B
              _buildOption("A", q["optionA"] ?? ""),
              const SizedBox(height: 12),
              _buildOption("B", q["optionB"] ?? ""),

              const Spacer(),

              // 次へ
              ElevatedButton(
                onPressed: selectedAnswer == null ? null : nextQuestion,
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

  // -------------------------------------------------------
  // A / B 選択肢ボタン
  // -------------------------------------------------------
  Widget _buildOption(String key, String text) {
    final bool isSelected = selectedAnswer == key;

    return GestureDetector(
      onTap: () => setState(() => selectedAnswer = key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withOpacity(0.25) : cardColor,
          border: Border.all(
            color: isSelected ? accentColor : Colors.white24,
            width: 1.4,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? accentColor : Colors.white54,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "$key. $text",
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
