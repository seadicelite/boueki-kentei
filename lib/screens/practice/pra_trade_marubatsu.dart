import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:boueki_kentei/core/colors.dart';

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

  // -----------------------------
  // 🔀 問題ランダム化
  // -----------------------------
  List<dynamic> shuffleQuestions(List<dynamic> list) {
    final random = Random();
    final newList = List<dynamic>.from(list);
    newList.shuffle(random);
    return newList;
  }

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    final jsonString = await rootBundle.loadString(widget.fileName);
    final data = json.decode(jsonString);

    setState(() {
      questions = shuffleQuestions(data["questions"]);
    });
  }

  // -----------------------------
  // ○×ボタン（UI改善版）
  // -----------------------------
  Widget answerButton({
    required bool value,
    required String label,
    required Color activeColor,
  }) {
    final isSelected = selectedAnswer == value;

    return GestureDetector(
      onTap: answered
          ? null
          : () {
              setState(() {
                selectedAnswer = value;
                answered = true;
              });

              Future.delayed(const Duration(milliseconds: 300), () {
                Scrollable.ensureVisible(
                  explanationKey.currentContext!,
                  duration: const Duration(milliseconds: 400),
                );
              });
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.5),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final q = questions[currentIndex];

    return Scaffold(
      backgroundColor: sc.back,
      appBar: AppBar(
        title: Text(widget.title, style: TextStyle(color: sc.text)),
        backgroundColor: sc.appbar,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // -----------------------------
          // 📘 問題カード
          // -----------------------------
          Card(
            color: sc.card,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "Q${currentIndex + 1}. ${q["question"]}",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: sc.text,
                  height: 1.5,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // -----------------------------
          // ○ × ボタン
          // -----------------------------
          Row(
            children: [
              Expanded(
                child: answerButton(
                  value: true,

                  label: "○ 正しい",
                  activeColor: Colors.grey,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: answerButton(
                  value: false,
                  label: "× 誤り",

                  activeColor: Colors.grey,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          if (answered) _buildExplanation(q),
        ],
      ),
    );
  }

  // -----------------------------
  // 📖 解説エリア
  // -----------------------------
  Widget _buildExplanation(Map q) {
    final bool isCorrect = q["answer"] == selectedAnswer;

    return Column(
      key: explanationKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 正解・不正解表示
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isCorrect
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
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
        ),

        const SizedBox(height: 24),

        // 解説ヘッダ
        Row(
          children: [
            const Text(
              "【解説】",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Text(
              q["answer"] ? "（正解：○）" : "（正解：×）",
              style: const TextStyle(fontSize: 18, color: Colors.blue),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // 解説本文
        Text(
          q["explanation"],
          style: TextStyle(fontSize: 16, height: 1.8, color: sc.text),
        ),

        const SizedBox(height: 32),

        // 次へボタン
        if (currentIndex < questions.length - 1)
          ElevatedButton(
            onPressed: () {
              setState(() {
                currentIndex++;
                answered = false;
                selectedAnswer = null;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              minimumSize: const Size(double.infinity, 56),
            ),
            child: const Text(
              "次の問題へ",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

        if (currentIndex == questions.length - 1)
          const Text(
            "これで全ての問題が終了です！",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
      ],
    );
  }
}
