import 'package:flutter/material.dart';

/// 貿易英語 Result Screen（ChatGPT風UI・スマホ最適）
class ResultScreenEigo extends StatelessWidget {
  final List<Map<String, dynamic>> answers;
  final double totalScore;
  final int totalQuestions;
  final Map<String, double> sectionScores;

  const ResultScreenEigo({
    super.key,
    required this.answers,
    required this.totalScore,
    required this.totalQuestions,
    required this.sectionScores,
  });

  // 🎨 ChatGPT風カラー
  static const bgColor = Color(0xFF0F0F0F);
  static const cardColor = Color(0xFF1E1E1E);
  static const accentColor = Color(0xFF10A37F);
  static const correctColor = Color(0xFF2ECC71);
  static const wrongColor = Color(0xFFE74C3C);

  @override
  Widget build(BuildContext context) {
    const double maxScore = 50.0;
    final double percent = (totalScore / maxScore).clamp(0, 1);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "English Test Result",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _summaryCard(percent),
            const SizedBox(height: 24),

            const Text(
              "SECTION SCORES",
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: sectionScores.entries
                  .map((e) => _chip("${e.key}  ${e.value.toStringAsFixed(1)}点"))
                  .toList(),
            ),

            const SizedBox(height: 28),

            const Text(
              "DETAIL RESULTS",
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            ...answers.asMap().entries.map((e) => _detailCard(e.key, e.value)),
          ],
        ),
      ),
    );
  }

  // =========================
  // 総合スコア
  // =========================
  Widget _summaryCard(double percent) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 90,
                height: 90,
                child: CircularProgressIndicator(
                  value: percent,
                  strokeWidth: 8,
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation<Color>(accentColor),
                ),
              ),
              Text(
                "${(percent * 100).toStringAsFixed(0)}%",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${totalScore.toStringAsFixed(1)} / 50点",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Total $totalQuestions questions",
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }

  // =========================
  // 詳細結果
  // =========================
  Widget _detailCard(int index, Map<String, dynamic> ans) {
    final bool isCorrect = ans["isCorrect"] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isCorrect ? correctColor : wrongColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Q${index + 1}. ${ans["question"]}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            "Your Answer : ${ans["selected"]}",
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          Text(
            "Correct     : ${ans["correct"]}",
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? correctColor : wrongColor,
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                "${ans["points"]} 点",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (ans["documentType"] != null) ...[
                const SizedBox(width: 12),
                Text(
                  ans["documentType"],
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
