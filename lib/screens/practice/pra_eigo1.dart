import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// ================================
/// 単語データモデル
/// ================================
class Term {
  final int id;
  final String termEn;
  final String termJp;

  Term({required this.id, required this.termEn, required this.termJp});

  factory Term.fromJson(Map<String, dynamic> json) {
    return Term(
      id: json["id"],
      termEn: json["term_en"],
      termJp: json["term_jp"],
    );
  }
}

/// ================================
/// ChatGPT風 英単語マッチング
/// ================================
class PracticeEigo1Screen extends StatefulWidget {
  final String title;
  final String fileName;
  final int limit;
  final Function(List<Map<String, dynamic>>, double)? onComplete;

  const PracticeEigo1Screen({
    super.key,
    required this.title,
    required this.fileName,
    this.limit = 5,
    this.onComplete,
  });

  @override
  State<PracticeEigo1Screen> createState() => _PracticeEigo1ScreenState();
}

class _PracticeEigo1ScreenState extends State<PracticeEigo1Screen> {
  // 🎨 ChatGPT風カラー
  static const bgColor = Color(0xFF0F0F0F);
  static const cardColor = Color(0xFF1E1E1E);
  static const accentColor = Color(0xFF10A37F);

  List<Term> allTerms = [];
  List<Term> questions = [];
  List<String> wordPool = [];
  Map<int, String> userAnswers = {};

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadAndPrepare();
  }

  Future<void> loadAndPrepare() async {
    await loadTerms();
    generateTest();
  }

  Future<void> loadTerms() async {
    final jsonStr = await rootBundle.loadString(widget.fileName);
    final list = jsonDecode(jsonStr);
    allTerms = list.map<Term>((e) => Term.fromJson(e)).toList();
    loading = false;
  }

  void generateTest() {
    final shuffled = List<Term>.from(allTerms)..shuffle(Random());
    questions = shuffled.take(widget.limit).toList();

    final correct = questions.map((e) => e.termJp).toList();
    final dummy =
        allTerms
            .map((e) => e.termJp)
            .where((jp) => !correct.contains(jp))
            .toList()
          ..shuffle(Random());

    wordPool = [...correct, ...dummy.take(widget.limit)]..shuffle(Random());
    userAnswers.clear();
    setState(() {});
  }

  void scoreTest() {
    int score = 0;
    List<Map<String, dynamic>> logs = [];

    for (final q in questions) {
      final selected = userAnswers[q.id];
      final isCorrect = selected == q.termJp;
      if (isCorrect) score++;

      logs.add({
        "question": q.termEn,
        "selected": selected ?? "未回答",
        "correct": q.termJp,
        "points": isCorrect ? 1.0 : 0.0,
        "isCorrect": isCorrect,
        "explanation": "",
      });
    }

    if (widget.onComplete != null) {
      widget.onComplete!(logs, score.toDouble());
      return;
    }

    showResultSheet(score);
  }

  /// ================================
  /// 結果 BottomSheet（ChatGPT風）
  /// ================================
  void showResultSheet(int score) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Text(
                "$score / ${widget.limit}",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: score >= widget.limit / 2
                      ? accentColor
                      : Colors.redAccent,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                score >= widget.limit / 2 ? "Good Job!" : "Try Again",
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: questions.length,
                  itemBuilder: (_, i) {
                    final q = questions[i];
                    final selected = userAnswers[q.id];
                    final isCorrect = selected == q.termJp;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            q.termEn,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "あなたの回答: ${selected ?? "未回答"}",
                            style: TextStyle(
                              color: isCorrect ? accentColor : Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "正解: ${q.termJp}",
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// ================================
  /// UI
  /// ================================
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: generateTest,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: questions.length,
        itemBuilder: (_, i) {
          final q = questions[i];

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  q.termEn,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  dropdownColor: cardColor,
                  value: userAnswers[q.id],
                  hint: const Text(
                    "日本語を選択",
                    style: TextStyle(color: Colors.white70),
                  ),
                  iconEnabledColor: accentColor,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: bgColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                  ),
                  items: wordPool
                      .map((jp) => DropdownMenuItem(value: jp, child: Text(jp)))
                      .toList(),
                  onChanged: (val) {
                    setState(() => userAnswers[q.id] = val!);
                  },
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: scoreTest,
          style: ElevatedButton.styleFrom(
            backgroundColor: accentColor,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text(
            "採点する",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
