import 'package:flutter/material.dart';
import '../widgets/pollcard.dart';
import '../widgets/navigationbar.dart';
import 'createpollpage.dart';
import 'searchpollpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yesnomaybeapp/auth.dart';
import 'package:provider/provider.dart';
import 'package:yesnomaybeapp/providers/polls_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notifications_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:yesnomaybeapp/l10n/app_localizations.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _expandedPollId;

  // get the name and display it
  String _extractDisplayName(User? user) {
    if (user == null) {
      return 'Guest';
    }
    if (user.displayName != null && user.displayName!.isNotEmpty) {
      return user.displayName!;
    }
    final email = user.email;
    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }
    return 'User';
  }

  // handle vote from PollCard
  void _handleVoteSubmitted(String pollId, String selectedOption) async {
    // provider call for saving to Firestore
    final provider = Provider.of<PollsProvider>(context, listen: false);

    final l10n = AppLocalizations.of(context)!;

    try {
      // async sending vote (updates Firestore)
      await provider.submitVote(pollId, selectedOption);

      // local state and UI update
      if (mounted) {
        setState(() {
          // the card closes after voting (switch to Less)
          _expandedPollId = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.snackBarVoteSuccess),
          ),
        );
      }
    } catch (e) {
      // error handling
      String errorMsg = e.toString().contains('voted')
          ? 'You have already voted on this poll.'
          : 'Failed to submit vote.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section with greeting and notification bell
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // StreamBuilder for automatic name changes
                    StreamBuilder<User?>(
                      stream: FirebaseAuth.instance.userChanges(),
                      builder: (context, snapshot) {
                        final String currentName = _extractDisplayName(snapshot.data);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${l10n.homepageGreeting} $currentName!',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A4D4D),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.homepageSubheader,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    // Notification bell icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.notifications_outlined,
                          size: 28,
                          color: Colors.grey[700],
                        ),
                        onPressed: () { //add navigation
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const NotificationsPage()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Two main action buttons in a row
                Row(
                  children: [
                  // "Create a poll" button (yellow-green)
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CreatePollPage()),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFCEF45E), // Yellow-green
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Center(
                            child: Text(
                                l10n.createPollButton,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A4D4D),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // "Find the poll" button (purple)
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SearchPollPage()),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFB8A6D9), // Light purple
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Center(
                            child: Text(
                                l10n.findPollButton,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const SizedBox(height: 30),

                // "Hot picks for you" section title
                Text(
                    l10n.homepageHeader,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A4D4D),
                  ),
                ),
                const SizedBox(height: 16),

                Consumer<PollsProvider>(
                  builder: (context, provider, child) {
                    if (provider.state == PollsState.Loading) {
                      return const Center(child: Padding(
                        padding: EdgeInsets.all(30.0),
                        child: CircularProgressIndicator(color: Color(0xFF4EE06D)),
                      ));
                    }
                    if (provider.state == PollsState.Error) {
                      return Center(child: Text('Error loading polls: ${provider.errorMessage}'));
                    }

                    final polls = provider.allPolls;

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: polls.length,
                      itemBuilder: (context, index) {
                        final poll = polls[index];
                        final List<String> pollOptions = List<String>.from(poll.options as List? ?? []);
                        final bool isExpanded = _expandedPollId == poll.id;
                        final String currentPollId = poll.id;
                        final String? userVotedOption = provider.votedOptionsMap[currentPollId];
                        final Map<String, dynamic>? firestoreVoteCounts = poll.voteCounts as Map<String, dynamic>?;

                        final Map<String, int> integerVoteCounts = {};
                        if (firestoreVoteCounts != null) {
                          // convert each number to int
                          firestoreVoteCounts.forEach((key, value) {
                            if (value is num) {
                              integerVoteCounts[key] = value.toInt();
                            }
                          });
                        }
                        return PollCard(
                          key: ValueKey(poll.id),
                          question: poll.title, // use 'title' from Firestore
                          subtitle: poll.description,
                          votes: poll.totalVotes,
                          date: poll.createdAt.toString().substring(0, 10), // handling Timestamp
                          isVoted: poll.isVoted as bool? ?? false,
                          options: pollOptions,
                          onExpansionChanged: (isNowExpanded) {
                            setState(() {
                              // update _expandedPollId
                              _expandedPollId = isNowExpanded ? poll.id : null;
                            });
                          },
                          // pass the expanded state
                          isExpanded: isExpanded,
                          userVotedOption: userVotedOption,
                          voteResults: integerVoteCounts,
                          totalVotes: (poll.totalVotes as num?)?.toInt() ?? 0,
                          onVoteSubmitted: (selectedOption) {
                            _handleVoteSubmitted(poll.id, selectedOption);
                          },

                          color: const Color(0xFF4EE06D),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),

      // Bottom Navigation Bar with 4 icons
      bottomNavigationBar: const BottomNavBar(
        currentIndex: 0,
      ),
    );
  }
}