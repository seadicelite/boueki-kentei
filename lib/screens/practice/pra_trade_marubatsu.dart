import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:math';

class PracticeTradeMarubatsuScreen extends StatefulWidget {
  final String title;
  final String fileName;

  const PracticeTradeMarubatsuScreen({
    super.key,
    required this.title,
    required this.fileName,
  });

  @override
  State<PracticeTradeMarubatsuScreen> createState() =>
      _PracticeTradeMarubatsuScreenState();
}

class _PracticeTradeMarubatsuScreenState
    extends State<PracticeTradeMarubatsuScreen> {
  List questions = [];
  int currentIndex = 0;

  bool answered = false;
  bool? selectedAnswer;
  final explanationKey = GlobalKey();

  // 🎨 ChatGPT風カラー
  static const bgColor = Color(0xFF0F0F0F);
  static const cardColor = Color(0xFF1E1E1E);
  static const accentColor = Color(0xFF10A37F);

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    final jsonString = await rootBundle.loadString(widget.fileName);
    final data = jsonDecode(jsonString);

    List list = List.from(data["questions"]);
    list.shuffle(Random());

    setState(() {
      questions = list;
    });
  }

  bool get isLast => currentIndex == questions.length - 1;

  void nextQuestion() {
    if (!isLast) {
      setState(() {
        currentIndex++;
        answered = false;
        selectedAnswer = null;
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
                currentIndex = 0;
                answered = false;
                selectedAnswer = null;
              });
            },
            child: const Text("もう一度"),
          ),
        ],
      ),
    );
  }

  // -----------------------------
  // ○ × ボタン（ChatGPT風）
  // -----------------------------
  Widget answerButton({required bool value, required String label}) {
    final isSelected = selectedAnswer == value;

    Color bg;
    if (!answered) {
      bg = isSelected ? accentColor : cardColor;
    } else if (value == questions[currentIndex]["answer"]) {
      bg = Colors.green.shade700;
    } else if (isSelected) {
      bg = Colors.red.shade700;
    } else {
      bg = cardColor;
    }

    return GestureDetector(
      onTap: answered
          ? null
          : () {
              setState(() {
                selectedAnswer = value;
                answered = true;
              });

              Future.delayed(const Duration(milliseconds: 300), () {
                if (explanationKey.currentContext != null) {
                  Scrollable.ensureVisible(
                    explanationKey.currentContext!,
                    duration: const Duration(milliseconds: 400),
                  );
                }
              });
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return const Scaffold(
        backgroundColor: bgColor,
        body: Center(child: CircularProgressIndicator(color: accentColor)),
      );
    }

    final q = questions[currentIndex];

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
                "Q${currentIndex + 1}. ${q["question"]}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ○ × ボタン
          Row(
            children: [
              Expanded(child: answerButton(value: true, label: "○ 正しい")),
              const SizedBox(width: 12),
              Expanded(child: answerButton(value: false, label: "× 誤り")),
            ],
          ),

          const SizedBox(height: 32),

          if (answered) _buildExplanation(q),

          if (answered) ...[
            const SizedBox(height: 32),
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
        ],
      ),
    );
  }

  // -----------------------------
  // 📖 解説エリア
  // -----------------------------
  Widget _buildExplanation(Map q) {
    final bool isCorrect = q["answer"] == selectedAnswer;

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
            q["answer"] ? "（正解：○）" : "（正解：×）",
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
