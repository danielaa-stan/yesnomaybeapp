import 'package:flutter/material.dart';

class PollResultsView extends StatelessWidget {
  final Map<String, int> pollResults;
  final int totalVotes;
  final String? userVotedOption; //for highlighting chosen option
  final List<String> options;

  const PollResultsView({
    super.key,
    required this.pollResults,
    required this.totalVotes,
    required this.options,
    this.userVotedOption,
  });

  @override
  Widget build(BuildContext context) {
    if (totalVotes == 0 && pollResults.isEmpty) {
      return const Center(
        child: Text('Be the first to vote to see results!', style: TextStyle(color: Color(0xFF1A4D4D))),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // displaying the results for each option
        ...options.map((option) {
          final voteCount = pollResults[option] ?? 0;
          final percentage = totalVotes > 0 ? (voteCount / totalVotes) * 100 : 0.0;
          final isSelected = userVotedOption == option;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildResultBar(option, percentage.round(), isSelected),
          );
        }).toList(),
      ],
    );
  }

  // helper widget for the result bar
  Widget _buildResultBar(String option, int percentage, bool isSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(option, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            Text('$percentage%', style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? const Color(0xFF4EE06D) : Colors.black)),
          ],
        ),
        const SizedBox(height: 5),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: Colors.grey.shade300,
          color: isSelected ? const Color(0xFF4EE06D) : const Color(0xFFB8A6D9).withOpacity(0.8),
          minHeight: 10,
          borderRadius: BorderRadius.circular(5),
        ),
      ],
    );
  }
}