import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:math';

class PracticeTradeABCScreen extends StatefulWidget {
  final String title;
  final String fileName;

  const PracticeTradeABCScreen({
    super.key,
    required this.title,
    required this.fileName,
  });

  @override
  State<PracticeTradeABCScreen> createState() => _PracticeTradeABCScreenState();
}

class _PracticeTradeABCScreenState extends State<PracticeTradeABCScreen> {
  List<dynamic> questions = [];
  int current = 0;
  String? selectedAnswer; // "A" / "B" / "C"
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

  // 🔥 押した瞬間に回答＋解説表示
  void onSelect(String key) {
    if (showExplanation) return;

    setState(() {
      selectedAnswer = key;
      showExplanation = true;
    });

    // 🔥 自動スクロール
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
          // 🔵 問題文
          Text(
            "Q${current + 1}. ${q["sentence"]}",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          // 🔵 A/B/C ボタン
          _buildChoiceButton("A", q["optionA"]),
          const SizedBox(height: 12),
          _buildChoiceButton("B", q["optionB"]),
          const SizedBox(height: 12),
          _buildChoiceButton("C", q["optionC"]),

          const SizedBox(height: 30),

          if (showExplanation) _buildExplanation(q),

          const SizedBox(height: 30),

          // 🔵 次へ
          if (showExplanation)
            ElevatedButton(
              onPressed: isLast ? null : nextQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: Text(isLast ? "終了" : "次の問題へ"),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // 🔥 アニメ付き A/B/C ボタン（丸罰UIを完全コピー）
  // ---------------------------------------------------------
  Widget _buildChoiceButton(String key, String text) {
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
  // 🔥 解説（丸罰UIと同じ）
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
          // ✔ 正誤
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

          // ✔ 解説タイトル + 正解表示
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
