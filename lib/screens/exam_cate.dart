import 'package:flutter/material.dart';
import '../exam/exam_runner.dart';

class ExamCategoryScreen extends StatelessWidget {
  final String examId;
  final String examTitle;

  const ExamCategoryScreen({
    super.key,
    required this.examId,
    required this.examTitle,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categories = [
      {"id": "boeki_jitsumu", "title": "貿易実務", "description": "制限時間60分・150点満点"},
      {"id": "boeki_eigo", "title": "貿易英語", "description": "制限時間45分・50点満点"},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(examTitle),
        backgroundColor: Colors.lightBlue[100],
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final String catId = cat["id"];
          final String catTitle = cat["title"];
          final String catDescription = cat["description"];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            shadowColor: Colors.black26,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                try {
                  // ===================================================
                  // 🔵 貿易英語の模試
                  // ===================================================
                  if (catId == "boeki_eigo") {
                    final List<Map<String, dynamic>> eigoSections = [
                      {
                        "id": "eigo1",
                        "title": "大問1：英単語問題",
                        "file": "assets/data/random_eigo/practice_eigo_1.json",
                        "type": "english_word",
                        "limit": 20,
                      },
                      {
                        "id": "eigo2",
                        "title": "大問2：英語3択問題",
                        "file": "assets/data/random_eigo/practice_eigo_2.json",
                        "type": "english_abc",
                        "limit": 10,
                      },
                      {
                        "id": "eigo3",
                        "title": "大問3：画像付き英語問題",
                        "file": "assets/data/random_eigo/practice_eigo_3.json",
                        "type": "english_img_group",
                        "limit": 1,
                      },
                    ];

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MockExamRunner(
                          examTitle: "$catTitle 模試",
                          examId: catId,
                          sections: eigoSections,
                        ),
                      ),
                    );
                    return;
                  }

                  // ===================================================
                  // 🔴 貿易実務の模試
                  // ===================================================
                  final List<Map<String, dynamic>> jitsumuSections = [
                    {
                      "id": "dai1",
                      "title": "大問1：貿易実務 正誤問題",
                      "file":
                          "assets/data/random_jitsumu/practice_trade_1.json",
                      "type": "marubatsu",
                      "limit": 20,
                    },
                    {
                      "id": "dai2",
                      "title": "大問2：貿易実務 選択問題",
                      "file":
                          "assets/data/random_jitsumu/practice_trade_2.json",
                      "type": "ab",
                      "limit": 20,
                    },
                    {
                      "id": "dai3",
                      "title": "大問3：貿易実務 語群穴埋め",
                      "file":
                          "assets/data/random_jitsumu/practice_trade_3.json",
                      "type": "wordbank",
                      "limit": 10,
                    },
                    {
                      "id": "dai4",
                      "title": "大問4：貿易実務 3択問題",
                      "file":
                          "assets/data/random_jitsumu/practice_trade_4.json",
                      "type": "abc",
                      "limit": 15,
                    },
                  ];

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MockExamRunner(
                        examTitle: "$catTitle 模試",
                        examId: catId,
                        sections: jitsumuSections,
                      ),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("画面遷移中にエラーが発生しました"),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                child: Row(
                  children: [
                    // 左：タイトルと説明
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            catTitle,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            catDescription,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.blueGrey,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
