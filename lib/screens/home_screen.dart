import 'package:flutter/material.dart';
import 'exam_cate.dart';
import '../pra_cate.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "貿易実務検定C級",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 700;

          return SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Padding(
                  padding: const EdgeInsets.all(20),
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

  // =============================
  // 📱 スマホ表示（縦並び）
  // =============================
  Widget _buildNarrowLayout(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _bigButton(
          title: "模擬テスト",
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

  // =============================
  // 💻 PC / iPad（横並び）
  // =============================
  Widget _buildWideLayout(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: _bigButton(
            title: "模擬テスト",
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
        const SizedBox(width: 20),
        Expanded(
          child: _bigButton(
            title: "大問別問題",
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

  // =============================
  // 🔵 共通の巨大ボタン
  // =============================
  Widget _bigButton({required String title, required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.blueAccent.shade100,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
