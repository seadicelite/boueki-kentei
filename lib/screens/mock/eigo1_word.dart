import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EnglishVocabChoiceScreen extends StatefulWidget {
  final String title;
  final String fileName;
  final int limit;
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
  // ===============================
  // ChatGPT風カラー
  // ===============================
  static const bgColor = Color(0xFF0F0F0F);
  static const cardColor = Color(0xFF1E1E1E);
  static const accentColor = Color(0xFF10A37F);
  static const textColor = Colors.white;
  static const subTextColor = Colors.grey;

  // ===============================
  // データ
  // ===============================
  List<dynamic> allWords = [];
  List<dynamic> questions = [];

  int current = 0;
  bool loading = true;

  // Dropdown用
  List<String> currentLabels = [];
  int? selectedIndex;

  // 回答保持
  final Map<int, String> userAnswers = {};
  final List<Map<String, dynamic>> answerLog = [];

  // ===============================
  // 初期化
  // ===============================
  @override
  void initState() {
    super.initState();
    loadJson();
  }

  Future<void> loadJson() async {
    final jsonString = await rootBundle.loadString(widget.fileName);
    final data = jsonDecode(jsonString);

    allWords = List.from(data)..shuffle();
    questions = allWords.take(widget.limit).toList();

    prepareQuestion();

    setState(() => loading = false);
  }

  // ===============================
  // 選択肢生成
  // ===============================
  List<String> buildChoices(String correctAnswer) {
    final pool = allWords.map<String>((e) => e["term_jp"].toString()).toList();

    pool.remove(correctAnswer);
    pool.shuffle();

    final options = [
      correctAnswer,
      ...pool.take(pool.length >= 7 ? 7 : pool.length),
    ]..shuffle();

    return options;
  }

  void prepareQuestion() {
    final q = questions[current];
    currentLabels = buildChoices(q["term_jp"]);
    selectedIndex = null;
  }

  // ===============================
  // 回答処理
  // ===============================
  void selectAnswer(int index) {
    final jp = currentLabels[index];
    userAnswers[current] = jp;

    if (current + 1 < questions.length) {
      setState(() {
        current++;
        prepareQuestion();
      });
    } else {
      finishQuiz();
    }
  }

  // ===============================
  // 🔥 ResultScreen 用フォーマットで返却
  // ===============================
  void finishQuiz() {
    answerLog.clear();

    for (int i = 0; i < questions.length; i++) {
      final q = questions[i];
      final correct = q["term_jp"];
      final user = userAnswers[i];
      final isCorrect = user == correct;

      answerLog.add({
        // 🔑 ResultScreenEigo が読むキー
        "question": q["term_en"], // Q 表示
        "selected": user, // あなたの答え
        "correct": correct, // 正解
        "isCorrect": isCorrect,
        "points": isCorrect ? 1.0 : 0.0,
      });
    }

    final score = answerLog.fold<double>(0, (s, e) => s + e["points"]);

    widget.onComplete(answerLog, score);
  }

  // ===============================
  // UI
  // ===============================
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: bgColor,
        body: Center(child: CircularProgressIndicator(color: accentColor)),
      );
    }

    final q = questions[current];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.title,
          style: const TextStyle(color: textColor, fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 進捗バー
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (current + 1) / questions.length,
                minHeight: 8,
                backgroundColor: Colors.grey[800],
                valueColor: const AlwaysStoppedAnimation(accentColor),
              ),
            ),

            const SizedBox(height: 28),

            // 問題カード
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                "Q${current + 1}. ${q["term_en"]}",
                style: const TextStyle(
                  fontSize: 22,
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Dropdown
            Theme(
              data: Theme.of(context).copyWith(canvasColor: cardColor),
              child: DropdownButtonFormField<int>(
                value: selectedIndex,
                dropdownColor: cardColor,
                iconEnabledColor: accentColor,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: "日本語を選択",
                  labelStyle: const TextStyle(color: subTextColor),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: subTextColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: accentColor),
                  ),
                ),
                style: const TextStyle(color: textColor, fontSize: 16),
                items: List.generate(currentLabels.length, (i) {
                  return DropdownMenuItem<int>(
                    value: i,
                    child: Text(currentLabels[i]),
                  );
                }),
                onChanged: (value) {
                  if (value == null) return;
                  selectAnswer(value);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
