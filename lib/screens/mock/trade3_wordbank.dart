import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';

class MockTradeDai3WordbankScreen extends StatefulWidget {
  final String title;
  final String fileName;
  final Function(List<Map<String, dynamic>>, double) onComplete;

  const MockTradeDai3WordbankScreen({
    super.key,
    required this.title,
    required this.fileName,
    required this.onComplete,
  });

  @override
  State<MockTradeDai3WordbankScreen> createState() =>
      _MockTradeDai3WordbankScreenState();
}

class _MockTradeDai3WordbankScreenState
    extends State<MockTradeDai3WordbankScreen> {
  List<dynamic> questions = [];
  int current = 0;

  String? selected1;
  String? selected2;

  bool isLoading = true;
  List<Map<String, dynamic>> answers = [];

  // 🎨 ChatGPT風カラー
  static const bgColor = Color(0xFF0F0F0F);
  static const cardColor = Color(0xFF1E1E1E);
  static const accentColor = Color(0xFF10A37F);

  static const int questionCount = 5; // ★ 常に5問

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

    final qs = List.from(data["questions"])..shuffle(Random());

    setState(() {
      questions = qs.take(questionCount).toList();
      isLoading = false;
    });
  }

  void nextQuestion() {
    final q = questions[current];
    final bool correct = selected1 == q["answer1"] && selected2 == q["answer2"];

    answers.add({
      "question": q["sentence"],
      "selected": "${selected1 ?? '-'} / ${selected2 ?? '-'}",
      "correct": "${q["answer1"]} / ${q["answer2"]}",
      "isCorrect": correct,
      "points": correct ? 3.0 : 0.0,
    });

    if (current < questions.length - 1) {
      setState(() {
        current++;
        selected1 = null;
        selected2 = null;
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
    final List<String> choices = List<String>.from(q["choices"]);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // 問題文
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  "Q${current + 1}. ${q["sentence"]}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    height: 1.6,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 空欄①
              _buildDropdown(
                label: "空欄①",
                value: selected1,
                items: choices,
                onChanged: (v) {
                  setState(() {
                    selected1 = v;
                    if (selected2 == v) selected2 = null;
                  });
                },
              ),

              const SizedBox(height: 16),

              // 空欄②
              _buildDropdown(
                label: "空欄②",
                value: selected2,
                items: choices,
                onChanged: (v) {
                  setState(() {
                    selected2 = v;
                    if (selected1 == v) selected1 = null;
                  });
                },
              ),

              const Spacer(),

              ElevatedButton(
                onPressed: (selected1 == null || selected2 == null)
                    ? null
                    : nextQuestion,
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

  // ----------------------------
  // Dropdown（ダーク対応）
  // ----------------------------
  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          dropdownColor: cardColor,
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(color: Colors.white)),
                ),
              )
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: cardColor,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white24),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: accentColor),
            ),
          ),
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}
