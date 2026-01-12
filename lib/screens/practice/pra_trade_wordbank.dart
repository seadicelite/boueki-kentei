import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:math';

class PracticeTradeBlank2Screen extends StatefulWidget {
  final String title;
  final String fileName;

  const PracticeTradeBlank2Screen({
    super.key,
    required this.title,
    required this.fileName,
  });

  @override
  State<PracticeTradeBlank2Screen> createState() =>
      _PracticeTradeBlank2ScreenState();
}

class _PracticeTradeBlank2ScreenState extends State<PracticeTradeBlank2Screen> {
  List questions = [];
  int current = 0;

  String? selected1;
  String? selected2;
  bool answered = false;

  // 🎨 ChatGPT風カラー
  static const bgColor = Color(0xFF0F0F0F);
  static const cardColor = Color(0xFF1E1E1E);
  static const accentColor = Color(0xFF10A37F);

  @override
  void initState() {
    super.initState();
    loadJson();
  }

  Future<void> loadJson() async {
    final jsonString = await rootBundle.loadString(widget.fileName);
    final data = jsonDecode(jsonString);

    List list = List.from(data["questions"]);
    list.shuffle(Random());

    setState(() {
      questions = list;
    });
  }

  bool get isCorrect {
    final q = questions[current];
    return selected1 == q["answer1"] && selected2 == q["answer2"];
  }

  bool get isLast => current == questions.length - 1;

  void nextQuestion() {
    if (!isLast) {
      setState(() {
        current++;
        selected1 = null;
        selected2 = null;
        answered = false;
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
                current = 0;
                selected1 = null;
                selected2 = null;
                answered = false;
              });
            },
            child: const Text("もう一度"),
          ),
        ],
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

    final q = questions[current];

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
          Text(
            "Q${current + 1}",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 16),

          _buildSentence(q),

          const SizedBox(height: 24),

          _buildDropdown(
            label: "空欄①",
            value: selected1,
            items: q["choices"],
            onChanged: (v) => setState(() => selected1 = v),
          ),

          const SizedBox(height: 16),

          _buildDropdown(
            label: "空欄②",
            value: selected2,
            items: q["choices"],
            onChanged: (v) => setState(() => selected2 = v),
          ),

          const SizedBox(height: 32),

          ElevatedButton(
            onPressed: (selected1 != null && selected2 != null && !answered)
                ? () => setState(() => answered = true)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              "解答する",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          if (answered) ...[
            const SizedBox(height: 24),
            _buildExplanation(q),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: nextQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                isLast ? "練習を終了する" : "次の問題へ",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ----------------------------
  // 問題文カード
  // ----------------------------
  Widget _buildSentence(Map q) {
    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          q["sentence"],
          style: const TextStyle(
            fontSize: 18,
            height: 1.6,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ----------------------------
  // ドロップダウン（ダーク対応）
  // ----------------------------
  Widget _buildDropdown({
    required String label,
    required String? value,
    required List items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          dropdownColor: cardColor,
          value: value,
          items: items
              .map<DropdownMenuItem<String>>(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(color: Colors.white)),
                ),
              )
              .toList(),
          onChanged: answered ? null : onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: cardColor,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white24),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: accentColor),
            ),
          ),
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  // ----------------------------
  // 解説エリア
  // ----------------------------
  Widget _buildExplanation(Map q) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isCorrect ? Colors.green : Colors.red),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isCorrect ? "正解！" : "不正解…",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isCorrect ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "正解：① ${q["answer1"]} ／ ② ${q["answer2"]}",
            style: const TextStyle(fontSize: 16, color: accentColor),
          ),
          const SizedBox(height: 8),
          Text(
            q["explanation"],
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
