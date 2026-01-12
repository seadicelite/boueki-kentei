import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:math';

class EnglishThreeChoiceScreen extends StatefulWidget {
  final String title;
  final String fileName;

  const EnglishThreeChoiceScreen({
    super.key,
    required this.title,
    required this.fileName,
  });

  @override
  State<EnglishThreeChoiceScreen> createState() =>
      _EnglishThreeChoiceScreenState();
}

class _EnglishThreeChoiceScreenState extends State<EnglishThreeChoiceScreen> {
  // 🎨 ChatGPT風カラー
  static const bgColor = Color(0xFF0F0F0F);
  static const cardColor = Color(0xFF1E1E1E);
  static const accentColor = Color(0xFF10A37F);

  List<dynamic> questions = [];
  int current = 0;

  String? selectedAnswer; // "A" / "B" / "C"
  bool isAnswered = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadJson();
  }

  // =====================================
  // JSON読み込み（questions配列）
  // =====================================
  Future<void> loadJson() async {
    final jsonString = await rootBundle.loadString(widget.fileName);
    final data = jsonDecode(jsonString);

    final list = List<dynamic>.from(data["questions"]);
    list.shuffle(Random());

    setState(() {
      questions = list;
      isLoading = false;
    });
  }

  // =====================================
  // 回答
  // =====================================
  void onSelect(String key) {
    if (isAnswered) return;

    setState(() {
      selectedAnswer = key;
      isAnswered = true;
    });
  }

  // =====================================
  // 次の問題
  // =====================================
  void nextQuestion() {
    setState(() {
      current++;
      selectedAnswer = null;
      isAnswered = false;
    });
  }

  bool get isLast => current == questions.length - 1;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: bgColor,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final q = questions[current];
    final correct = q["answer"]; // "A" / "B" / "C"

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 進捗表示
          Text(
            "Question ${current + 1} / ${questions.length}",
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 10),

          // 英文（問題文）
          Text(
            q["sentence_en"],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 28),

          // 日本語3択
          _buildChoice("A", q["optionA_jp"], correct),
          const SizedBox(height: 12),
          _buildChoice("B", q["optionB_jp"], correct),
          const SizedBox(height: 12),
          _buildChoice("C", q["optionC_jp"], correct),

          const SizedBox(height: 32),

          // 次へボタン（回答後のみ）
          AnimatedOpacity(
            opacity: isAnswered ? 1 : 0,
            duration: const Duration(milliseconds: 250),
            child: IgnorePointer(
              ignoring: !isAnswered,
              child: ElevatedButton(
                onPressed: isLast ? null : nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  isLast ? "Finish" : "Next",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================
  // 選択肢UI（回答後ロック・色分け）
  // =====================================
  Widget _buildChoice(String key, String text, String correct) {
    final isCorrect = isAnswered && key == correct;
    final isWrong = isAnswered && key == selectedAnswer && key != correct;

    Color bg;
    Color border;
    IconData icon;
    Color iconColor;

    if (isCorrect) {
      bg = accentColor.withOpacity(0.2);
      border = accentColor;
      icon = Icons.check_circle;
      iconColor = accentColor;
    } else if (isWrong) {
      bg = Colors.redAccent.withOpacity(0.2);
      border = Colors.redAccent;
      icon = Icons.cancel;
      iconColor = Colors.redAccent;
    } else if (isAnswered) {
      bg = cardColor.withOpacity(0.5);
      border = Colors.white12;
      icon = Icons.circle_outlined;
      iconColor = Colors.white24;
    } else {
      bg = cardColor;
      border = Colors.white24;
      icon = Icons.circle_outlined;
      iconColor = Colors.white38;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: 1.2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => onSelect(key),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
          child: Row(
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "$key. $text",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
