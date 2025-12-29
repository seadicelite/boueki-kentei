import 'package:flutter/material.dart';
import 'screens/practice/pra_trade_marubatsu.dart';
import 'screens/practice/pra_trade_abc.dart';
import 'screens/practice/pra_trade_ab.dart';
import 'screens/practice/pra_trade_wordbank.dart';
import 'screens/practice/pra_eigo1.dart';
import 'screens/practice/pra_eigo2.dart';
import 'screens/practice/pra_eigo3.dart';

class PracticeCategoryScreen extends StatelessWidget {
  const PracticeCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categories = [
      // 🟦 貿易実務
      {
        "title": "📦 貿易実務 大問1：正誤問題",
        "file": "assets/data/random_jitsumu/practice_trade_1.json",
        "type": "trade",
      },

      {
        "title": "📦 貿易実務 大問2：選択問題",
        "file": "assets/data/random_jitsumu/practice_trade_2.json",
        "type": "trade_ab",
      },
      {
        "title": "📦 貿易実務 大問3：語群選択問題",
        "file": "assets/data/random_jitsumu/practice_trade_3.json",
        "type": "trade_wordbank",
      },
      {
        "title": "📦 貿易実務 大問4：3択問題",
        "file": "assets/data/random_jitsumu/practice_trade_4.json",
        "type": "trade_abc",
      },
      // 🟩 貿易英語
      {
        "title": "🌐 貿易英語 大問1：英単語の意味",
        "file": "assets/data/random_eigo/practice_eigo_1.json",
        "type": "english1",
      },
      {
        "title": "🌐 貿易英語 大問2：英文和訳",
        "file": "assets/data/random_eigo/practice_eigo_2.json",
        "type": "english2",
      },
      {
        "title": "🌐 貿易英語 大問3：英文解釈",
        "file": "assets/data/random_eigo/practice_eigo_3.json",
        "type": "english3",
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("練習モード（ランダム出題）")),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final cat = categories[index];
          return Card(
            elevation: 2,
            child: ListTile(
              title: Text(
                cat["title"],
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () {
                if (cat["type"] == "trade") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PracticeTradeMarubatsuScreen(
                        title: cat["title"],
                        fileName: cat["file"],
                      ),
                    ),
                  );
                } else if (cat["type"] == "trade_ab") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PracticeTradeABScreen(
                        title: cat["title"],
                        fileName: cat["file"],
                      ),
                    ),
                  );
                } else if (cat["type"] == "trade_wordbank") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PracticeTradePassageWordBankScreen(
                        title: cat["title"],
                        fileName: cat["file"],
                      ),
                    ),
                  );
                } else if (cat["type"] == "english1") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PracticeEigo1Screen(
                        title: cat["title"],
                        fileName: cat["file"],
                      ),
                    ),
                  );
                } else if (cat["type"] == "english2") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EnglishThreeChoiceScreen(
                        title: cat["title"],
                        fileName: cat["file"],
                      ),
                    ),
                  );
                } else if (cat["type"] == "english3") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PracticeEigoImageABCScreen(
                        title: cat["title"],
                        fileName: cat["file"],
                      ),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PracticeTradeABCScreen(
                        title: cat["title"],
                        fileName: cat["file"],
                      ),
                    ),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}
