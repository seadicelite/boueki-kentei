import 'package:flutter/material.dart';
import 'exam_cate.dart';
import '../pra_cate.dart';
import 'package:boueki_kentei/core/colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: sc.back,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: sc.appbar,
        centerTitle: true,
        title: const Text(
          "貿易実務検定C級",
          style: TextStyle(
            color: sc.text,
            fontWeight: FontWeight.w600,
            fontSize: 18,
            letterSpacing: 0.4,
          ),
        ),
        iconTheme: const IconThemeData(color: sc.icon),
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

  // 💻 Wide
  Widget _buildWideLayout(BuildContext context) {
    return Row(
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
        const SizedBox(width: 24),
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

  // 🔘 Premium Button
  Widget _bigButton({required String title, required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF111111), Color(0xFF1C1C1C)],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: sc.text),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.45),
              blurRadius: 24,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
              color: sc.text,
            ),
          ),
        ),
      ),
    );
  }
}
