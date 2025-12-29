import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EnglishVocabChoiceScreen extends StatefulWidget {
  final String title;
  final String fileName;
  final int limit; // 10
  final Function(List<Map<String, dynamic>>, double) onComplete;

  const EnglishVocabChoiceScreen({
    super.key,
    required this.title,
    required this.fileName,
    required this.limit,
    required this.onComplete,
  });

  @override
  State<EnglishVocabChoiceScreen> createState() =>
      _EnglishVocabChoiceScreenState();
}

class _EnglishVocabChoiceScreenState extends State<EnglishVocabChoiceScreen> {
  List<dynamic> allWords = [];
  List<dynamic> questions = [];

  int current = 0;
  bool loading = true;

  String? selected;
  bool showResult = false;

  final List<Map<String, dynamic>> answerLog = [];

  @override
  void initState() {
    super.initState();
    loadJson();
  }

  Future<void> loadJson() async {
    final jsonString = await rootBundle.loadString(widget.fileName);
    final data = jsonDecode(jsonString);

    allWords = List.from(data); // 全単語

    allWords.shuffle();

    // 🔵 出題10個
    questions = allWords.take(widget.limit).toList();

    setState(() => loading = false);
  }

  // ---------------------------------------------------------
  // 🔥 選択肢20個生成（正解 + ランダム19個）
  // ---------------------------------------------------------
  List<String> buildChoices(String correctAnswer) {
    List<String> pool = allWords
        .map<String>((e) => e["term_jp"].toString())
        .toSet()
        .toList();

    pool.shuffle();

    // 重複防止
    pool.remove(correctAnswer);

    // 正解 + ランダム19語
    List<String> options = [correctAnswer];
    options.addAll(pool.take(19));

    options.shuffle();
    return options;
  }

  void selectAnswer(String jp) {
    if (showResult) return;

    final q = questions[current];
    final correct = q["term_jp"];
    final isCorrect = (jp == correct);

    selected = jp;
    showResult = true;

    answerLog.add({
      "term_en": q["term_en"],
      "user": jp,
      "correct": isCorrect,
      "points": isCorrect ? 1.0 : 0.0,
      "correctAnswer": correct,
    });

    setState(() {});
  }

  void next() {
    if (current + 1 < questions.length) {
      setState(() {
        current++;
        selected = null;
        showResult = false;
      });
    } else {
      final score = answerLog.fold<double>(0, (s, e) => s + e["points"]);
      widget.onComplete(answerLog, score);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final q = questions[current];
    final termEn = q["term_en"];
    final correct = q["term_jp"];

    final choices = buildChoices(correct);

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔵 英単語（問題）
            Text(
              "Q${current + 1}. $termEn",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 24),

            // 🔵 選択肢（日本語）
            Expanded(
              child: ListView.builder(
                itemCount: choices.length,
                itemBuilder: (_, i) {
                  final jp = choices[i];
                  final isSelected = selected == jp;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected
                            ? Colors.blueAccent
                            : Colors.grey[200],
                        foregroundColor: isSelected
                            ? Colors.white
                            : Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => selectAnswer(jp),
                      child: Text(jp, style: const TextStyle(fontSize: 16)),
                    ),
                  );
                },
              ),
            ),

            if (showResult) ...[
              const SizedBox(height: 10),
              Text(
                selected == correct ? "◎ 正解！" : "✕ 不正解…（正解：$correct）",
                style: TextStyle(
                  fontSize: 18,
                  color: selected == correct ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  minimumSize: const Size(double.infinity, 48),
                ),
                onPressed: next,
                child: Text(
                  current + 1 == questions.length ? "大問を終了する" : "次の問題へ",
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
