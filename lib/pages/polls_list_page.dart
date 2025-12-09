import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/polls_provider.dart';
import '../widgets/pollcard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/poll.dart';
import 'package:yesnomaybeapp/l10n/app_localizations.dart';

enum PollListType { Created, Voted }

class PollsListPage extends StatefulWidget {
  final PollListType type;

  const PollsListPage({super.key, required this.type});

  @override
  State<PollsListPage> createState() => _PollsListPageState();
}

class _PollsListPageState extends State<PollsListPage> {

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pollsProvider = Provider.of<PollsProvider>(context);
    // filter list based on the type
    // for "Created" use the list of all polls (the function is in provider)
    List<Poll> displayedPolls;

    if (widget.type == PollListType.Created) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      //filter the polls to find the one created by the current user
      displayedPolls = pollsProvider.allPolls
          .where((poll) => poll.authorId == userId)
          .toList();
    } else {
      // for voted -> use data from Provider
      final votedPollIds = pollsProvider.votedOptionsMap.keys.toSet();
      displayedPolls = pollsProvider.allPolls
          .where((poll) => votedPollIds.contains(poll.id))
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.type == PollListType.Created ? l10n.thePollsYouCreated : l10n.thePollsYouVotedIn,
          style: const TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xFF1A4D4D),
      ),
      backgroundColor: Colors.grey[100],
      body: (pollsProvider.state == PollsState.Loading)
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4EE06D)))
          : (pollsProvider.state == PollsState.Error)
          ? Center(child: Text('Error: ${pollsProvider.errorMessage}'))
          : (displayedPolls.isEmpty)
          ? Center(
              child: Text(
                  widget.type == PollListType.Created
                    ? l10n.messageNoPolls
                    : l10n.messageNoVotes,
                  style: TextStyle(color: Colors.grey[600])))
          : ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: displayedPolls.length,
        itemBuilder: (context, index) {
          final poll = displayedPolls[index];
          final String currentPollId = poll.id;
          final DateTime date = poll.createdAt ?? DateTime.now();
          final bool isVoted = pollsProvider.votedOptionsMap.containsKey(currentPollId);
          final String? userVotedOption = pollsProvider.votedOptionsMap[currentPollId];

          final Map<String, int>? voteResults =
          Map<String, int>.from(poll.voteCounts as Map? ?? {});
          final int totalVotes = (poll.totalVotes as num?)?.toInt() ?? 0;

          return PollCard(
            key: ValueKey(poll.id),
            question: poll.title ?? 'No Title',
            subtitle: poll.description as String? ?? '',
            votes: totalVotes,
            date: '${date.day}.${date.month}.${date.year}',
            isVoted: isVoted,
            options: List<String>.from(poll.options as List? ?? []),
            isExpanded: false, //poll cards are closed
            onExpansionChanged: (isNowExpanded) {},
            voteResults: voteResults,
            totalVotes: totalVotes,
            userVotedOption: userVotedOption,
            color: const Color(0xFF4EE06D),
          );
        },
      ),
    );
  }
}