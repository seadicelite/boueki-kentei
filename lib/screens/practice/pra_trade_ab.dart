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
        title: const Text("終了"),
        content: const Text("すべての問題を解きました。"),
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final q = questions[current];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.blueGrey.shade900,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --------------------
          // 📘 問題カード
          // --------------------
          Card(
            elevation: 4,
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
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // --------------------
          // A / B ボタン
          // --------------------
          _choiceButton("A", q["optionA"]),
          const SizedBox(height: 12),
          _choiceButton("B", q["optionB"]),

          const SizedBox(height: 32),

          if (showExplanation) _buildExplanation(q),

          const SizedBox(height: 32),

          if (showExplanation)
            ElevatedButton(
              onPressed: nextQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
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

  // --------------------
  // 🎯 選択ボタン（統一カラー）
  // --------------------
  Widget _choiceButton(String key, String text) {
    final isSelected = selectedAnswer == key;

    return GestureDetector(
      onTap: () => onSelect(key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isSelected ? Colors.blue.withOpacity(0.4) : Colors.black12,
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? Colors.white : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "$key. $text",
                style: TextStyle(
                  fontSize: 16,
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------
  // 📖 解説エリア
  // --------------------
  Widget _buildExplanation(Map<String, dynamic> q) {
    final correct = q["answer"];
    final isCorrect = selectedAnswer == correct;

    return Container(
      key: explanationKey,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
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

          const SizedBox(height: 16),

          Row(
            children: [
              const Text(
                "【解説】",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Text(
                "（正解：$correct）",
                style: const TextStyle(fontSize: 16, color: Colors.blue),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            q["explanation"],
            style: const TextStyle(fontSize: 16, height: 1.8),
          ),
        ],
      ),
    );
  }
}
