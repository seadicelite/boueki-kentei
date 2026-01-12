import 'package:flutter/material.dart';
import 'exam_cate.dart';
import '../pra_cate.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // 🎨 ChatGPT風カラー
  static const bgColor = Color(0xFF0F0F0F);
  static const cardColor = Color(0xFF1E1E1E);
  static const accentColor = Color(0xFF10A37F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: bgColor,
        centerTitle: true,
        title: const Text(
          "貿易実務検定C級",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
            letterSpacing: 0.4,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 700;

          return SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: isWide
                      ? _buildWideLayout(context)
                      : _buildNarrowLayout(context),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 📱 Mobile
  Widget _buildNarrowLayout(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _bigButton(
          title: "模擬テスト",
          subtitle: "本番形式で実力チェック",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ExamCategoryScreen(
                  examId: "mock_1",
                  examTitle: "模擬テスト",
                ),
              ),
            );
          },
        ),
        _bigButton(
          title: "大問別問題",
          subtitle: "分野ごとに徹底演習",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PracticeCategoryScreen()),
            );
          },
        ),
      ],
    );
  }

  // 💻 Wide
  Widget _buildWideLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _bigButton(
            title: "模擬テスト",
            subtitle: "本番形式で実力チェック",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ExamCategoryScreen(
                    examId: "mock_1",
                    examTitle: "模擬テスト",
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _bigButton(
            title: "大問別問題",
            subtitle: "分野ごとに徹底演習",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PracticeCategoryScreen(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 🔘 ChatGPT風 ビッグボタン
  Widget _bigButton({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: accentColor.withOpacity(0.8), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 24,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withOpacity(0.65),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
