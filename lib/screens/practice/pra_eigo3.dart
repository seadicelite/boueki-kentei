import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PracticeEigoImageABCScreen extends StatefulWidget {
  final String title;

  const PracticeEigoImageABCScreen({super.key, required this.title});

  @override
  State<PracticeEigoImageABCScreen> createState() =>
      _PracticeEigoImageABCScreenState();
}

class _PracticeEigoImageABCScreenState
    extends State<PracticeEigoImageABCScreen> {
  // ===============================
  // 状態
  // ===============================
  String? documentType;
  Map<String, dynamic>? document;
  List<dynamic> questions = [];
  List<String?> userAnswers = [];
  bool showResult = false;

  // ===============================
  // 設定
  // ===============================
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

  // ===============================
  // 🔥 完全ランダムで次のドキュメント
  // ===============================
  Future<void> loadRandomDocument() async {
    final files = List<String>.from(allDocFiles)..shuffle(Random());
    final selectedFile = files.first;

    final jsonString = await rootBundle.loadString(selectedFile);
    final decoded = json.decode(jsonString);

    final List<dynamic> docs = List.from(decoded["documents"])
      ..shuffle(Random());
    final selected = docs.first;

    setState(() {
      documentType = decoded["document_type"];
      document = selected["document"];
      questions = selected["questions"];
      userAnswers = List<String?>.filled(questions.length, null);
      showResult = false;
    });
  }

  // ===============================
  // 採点
  // ===============================
  void answerCheck() {
    setState(() {
      showResult = true;
    });
  }

  bool get allAnswered => userAnswers.every((a) => a != null);

  // ===============================
  // UI
  // ===============================
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
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 📄 ドキュメント表示
          buildDocumentView(),

          const SizedBox(height: 24),

          // ❓ 質問（2問縦並び）
          ...List.generate(questions.length, (index) {
            final q = questions[index];
            final correct = q["answer"];

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

                  _choiceButton(index, "A", q["A"], correct),
                  const SizedBox(height: 8),
                  _choiceButton(index, "B", q["B"], correct),
                  const SizedBox(height: 8),
                  _choiceButton(index, "C", q["C"], correct),
                ],
              ),
            );
          }),

          const SizedBox(height: 20),

          // 🔘 Answer Check / Next
          ElevatedButton(
            onPressed: showResult
                ? loadRandomDocument
                : allAnswered
                ? answerCheck
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              showResult ? "Next Document" : "Answer Check",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================
  // 📄 document_type 切替
  // ===============================
  Widget buildDocumentView() {
    switch (documentType) {
      case "INVOICE":
        return InvoiceDocumentView(doc: document!);
      case "LETTER_OF_CREDIT":
        return LetterOfCreditView(doc: document!);
      case "BILL_OF_LADING":
        return BillOfLadingView(doc: document!);
      case "BILL_OF_EXCHANGE":
        return BillOfExchangeView(doc: document!);
      default:
        return const SizedBox();
    }
  }

  // ===============================
  // 🔘 選択肢
  // ===============================
  Widget _choiceButton(int index, String key, String text, String correct) {
    final selected = userAnswers[index];
    final isSelected = selected == key;
    final isCorrect = showResult && key == correct;
    final isWrong = showResult && isSelected && key != correct;

    Color bg = cardColor;
    Color border = Colors.white24;

    if (!showResult && isSelected) {
      bg = accentColor.withOpacity(0.18);
      border = accentColor;
    }
    if (isCorrect) {
      bg = accentColor.withOpacity(0.3);
      border = accentColor;
    }
    if (isWrong) {
      bg = Colors.redAccent.withOpacity(0.3);
      border = Colors.redAccent;
    }

    return InkWell(
      onTap: showResult ? null : () => setState(() => userAnswers[index] = key),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: 1.4),
        ),
        child: Text(
          "$key. $text",
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////
// 以下：ドキュメント表示（変更なし）
////////////////////////////////////////////////////////////////////////////////

class InvoiceDocumentView extends StatelessWidget {
  final Map<String, dynamic> doc;
  const InvoiceDocumentView({super.key, required this.doc});

  @override
  Widget build(BuildContext context) {
    return _base("INVOICE", [
      "Invoice No.: ${doc["invoice_no"]}",
      "Invoice Date: ${doc["invoice_date"]}",
      "Seller: ${doc["seller"]["company"]}",
      "Buyer: ${doc["buyer"]["company"]}",
      "Total: ${doc["total"]["currency"]} ${doc["total"]["amount"]}",
    ]);
  }
}

class LetterOfCreditView extends StatelessWidget {
  final Map<String, dynamic> doc;
  const LetterOfCreditView({super.key, required this.doc});

  @override
  Widget build(BuildContext context) {
    return _base("LETTER OF CREDIT", [
      "L/C No.: ${doc["lc_no"]}",
      "Applicant: ${doc["applicant"]["company"]}",
      "Beneficiary: ${doc["beneficiary"]["company"]}",
      "Expiry: ${doc["expiry"]["date"]}",
    ]);
  }
}

class BillOfLadingView extends StatelessWidget {
  final Map<String, dynamic> doc;
  const BillOfLadingView({super.key, required this.doc});

  @override
  Widget build(BuildContext context) {
    return _base("BILL OF LADING", [
      "Shipper: ${doc["shipper"]}",
      "Consignee: ${doc["consignee"]}",
      "Loading: ${doc["port_of_loading"]}",
      "Discharge: ${doc["port_of_discharge"]}",
    ]);
  }
}

class BillOfExchangeView extends StatelessWidget {
  final Map<String, dynamic> doc;
  const BillOfExchangeView({super.key, required this.doc});

  @override
  Widget build(BuildContext context) {
    return _base("BILL OF EXCHANGE", [
      "Amount: ${doc["amount_numeric"]}",
      "Tenor: ${doc["tenor"]}",
      "Drawer: ${doc["drawer"]}",
    ]);
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
        const Divider(color: Colors.white24, height: 24),
        ...lines.map(
          (e) => Text(
            e,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
      ],
    ),
  );
}
