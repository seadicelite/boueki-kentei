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

  // 🎨 ChatGPT風カラー
  static const bgColor = Color(0xFF0F0F0F);
  static const cardColor = Color(0xFF1E1E1E);
  static const accentColor = Color(0xFF10A37F);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categories = [
      // 🟦 貿易実務
      {
        "title": "実務 大問1：正誤問題",
        "file": "assets/data/random_jitsumu/practice_trade_1.json",
        "type": "trade",
      },
      {
        "title": "実務 大問2：選択問題",
        "file": "assets/data/random_jitsumu/practice_trade_2.json",
        "type": "trade_ab",
      },
      {
        "title": "実務 大問3：語群選択問題",
        "file": "assets/data/random_jitsumu/practice_trade_3.json",
        "type": "trade_wordbank",
      },
      {
        "title": "実務 大問4：3択問題",
        "file": "assets/data/random_jitsumu/practice_trade_4.json",
        "type": "trade_abc",
      },

      // 🟩 貿易英語
      {
        "title": "英語 大問1：英単語の意味",
        "file": "assets/data/random_eigo/practice_eigo_1.json",
        "type": "english1",
      },
      {
        "title": "英語 大問2：英文和訳",
        "file": "assets/data/random_eigo/practice_eigo_2.json",
        "type": "english2",
      },
      {
        "title": "英語 大問3：英文解釈",
        "file": "assets/data/random_docs",
        "type": "english3",
      },
    ];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "練習モード（ランダム出題）",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final cat = categories[index];

          return InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => _navigate(context, cat),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: accentColor.withOpacity(0.5),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      cat["title"],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.white70,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ----------------------------
  // 画面遷移まとめ
  // ----------------------------
  void _navigate(BuildContext context, Map<String, dynamic> cat) {
    Widget screen;

    switch (cat["type"]) {
      case "trade":
        screen = PracticeTradeMarubatsuScreen(
          title: cat["title"],
          fileName: cat["file"],
        );
        break;
      case "trade_ab":
        screen = PracticeTradeABScreen(
          title: cat["title"],
          fileName: cat["file"],
        );
        break;
      case "trade_wordbank":
        screen = PracticeTradeBlank2Screen(
          title: cat["title"],
          fileName: cat["file"],
        );
        break;
      case "trade_abc":
        screen = PracticeTradeABCScreen(
          title: cat["title"],
          fileName: cat["file"],
        );
        break;
      case "english1":
        screen = PracticeEigo1Screen(
          title: cat["title"],
          fileName: cat["file"],
        );
        break;
      case "english2":
        screen = EnglishThreeChoiceScreen(
          title: cat["title"],
          fileName: cat["file"],
        );
        break;
      case "english3":
        screen = PracticeEigoImageABCScreen(title: cat["title"]);
        break;
      default:
        return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}
