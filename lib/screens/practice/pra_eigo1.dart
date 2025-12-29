import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 単語データモデル
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

/// 大問1 英単語 → 日本語 選択問題（語群・マッチング）
class PracticeEigo1Screen extends StatefulWidget {
  final String title;
  final String fileName;
  final int limit; // 1セット5問（模試用で可変）
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

  // ======================================
  // JSONロード → 問題と語群作成
  // ======================================
  Future<void> loadAndPrepare() async {
    await loadTerms();
    generateTest(); // 一発目の問題セット
  }

  Future<void> loadTerms() async {
    final jsonStr = await rootBundle.loadString(widget.fileName);
    final list = jsonDecode(jsonStr);

    allTerms = list.map<Term>((e) => Term.fromJson(e)).toList();
    loading = false;
  }

  // ======================================
  // 5問と語群10個作成
  // ======================================
  void generateTest() {
    List<Term> shuffled = List.from(allTerms)..shuffle(Random());

    questions = shuffled.take(widget.limit).toList();

    List<String> correct = questions.map((e) => e.termJp).toList();

    List<String> dummy =
        allTerms
            .map((e) => e.termJp)
            .where((jp) => !correct.contains(jp))
            .toList()
          ..shuffle(Random());

    dummy = dummy.take(widget.limit).toList();

    wordPool = [...correct, ...dummy]..shuffle(Random());

    userAnswers.clear();

    setState(() {});
  }

  // ======================================
  // 採点
  // ======================================
  void scoreTest() {
    int score = 0;

    List<Map<String, dynamic>> answerLog = [];

    for (var q in questions) {
      final selected = userAnswers[q.id];
      final correct = q.termJp;
      final isCorrect = selected == correct;

      if (isCorrect) score++;

      answerLog.add({
        "question": q.termEn,
        "selected": selected ?? "未回答",
        "correct": correct,
        "points": isCorrect ? 1.0 : 0.0,
        "isCorrect": isCorrect,
        "explanation": "",
      });
    }

    // ------ Runner へ返す場合 ------
    if (widget.onComplete != null) {
      widget.onComplete!(answerLog, score.toDouble());
      return;
    }

    // ------ 練習画面の場合 → BottomSheet ------
    showResultSheet(score, answerLog);
  }

  // ======================================
  // 結果 BottomSheet
  // ======================================
  void showResultSheet(int score, List<Map<String, dynamic>> logs) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          builder: (_, controller) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: Column(
                children: [
                  // ★ スコアバッジ
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: score >= (widget.limit / 2)
                          ? Colors.green.shade100
                          : Colors.red.shade100,
                    ),
                    child: Column(
                      children: [
                        Text(
                          "$score / ${widget.limit}",
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                            color: score >= (widget.limit / 2)
                                ? Colors.green.shade800
                                : Colors.red.shade800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          score >= (widget.limit / 2)
                              ? "Good Job!"
                              : "Try Again!",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ★ 問題リスト
                  Expanded(
                    child: ListView.builder(
                      controller: controller,
                      itemCount: questions.length,
                      itemBuilder: (_, index) {
                        final q = questions[index];
                        final selected = userAnswers[q.id];
                        final isCorrect = selected == q.termJp;

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                                color: Colors.black12,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                q.termEn,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                      horizontal: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: isCorrect
                                          ? Colors.green.shade100
                                          : Colors.red.shade100,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isCorrect ? Icons.check : Icons.close,
                                          color: isCorrect
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          selected ?? "未回答",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isCorrect
                                                ? Colors.green.shade900
                                                : Colors.red.shade900,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),
                              Text(
                                "正解: ${q.termJp}",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
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
      },
    );
  }

  // ======================================
  // UI
  // ======================================
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "次の${widget.limit}問",
            onPressed: generateTest,
          ),
        ],
      ),

      body: ListView.builder(
        itemCount: questions.length,
        itemBuilder: (_, i) {
          final q = questions[i];

          return Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    q.termEn,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: DropdownButton<String>(
                      hint: const Text("日本語を選択"),
                      value: userAnswers[q.id],
                      items: wordPool.map((jp) {
                        return DropdownMenuItem(value: jp, child: Text(jp));
                      }).toList(),
                      onChanged: (val) {
                        setState(() => userAnswers[q.id] = val!);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: scoreTest,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
          child: Text("採点する", style: const TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}
