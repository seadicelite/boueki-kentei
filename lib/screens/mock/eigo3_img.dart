import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PracticeTradeImageGroupABCScreen extends StatefulWidget {
  final String title;
  final String fileName;
  final int limit; // 出題する画像グループ数（例：5 → 10問）
  final Function(List<Map<String, dynamic>>, double) onComplete;

  const PracticeTradeImageGroupABCScreen({
    super.key,
    required this.title,
    required this.fileName,
    required this.limit,
    required this.onComplete,
  });

  @override
  State<PracticeTradeImageGroupABCScreen> createState() =>
      _PracticeTradeImageGroupABCScreenState();
}

class _PracticeTradeImageGroupABCScreenState
    extends State<PracticeTradeImageGroupABCScreen> {
  List<dynamic> groups = []; // 画像＋質問2つのセット
  List<Map<String, dynamic>> flatQuestions = []; // 出題用（グループ展開後）

  int current = 0;
  bool loading = true;

  String? selected;
  bool showExplanation = false;

  final List<Map<String, dynamic>> answerLog = [];

  @override
  void initState() {
    super.initState();
    loadJson();
  }

  Future<void> loadJson() async {
    final jsonString = await rootBundle.loadString(widget.fileName);
    final data = jsonDecode(jsonString);

    // 1. グループ（画像セット）を取得
    groups = List.from(data["question_groups"]);
    groups.shuffle(Random()); // グループごとシャッフル

    // 2. limit グループだけ抽出
    groups = groups.take(widget.limit).toList();

    // 3. グループを「画像を保持したままフラット化」
    flatQuestions = [];

    for (var group in groups) {
      final imagePath = group["image"];
      final qs = group["questions"];

      for (var q in qs) {
        flatQuestions.add({
          "image": imagePath,
          "sentence": q["sentence"],
          "A": q["A"],
          "B": q["B"],
          "C": q["C"],
          "answer": q["answer"],
          "explanation": q["explanation"],
        });
      }
    }

    setState(() => loading = false);
  }

  // ============================================================
  // 🔵 回答
  // ============================================================
  void selectAnswer(String key) {
    if (showExplanation) return;

    final q = flatQuestions[current];
    final correct = q["answer"];
    final isCorrect = (key == correct);

    selected = key;
    showExplanation = true;

    answerLog.add({
      "image": q["image"],
      "sentence": q["sentence"],
      "user": key,
      "correct": isCorrect,
      "points": isCorrect ? 1.0 : 0.0,
      "correctAnswer": correct,
      "explanation": q["explanation"],
    });

    setState(() {});
  }

  // ============================================================
  // 🔵 次へ
  // ============================================================
  void next() {
    if (current + 1 < flatQuestions.length) {
      setState(() {
        current++;
        selected = null;
        showExplanation = false;
      });
    } else {
      final score = answerLog.fold<double>(0, (s, e) => s + e["points"]);
      widget.onComplete(answerLog, score);
    }
  }

  bool get isLast => current == flatQuestions.length - 1;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final q = flatQuestions[current];

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔵 画像
              Center(
                child: Image.asset(
                  q["image"],
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                "Q${current + 1}. ${q["sentence"]}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              _choice("A", q["A"]),
              const SizedBox(height: 12),
              _choice("B", q["B"]),
              const SizedBox(height: 12),
              _choice("C", q["C"]),

              const SizedBox(height: 30),

              if (showExplanation) _explanation(q),

              if (showExplanation)
                ElevatedButton(
                  onPressed: next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: Text(isLast ? "大問を終了する" : "次の問題へ"),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔵 3択ボタン
  Widget _choice(String key, String text) {
    final isSelected = (selected == key);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blueAccent : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton(
        onPressed: () => selectAnswer(key),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: isSelected ? Colors.white : Colors.black,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.radio_button_checked : Icons.circle_outlined,
                color: isSelected ? Colors.white : Colors.grey,
              ),
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

  // 🔵 解説
  Widget _explanation(q) {
    final correct = q["answer"];
    final isCorrect = selected == correct;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
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
          Text(
            "正解：$correct → ${q[correct]}",
            style: const TextStyle(color: Colors.blue, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Text(
            q["explanation"],
            style: const TextStyle(fontSize: 16, height: 1.6),
          ),
        ],
      ),
    );
  }
}
