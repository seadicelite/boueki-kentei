import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:math';

class EnglishThreeChoiceScreen extends StatefulWidget {
  final String title;
  final String fileName;

  const EnglishThreeChoiceScreen({
    super.key,
    required this.title,
    required this.fileName,
  });

  @override
  State<EnglishThreeChoiceScreen> createState() =>
      _EnglishThreeChoiceScreenState();
}

class _EnglishThreeChoiceScreenState extends State<EnglishThreeChoiceScreen> {
  List<dynamic> questions = [];
  int current = 0;
  String? selectedAnswer; // A/B/C
  bool showExplanation = false;
  bool isLoading = true;

  final explanationKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    loadJson();
  }

  Future<void> loadJson() async {
    final jsonString = await rootBundle.loadString(widget.fileName);
    final data = jsonDecode(jsonString);

    List<dynamic> list = List.from(data["questions"]);
    list.shuffle(Random()); // 🔥 全問シャッフル

    setState(() {
      questions = list;
      isLoading = false;
    });
  }

  void onSelect(String key) {
    if (showExplanation) return;

    setState(() {
      selectedAnswer = key;
      showExplanation = true;
    });

    // 🔥 解説へ自動スクロール
    Future.delayed(const Duration(milliseconds: 250), () {
      Scrollable.ensureVisible(
        explanationKey.currentContext!,
        duration: const Duration(milliseconds: 400),
      );
    });
  }

  void nextQuestion() {
    setState(() {
      current++;
      selectedAnswer = null;
      showExplanation = false;
    });
  }

  bool get isLast => current == questions.length - 1;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final q = questions[current];

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🔵 英文問題文
          Text(
            "Q${current + 1}. ${q["sentence_en"]}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          // 🔵 3択
          _buildChoice("A", q["optionA_en"]),
          const SizedBox(height: 12),
          _buildChoice("B", q["optionB_en"]),
          const SizedBox(height: 12),
          _buildChoice("C", q["optionC_en"]),

          const SizedBox(height: 30),

          if (showExplanation) _buildExplanation(q),

          const SizedBox(height: 30),

          if (showExplanation)
            ElevatedButton(
              onPressed: isLast ? null : nextQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: Text(isLast ? "Finish" : "Next Question"),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // 🔥 3択ボタン（丸罰UI）
  // ---------------------------------------------------------
  Widget _buildChoice(String key, String text) {
    final isSelected = selectedAnswer == key;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.withOpacity(0.7) : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        boxShadow: isSelected
            ? [BoxShadow(color: Colors.blue.withOpacity(0.4), blurRadius: 12)]
            : [],
      ),
      child: ElevatedButton(
        onPressed: () => onSelect(key),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.circle : Icons.circle_outlined,
                color: isSelected ? Colors.white : Colors.grey,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "$key. $text",
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // 🔥 解説（丸罰UI）
  // ---------------------------------------------------------
  Widget _buildExplanation(Map<String, dynamic> q) {
    final correct = q["answer"]; // "A" / "B" / "C"
    final isCorrect = selectedAnswer == correct;

    return Container(
      key: explanationKey,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 正誤
          Row(
            children: [
              Icon(
                isCorrect ? Icons.circle : Icons.close,
                color: isCorrect ? Colors.green : Colors.red,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect ? "Correct!" : "Wrong...",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isCorrect ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              const Text(
                "Explanation：",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                "(Correct Answer：$correct)",
                style: const TextStyle(fontSize: 16, color: Colors.blue),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            q["explanation_en"],
            style: const TextStyle(fontSize: 16, height: 1.6),
          ),
        ],
      ),
    );
  }
}
