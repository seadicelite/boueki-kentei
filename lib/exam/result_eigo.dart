import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    const double maxScore = 50.0; // 英語は50点満点
    final double percent = (totalScore / maxScore) * 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text("貿易英語 結果"),
        backgroundColor: Colors.lightBlue[100],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ============================
            // 🔵 総合スコア
            // ============================
            Center(
              child: Column(
                children: [
                  Text(
                    "総合スコア：${totalScore.toStringAsFixed(1)} / 50点",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "正答率：${percent.toStringAsFixed(1)}%",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: percent / 100,
                    minHeight: 8,
                    color: Colors.lightBlue,
                    backgroundColor: Colors.grey[300],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ============================
            // 🔵 大問別スコア
            // ============================
            const Text(
              "【大問別スコア】",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 8),

            ...sectionScores.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  "${entry.key}：${entry.value.toStringAsFixed(1)}点",
                  style: const TextStyle(fontSize: 16),
                ),
              );
            }),

            const Divider(thickness: 1, height: 32),

            // ============================
            // 🔵 詳細結果
            // ============================
            const Text(
              "【詳細結果】",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: ListView.builder(
                itemCount: answers.length,
                itemBuilder: (context, index) {
                  final ans = answers[index];

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 英文
                          Text(
                            "Q${index + 1}. ${ans["question"] ?? ""}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),

                          const SizedBox(height: 6),

                          if (ans["sentence"] != null)
                            Text(
                              ans["sentence"],
                              style: const TextStyle(fontSize: 14),
                            ),

                          const SizedBox(height: 8),

                          Text(
                            "あなたの答え：${ans["selected"] ?? "-"}",
                            style: const TextStyle(fontSize: 14),
                          ),
                          Text(
                            "正解：${ans["correct"] ?? "-"}",
                            style: const TextStyle(fontSize: 14),
                          ),

                          Text(
                            "得点：${ans["points"].toStringAsFixed(1)}点",
                            style: const TextStyle(fontSize: 14),
                          ),

                          const SizedBox(height: 6),

                          if (ans["explanation"] != null &&
                              ans["explanation"].toString().isNotEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blueGrey[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "解説：${ans["explanation"]}",
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),

                          Align(
                            alignment: Alignment.bottomRight,
                            child: Icon(
                              ans["isCorrect"]
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: ans["isCorrect"]
                                  ? Colors.green
                                  : Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
