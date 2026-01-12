import 'package:boueki_kentei/screens/mock/trade1_marubatsu.dart';
import 'package:boueki_kentei/screens/mock/trade2_ab.dart';
import 'package:boueki_kentei/screens/mock/trade3_wordbank.dart';
import 'package:boueki_kentei/screens/mock/trade4_abc.dart';
import 'package:boueki_kentei/screens/mock/eigo1_word.dart';
import 'package:boueki_kentei/screens/mock/eigo2_abc.dart';
import 'package:boueki_kentei/screens/mock/eigo3_img.dart';

import 'package:flutter/material.dart';

// 👉 実務版 / 英語版 ResultScreen を分けて import
import 'result_trade.dart';
import 'result_eigo.dart';

// 各大問UI（limit / onComplete に対応済みのバージョンが必要）
class MockExamRunner extends StatefulWidget {
  final String examTitle;
  final List<Map<String, dynamic>> sections;
  final String examId; // boeki_jitsumu / eigo

  const MockExamRunner({
    super.key,
    required this.examTitle,
    required this.sections,
    required this.examId,
  });

  @override
  State<MockExamRunner> createState() => _MockExamRunnerState();
}

class _MockExamRunnerState extends State<MockExamRunner> {
  int currentIndex = 0;

  final List<Map<String, dynamic>> allAnswers = [];
  final Map<String, double> sectionScores = {};

  // ============================================================
  // 🔵 ローディング（1秒）
  // ============================================================
  Future<void> showLoadingDialog(BuildContext context, String message) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 1));
    Navigator.of(context).pop();
  }

  // ============================================================
  // 🔵 大問終了時
  // ============================================================
  Future<void> onSectionComplete(
    List<Map<String, dynamic>> sectionAnswers,
    double sectionScore,
  ) async {
    allAnswers.addAll(sectionAnswers);

    final sectionTitle = widget.sections[currentIndex]["title"] ?? "大問";

    sectionScores[sectionTitle] = sectionScore;

    // 次の大問読み込み
    await showLoadingDialog(context, "次の大問を読み込み中…");

    if (currentIndex < widget.sections.length - 1) {
      setState(() {
        currentIndex++;
      });
      return;
    }

    // 全部終わり
    await showLoadingDialog(context, "結果画面を作成中…");

    final totalScore = allAnswers.fold<double>(
      0,
      (sum, item) => sum + (item["points"] ?? 0),
    );

    // 🔥 実務 / 英語の結果画面を自動切替
    if (widget.examId == "boeki_jitsumu") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreenJitsumu(
            answers: allAnswers,
            totalScore: totalScore,
            totalQuestions: allAnswers.length,
            sectionScores: sectionScores,
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreenEigo(
            answers: allAnswers,
            totalScore: totalScore,
            totalQuestions: allAnswers.length,
            sectionScores: sectionScores,
          ),
        ),
      );
    }
  }

  // ============================================================
  // 🔵 大問 UI の切替
  // ============================================================
  Widget buildSectionScreen(Map<String, dynamic> sec) {
    final type = sec["type"];
    final file = sec["file"];
    final title = sec["title"];
    final limit = sec["limit"] ?? 999;

    switch (type) {
      case "marubatsu":
        return MockTradeDai1Screen(
          title: title,
          fileName: file,
          limit: limit,
          onComplete: onSectionComplete,
        );

      case "ab":
        return MockTradeDai2Screen(
          title: title,
          fileName: file,
          limit: limit,
          onComplete: onSectionComplete,
        );

      case "wordbank":
        return MockTradeDai3WordbankScreen(
          title: title,
          fileName: file,

          onComplete: onSectionComplete,
        );

      case "abc":
        return MockTradeDai4ABCScreen(
          title: title,
          fileName: file,
          limit: limit,
          onComplete: onSectionComplete,
        );

      case "english_word":
        return EnglishVocabChoiceScreen(
          title: title,
          fileName: file,
          limit: limit,
          onComplete: onSectionComplete,
        );
      case "english_abc":
        return EnglishThreeChoiceScreen(
          title: title,
          fileName: file,
          limit: limit,
          onComplete: onSectionComplete,
        );

      case "english_img_group":
        return PracticeEigoImageABCScreen(
          title: title,
          onComplete: onSectionComplete,
        );

      default:
        return const Center(
          child: Text("未対応の大問タイプです", style: TextStyle(fontSize: 18)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentSection = widget.sections[currentIndex];

    return Scaffold(body: SafeArea(child: buildSectionScreen(currentSection)));
  }
}
