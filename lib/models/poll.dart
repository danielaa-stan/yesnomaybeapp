import 'package:cloud_firestore/cloud_firestore.dart';

class Poll {
  final String id;
  final String title;
  final String description;
  final List<String> options;
  final int totalVotes;
  final Map<String, int> voteCounts;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final String tag;
  final bool isVoted;
  final String? userVotedOption;

  const Poll({
    required this.id,
    required this.title,
    required this.description,
    required this.options,
    required this.totalVotes,
    required this.voteCounts,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    required this.tag,
    this.isVoted = false,
    this.userVotedOption,
  });

  // mapping with Firestore DocumentSnapshot
  factory Poll.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc, {
    bool isVoted = false,
    String? userVotedOption,
  }) {
    final data = doc.data() ?? {};
    final Timestamp? timestamp = data['created_at'] as Timestamp?;

    return Poll(
      id: doc.id,
      title: data['title'] as String? ?? 'No Title',
      description: data['description'] as String? ?? '',
      options: List<String>.from(data['options'] ?? []),
      totalVotes: (data['total_votes'] as num?)?.toInt() ?? 0,
      voteCounts: Map<String, int>.from(data['vote_counts'] ?? {}),
      authorId: data['author_id'] as String? ?? '',
      authorName: data['author_name'] as String? ?? 'Anonymous',
      tag: data['tag'] as String? ?? 'General',
      createdAt: timestamp?.toDate() ?? DateTime.now(),
      isVoted: isVoted,
      userVotedOption: userVotedOption,
    );
  }

  // mapping for record in Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'options': options,
      'total_votes': totalVotes,
      'vote_counts': voteCounts,
      'author_id': authorId,
      'author_name': authorName,
      'tag': tag,
      'created_at': FieldValue.serverTimestamp(),
    };
  }
}