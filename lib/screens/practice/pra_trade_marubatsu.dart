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

  // 🔥  ランダム化
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

  // ---------------------------------------------------------
  // 🔥 ○×ボタン（アニメ付き）
  // ---------------------------------------------------------
  Widget animatedAnswerButton({
    required bool answerValue,
    required String label,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    final bool isSelected = selectedAnswer == answerValue;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: isSelected ? activeColor : inactiveColor,
        borderRadius: BorderRadius.circular(12),

        boxShadow: isSelected
            ? [BoxShadow(color: activeColor.withOpacity(0.5), blurRadius: 12)]
            : [],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.black,
        ),
        onPressed: answered
            ? null
            : () {
                setState(() {
                  selectedAnswer = answerValue;
                  answered = true; // ← 押した瞬間回答
                });

                // 🔥 解説へ自動スクロール
                Future.delayed(const Duration(milliseconds: 250), () {
                  Scrollable.ensureVisible(
                    explanationKey.currentContext!,
                    duration: const Duration(milliseconds: 400),
                  );
                });
              },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(label),
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
      appBar: AppBar(title: Text(widget.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🔵 問題文（question）
          Text(
            "Q${currentIndex + 1}. ${q["question"]}",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          // 🔥 ○×ボタン
          Row(
            children: [
              Expanded(
                child: animatedAnswerButton(
                  answerValue: true,
                  label: "○ 正しい",
                  activeColor: Colors.green.withOpacity(0.7),
                  inactiveColor: Colors.grey[300]!,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: animatedAnswerButton(
                  answerValue: false,
                  label: "× 誤り",
                  activeColor: Colors.red.withOpacity(0.7),
                  inactiveColor: Colors.grey[300]!,
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // 🔵 解説
          if (answered) _buildExplanation(q),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // 🔥 解説（正解表示つき）
  // ---------------------------------------------------------
  Widget _buildExplanation(Map q) {
    final bool isCorrect = (q["answer"] == selectedAnswer);

    return Column(
      key: explanationKey,
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

        const SizedBox(height: 20),

        // 🔵 解説ヘッダ + 正解
        Row(
          children: [
            const Text(
              "【解説】",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(width: 8),
            Text(
              q["answer"] == true ? "（正解：○）" : "（正解：×）",
              style: const TextStyle(fontSize: 18, color: Colors.blue),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Text(
          q["explanation"],
          style: const TextStyle(fontSize: 16, height: 1.6),
        ),

        const SizedBox(height: 30),

        // 🔵 次へ
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
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text("次の問題へ"),
          ),

        if (currentIndex == questions.length - 1)
          const Text(
            "これで全ての問題が終了です！",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
      ],
    );
  }
}
