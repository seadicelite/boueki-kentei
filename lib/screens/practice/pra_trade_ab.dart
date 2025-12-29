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

  String? selectedAnswer; // "A" / "B"
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

    Future.delayed(const Duration(milliseconds: 250), () {
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
      appBar: AppBar(title: Text(widget.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            "Q${current + 1}. ${q["sentence"]}",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          // 🔵 A / B ボタン（ABC版UIそのまま！）
          _choiceButton("A", q["optionA"]),
          const SizedBox(height: 12),
          _choiceButton("B", q["optionB"]),

          const SizedBox(height: 30),

          if (showExplanation) _buildExplanation(q),

          const SizedBox(height: 30),

          if (showExplanation)
            ElevatedButton(
              onPressed: nextQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: Text(isLast ? "練習を終了する" : "次の問題へ"),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // 🔵 ABC版UIを 2 択にそのまま流用したボタン
  // ---------------------------------------------------------
  Widget _choiceButton(String key, String text) {
    final isSelected = selectedAnswer == key;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.withOpacity(0.7) : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        boxShadow: isSelected
            ? [BoxShadow(color: Colors.blue.withOpacity(0.5), blurRadius: 12)]
            : [],
      ),
      child: ElevatedButton(
        onPressed: () => onSelect(key),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.black,
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
  // 🔵 ABC版 UI を完全コピーした解説
  // ---------------------------------------------------------
  Widget _buildExplanation(Map<String, dynamic> q) {
    final correct = q["answer"];
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

          const SizedBox(height: 6),

          Text(
            q["explanation"],
            style: const TextStyle(fontSize: 16, height: 1.6),
          ),
        ],
      ),
    );
  }
}
