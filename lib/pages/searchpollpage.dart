import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/polls_provider.dart';
import '../widgets/navigationbar.dart';
import '../widgets/pollcard.dart';
import '../l10n/app_localizations.dart';

class SearchPollPage extends StatefulWidget {
  const SearchPollPage({Key? key}) : super(key: key);

  @override
  State<SearchPollPage> createState() => _SearchPollPageState();
}

class _SearchPollPageState extends State<SearchPollPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _expandedPollId;


  final List<Map<String, dynamic>> _hotTopics = const [
    {'title': 'Sports', 'color': Color(0xFF4EE06D)},
    {'title': 'Fashion', 'color': Colors.white},
    {'title': 'Music', 'color': Color(0xFFB8A6D9)},
    {'title': 'Computer Science', 'color': Color(0xFFCEF45E)},
    {'title': 'Social/volunteering', 'color': Colors.white},
    {'title': 'Hiking', 'color': Color(0xFF4EE06D)},
    {'title': 'Travelling', 'color': Color(0xFFB8A6D9)},
    {'title': 'Life choices', 'color': Color(0xFFCEF45E)},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _startSearch(String query, PollsProvider provider) {
    provider.searchPolls(
      query: query,
      tag: provider.selectedTagFilter,
    );
  }

  Widget _buildTopicCard({
    required String title,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final textColor =
    isSelected || color == Colors.white ? const Color(0xFF1A4D4D) : Colors.white;
    final effectiveColor =
    isSelected && color != Colors.white ? const Color(0xFF4EE06D) : color;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: effectiveColor,
          borderRadius: BorderRadius.circular(25),
          border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }


  void _handleVoteSubmitted(String pollId, String selectedOption) async {
    final l10n = AppLocalizations.of(context)!;
    // provider call for saving the vote to Firestore
    final provider = Provider.of<PollsProvider>(context, listen: false);

    try {
      //async vote sending (updates Firestore)
      await provider.submitVote(pollId, selectedOption);

      // local state and UI update
      if (mounted) {
        setState(() {
          // the poll card closes -> switch to Less
          _expandedPollId = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.snackBarVoteSuccess)),
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
    const Color darkTeal = Color(0xFF1A4D4D);

    return Consumer<PollsProvider>(
      builder: (context, provider, child) {
        // Determine UI states
        final bool showTagsGrid =
            provider.currentSearchQuery.isEmpty && provider.selectedTagFilter == null;
        final bool showResults = !showTagsGrid;

        return Scaffold(
          backgroundColor: darkTeal,
          bottomNavigationBar: const BottomNavBar(currentIndex: 2),
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                // HEADER + SEARCH BAR + TAG CHIP
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          l10n.searchPageHeader,
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Search bar
                        TextField(
                          controller: _searchController,
                          onChanged: (value) => _startSearch(value, provider),
                          style: const TextStyle(color: Color(0xFF1A4D4D)),
                          decoration: InputDecoration(
                            hintText: l10n.searchBarHint,
                            hintStyle: TextStyle(color: Colors.grey[600]),
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 0),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Show selected tag as a chip with X to clear
                        if (provider.selectedTagFilter != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: GestureDetector(
                              onTap: () {
                                provider.searchPolls(
                                  query: _searchController.text,
                                  tag: null,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      provider.selectedTagFilter!,
                                      style: const TextStyle(
                                        color: Color(0xFF1A4D4D),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.close,
                                        color: Color(0xFF1A4D4D), size: 18),
                                  ],
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // TAGS TITLE
                if (showTagsGrid)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:  [
                          Text(
                            l10n.searchPageSubheader,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                // TAGS GRID
                if (showTagsGrid)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        childAspectRatio: 1.5,
                      ),
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          final topic = _hotTopics[index];
                          final tag = topic['title'];
                          final selected = provider.selectedTagFilter == tag;

                          return _buildTopicCard(
                            title: tag,
                            color: topic['color'],
                            isSelected: selected,
                            onTap: () {
                              provider.searchPolls(
                                query: _searchController.text,
                                tag: selected ? null : tag,
                              );
                            },
                          );
                        },
                        childCount: _hotTopics.length,
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                // SEARCH RESULTS
                if (showResults) ...[
                  if (provider.state == PollsState.Loading)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    )
                  else if (provider.allPolls.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child:
                        Text(
                          l10n.noPollsFound,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          final poll = provider.allPolls[index];
                          final date = poll.createdAt ?? DateTime.now();
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
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 8,
                            ),

                            child: PollCard(
                              key: ValueKey(poll.id),
                              question: poll.title ?? 'No Title',
                              subtitle: poll.description ?? '',
                              votes: (poll.totalVotes as num?)?.toInt() ?? 0,
                              date: '${date.day}.${date.month}.${date.year}',
                              isVoted: poll.isVoted as bool? ?? false,
                              options: List<String>.from(poll.options ?? []),
                              isExpanded: isExpanded,
                              color: const Color(0xFF4EE06D),
                              onExpansionChanged: (isNowExpanded) {
                                setState(() {
                                  // if the card is open -> save the ID, otherwise -> null
                                  _expandedPollId = isNowExpanded ? poll.id : null;
                                });
                              },
                              userVotedOption: userVotedOption,
                              voteResults: integerVoteCounts,
                              totalVotes: (poll.totalVotes as num?)?.toInt() ?? 0,
                              onVoteSubmitted: (selectedOption) {
                                // handler call passing the poll ID and selected option
                                _handleVoteSubmitted(poll.id, selectedOption);
                              },
                            ),
                          );
                        },
                        childCount: provider.allPolls.length,
                      ),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
