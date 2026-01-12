import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PracticeEigoImageABCScreen extends StatefulWidget {
  final String title;
  final Function(List<Map<String, dynamic>>, double) onComplete;

  const PracticeEigoImageABCScreen({
    super.key,
    required this.title,
    required this.onComplete,
  });

  @override
  State<PracticeEigoImageABCScreen> createState() =>
      _PracticeEigoImageABCScreenState();
}

class _PracticeEigoImageABCScreenState
    extends State<PracticeEigoImageABCScreen> {
  String? documentType;
  Map<String, dynamic>? document;
  List<dynamic> questions = [];
  List<String?> userAnswers = [];

  final List<String> allDocFiles = [
    "assets/data/random_docs/invoice.json",
    "assets/data/random_docs/lc.json",
    "assets/data/random_docs/bl.json",
    "assets/data/random_docs/boe.json",
  ];

  // 🎨 ChatGPT風カラー
  static const bgColor = Color(0xFF0F0F0F);
  static const cardColor = Color(0xFF1E1E1E);
  static const accentColor = Color(0xFF10A37F);

  @override
  void initState() {
    super.initState();
    loadRandomDocument();
  }

  Future<void> loadRandomDocument() async {
    final files = List<String>.from(allDocFiles)..shuffle(Random());
    final jsonString = await rootBundle.loadString(files.first);
    final decoded = json.decode(jsonString);

    final docs = List.from(decoded["documents"])..shuffle(Random());
    final selected = docs.first;

    setState(() {
      documentType = decoded["document_type"];
      document = selected["document"];
      questions = selected["questions"];
      userAnswers = List<String?>.filled(questions.length, null);
    });
  }

  bool get allAnswered => userAnswers.every((a) => a != null);

  // ===============================
  // 🔥 ResultScreenEigo へ結果送信
  // ===============================
  void finishSection() {
    final List<Map<String, dynamic>> answerLog = [];

    for (int i = 0; i < questions.length; i++) {
      final q = questions[i];
      final user = userAnswers[i];
      final correct = q["answer"];

      answerLog.add({
        "question": q["sentence"],
        "selected": user,
        "correct": correct,
        "isCorrect": user == correct,
        "points": user == correct ? 5.0 : 0.0,
        "documentType": documentType,
      });
    }

    final score = answerLog.fold<double>(0, (sum, e) => sum + e["points"]);

    widget.onComplete(answerLog, score);
  }

  @override
  Widget build(BuildContext context) {
    if (document == null) {
      return const Scaffold(
        backgroundColor: bgColor,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDocumentView(),
          const SizedBox(height: 24),

          ...List.generate(questions.length, (index) {
            final q = questions[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Q${index + 1}. ${q["sentence"]}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),

                  _choice(index, "A", q["A"]),
                  const SizedBox(height: 8),
                  _choice(index, "B", q["B"]),
                  const SizedBox(height: 8),
                  _choice(index, "C", q["C"]),
                ],
              ),
            );
          }),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: allAnswered ? finishSection : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              "Finish Section",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================
  // 📄 ドキュメント表示
  // ===============================
  Widget _buildDocumentView() {
    if (documentType == null || document == null) {
      return const SizedBox();
    }

    switch (documentType!) {
      case "INVOICE":
        return _base("INVOICE", [
          "Seller: ${document!["seller"]?["company"] ?? ""}",
        ]);
      case "LETTER_OF_CREDIT":
        return _base("LETTER OF CREDIT", [
          "Applicant: ${document!["applicant"]?["company"] ?? ""}",
        ]);
      case "BILL_OF_LADING":
        return _base("BILL OF LADING", [
          "Shipper: ${document!["shipper"]}",
          "Consignee: ${document!["consignee"]}",
        ]);
      case "BILL_OF_EXCHANGE":
        return _base("BILL OF EXCHANGE", ["Drawer: ${document!["drawer"]}"]);
      default:
        return const SizedBox();
    }
  }

  // ===============================
  // 🔘 選択肢（選択状態のみ表示）
  // ===============================
  Widget _choice(int index, String key, String text) {
    final selected = userAnswers[index];
    final isSelected = selected == key;

    return InkWell(
      onTap: () => setState(() => userAnswers[index] = key),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withOpacity(0.25) : cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? accentColor : Colors.white24),
        ),
        child: Text("$key. $text", style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}

Widget _base(String title, List<String> lines) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF1E1E1E),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white24),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            "$title (Sample)",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Divider(color: Colors.white24),
        ...lines.map(
          (e) => Text(e, style: const TextStyle(color: Colors.white70)),
        ),
      ],
    ),
  );
}
