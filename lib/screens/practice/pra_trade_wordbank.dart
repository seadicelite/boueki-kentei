import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class PracticeTradePassageWordBankScreen extends StatefulWidget {
  final String title;
  final String fileName;

  const PracticeTradePassageWordBankScreen({
    super.key,
    required this.title,
    required this.fileName,
  });

  @override
  State<PracticeTradePassageWordBankScreen> createState() =>
      _PracticeTradePassageWordBankScreenState();
}

class _PracticeTradePassageWordBankScreenState
    extends State<PracticeTradePassageWordBankScreen> {
  List<String> passage = [];
  List<String> wordBank = [];
  List<dynamic> questions = [];

  Map<int, String> answers = {};
  bool showExplanation = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadJson();
  }

  Future<void> loadJson() async {
    final jsonString = await rootBundle.loadString(widget.fileName);
    final data = jsonDecode(jsonString);

    setState(() {
      passage = List<String>.from(data["passage"]);
      wordBank = List<String>.from(data["wordBank"]);
      questions = data["questions"];
      isLoading = false;
    });
  }

  void checkAnswers() {
    setState(() => showExplanation = true);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: showExplanation
            ? const BouncingScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPassage(),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: answers.length == questions.length
                  ? checkAnswers
                  : null,
              child: const Text("回答を確定する"),
            ),

            const SizedBox(height: 30),

            if (showExplanation) _buildExplanation(),
          ],
        ),
      ),
    );
  }

  Widget _buildPassage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: passage.map((text) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [..._replaceBlanks(text), const SizedBox(height: 20)],
        );
      }).toList(),
    );
  }

  /// ( ① ) → ドロップダウンに置換
  List<Widget> _replaceBlanks(String text) {
    final regex = RegExp(r'（\s*([①-⑩])\s*）');
    final List<Widget> widgets = [];

    int lastIndex = 0;
    int blankCount = 1;

    for (final match in regex.allMatches(text)) {
      final beforeText = text.substring(lastIndex, match.start);
      widgets.add(Text(beforeText, style: const TextStyle(fontSize: 16)));

      final number = blankCount;
      widgets.add(_buildDropdown(number));

      blankCount++;
      lastIndex = match.end;
    }

    widgets.add(
      Text(text.substring(lastIndex), style: const TextStyle(fontSize: 16)),
    );

    return widgets;
  }

  Widget _buildDropdown(int number) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: answers[number],
        hint: Text("(${number.toString().padLeft(2, '0')}) 選択"),
        items: wordBank.map((word) {
          return DropdownMenuItem(value: word, child: Text(word));
        }).toList(),
        onChanged: showExplanation
            ? null
            : (value) => setState(() => answers[number] = value!),
      ),
    );
  }

  Widget _buildExplanation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: questions.map((q) {
        final number = q["number"];
        final userAnswer = answers[number];
        final correct = q["answer"];
        final isCorrect = userAnswer == correct;

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isCorrect ? Colors.green.shade50 : Colors.red.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            "（$number） ${isCorrect ? "正解" : "不正解"}\n"
            "あなたの回答：$userAnswer\n"
            "正解：$correct\n\n"
            "${q["explanation"]}",
            style: const TextStyle(fontSize: 14),
          ),
        );
      }).toList(),
    );
  }
}
