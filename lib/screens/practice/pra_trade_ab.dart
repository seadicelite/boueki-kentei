import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:math';

class PracticeTradeABScreen extends StatefulWidget {
  final String title;
  final String fileName;

  const PracticeTradeABScreen({
    super.key,
    required this.title,
    required this.fileName,
  });

  @override
  State<PracticeTradeABScreen> createState() => _PracticeTradeABScreenState();
}

class _PracticeTradeABScreenState extends State<PracticeTradeABScreen> {
  List<dynamic> questions = [];
  int current = 0;

  String? selectedAnswer;
  bool showExplanation = false;
  bool isLoading = true;

  final explanationKey = GlobalKey();

  // 🎨 ChatGPT風カラー定義
  static const bgColor = Color(0xFF0F0F0F);
  static const cardColor = Color(0xFF1E1E1E);
  static const accentColor = Color(0xFF10A37F);

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

    Future.delayed(const Duration(milliseconds: 300), () {
      if (explanationKey.currentContext != null) {
        Scrollable.ensureVisible(
          explanationKey.currentContext!,
          duration: const Duration(milliseconds: 400),
        );
      }
    });
  }

  void nextQuestion() {
    if (current + 1 < questions.length) {
      setState(() {
        current++;
        selectedAnswer = null;
        showExplanation = false;
      });
    } else {
      showEndDialog();
    }
  }

  void showEndDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cardColor,
        title: const Text("終了", style: TextStyle(color: Colors.white)),
        content: const Text(
          "すべての問題を解きました。",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("閉じる"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                current = 0;
                selectedAnswer = null;
                showExplanation = false;
              });
            },
            child: const Text("もう一度"),
          ),
        ],
      ),
    );
  }

  bool get isLast => current == questions.length - 1;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: bgColor,
        body: Center(child: CircularProgressIndicator(color: accentColor)),
      );
    }

    final q = questions[current];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: bgColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 📘 問題カード
          Card(
            color: cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "Q${current + 1}. ${q["sentence"]}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  height: 1.5,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          _choiceButton("A", q["optionA"], q["answer"]),
          const SizedBox(height: 12),
          _choiceButton("B", q["optionB"], q["answer"]),

          const SizedBox(height: 32),

          if (showExplanation) _buildExplanation(q),

          const SizedBox(height: 32),

          if (showExplanation)
            ElevatedButton(
              onPressed: nextQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                isLast ? "練習を終了する" : "次の問題へ",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 🎯 選択ボタン
  Widget _choiceButton(String key, String text, String correct) {
    final isSelected = selectedAnswer == key;

    Color bg;
    if (!showExplanation) {
      bg = isSelected ? accentColor : cardColor;
    } else if (key == correct) {
      bg = Colors.green.shade700;
    } else if (isSelected) {
      bg = Colors.red.shade700;
    } else {
      bg = cardColor;
    }

    return GestureDetector(
      onTap: () => onSelect(key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: Colors.white70,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "$key. $text",
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📖 解説エリア
  Widget _buildExplanation(Map<String, dynamic> q) {
    final correct = q["answer"];
    final isCorrect = selectedAnswer == correct;

    return Container(
      key: explanationKey,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isCorrect ? Colors.green : Colors.red),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? Colors.green : Colors.red,
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
            "【解説】（正解：$correct）",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            q["explanation"],
            style: const TextStyle(
              fontSize: 16,
              height: 1.8,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
