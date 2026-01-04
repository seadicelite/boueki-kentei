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

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final q = questions[current];

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            "Q${current + 1}",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
            child: const Text("解答する"),
          ),

          const SizedBox(height: 24),

          if (answered) _buildExplanation(q),
        ],
      ),
    );
  }

  // ----------------------------
  // 問題文（①②を強調）
  // ----------------------------
  Widget _buildSentence(Map q) {
    return Text(
      q["sentence"],
      style: const TextStyle(fontSize: 18, height: 1.6),
    );
  }

  // ----------------------------
  // ドロップダウン
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
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          items: items
              .map<DropdownMenuItem<String>>(
                (e) => DropdownMenuItem(value: e, child: Text(e)),
              )
              .toList(),
          onChanged: answered ? null : onChanged,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
      ],
    );
  }

  // ----------------------------
  // 解説
  // ----------------------------
  Widget _buildExplanation(Map q) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
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
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            q["explanation"],
            style: const TextStyle(fontSize: 16, height: 1.6),
          ),
        ],
      ),
    );
  }
}
