import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EnglishThreeChoiceScreen extends StatefulWidget {
  final String title;
  final String fileName;
  final int limit;
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
  // =============================
  // ChatGPT風カラー
  // =============================
  static const bgColor = Color(0xFF0F0F0F);
  static const cardColor = Color(0xFF1E1E1E);
  static const accentColor = Color(0xFF10A37F);
  static const textColor = Colors.white;
  static const subTextColor = Colors.grey;

  List<dynamic> questions = [];

  int current = 0;
  bool loading = true;

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

    questions = list.take(widget.limit).toList();
    setState(() => loading = false);
  }

  // =============================
  // 回答処理（即次へ）
  // =============================
  void selectAnswer(String key) {
    final q = questions[current];
    final correctKey = q["answer"];
    final isCorrect = key == correctKey;

    answerLog.add({
      // ResultScreenEigo 対応キー
      "question": q["sentence_en"],
      "sentence": null,
      "selected": "$key. ${q["option${key}_jp"]}",
      "correct": "$correctKey. ${q["option${correctKey}_jp"]}",
      "isCorrect": isCorrect,
      "points": isCorrect ? 2.0 : 0.0,
      "explanation": null,
    });

    if (current + 1 < questions.length) {
      setState(() => current++);
    } else {
      final score = answerLog.fold<double>(0, (s, e) => s + e["points"]);
      widget.onComplete(answerLog, score);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: bgColor,
        body: Center(child: CircularProgressIndicator(color: accentColor)),
      );
    }

    final q = questions[current];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        title: Text(widget.title, style: const TextStyle(color: textColor)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 進捗バー
            LinearProgressIndicator(
              value: (current + 1) / questions.length,
              backgroundColor: Colors.grey[800],
              valueColor: const AlwaysStoppedAnimation(accentColor),
            ),

            const SizedBox(height: 24),

            // 問題カード
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                "Q${current + 1}. ${q["sentence_en"]}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),

            const SizedBox(height: 24),

            _buildChoiceButton("A", q["optionA_jp"]),
            const SizedBox(height: 12),
            _buildChoiceButton("B", q["optionB_jp"]),
            const SizedBox(height: 12),
            _buildChoiceButton("C", q["optionC_jp"]),
          ],
        ),
      ),
    );
  }

  // =============================
  // 3択ボタン（試験モード）
  // =============================
  Widget _buildChoiceButton(String key, String text) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: subTextColor),
      ),
      child: ElevatedButton(
        onPressed: () => selectAnswer(key),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: textColor,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              const Icon(Icons.circle_outlined, color: textColor),
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
}
