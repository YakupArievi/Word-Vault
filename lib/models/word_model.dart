import 'package:cloud_firestore/cloud_firestore.dart';

class WordModel {
  final String id;
  final String targetWord;
  final String translation;
  final String? sentence;
  final bool isLearned;
  final int correctCount;
  final DateTime? lastReview;  
  final int level;
  WordModel({
    required this.id,
    required this.targetWord,
    required this.translation,
    this.sentence,
    required this.isLearned,
    this.correctCount = 0,
    this.lastReview,
    this.level = 0, 
  });

  factory WordModel.fromMap(Map<String, dynamic> map, String id) {
    return WordModel(
      id: id,
      targetWord: map['targetWord'] ?? '',
      translation: map['translation'] ?? '',
      sentence: map['sentence'],
      isLearned: map['isLearned'] ?? false,
      correctCount: map['correctCount'] ?? 0,
      level: map['level'] ?? 0,
      lastReview: map['lastReview'] != null 
          ? (map['lastReview'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'targetWord': targetWord,
      'translation': translation,
      'sentence': sentence,
      'isLearned': isLearned,
      'correctCount': correctCount,
      'level': level,
      'lastReview': lastReview != null ? Timestamp.fromDate(lastReview!) : null,
    };
  }
}