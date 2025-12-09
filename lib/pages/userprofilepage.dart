import 'dart:math';

import 'package:flutter/material.dart';
import '../widgets/pollcard.dart';
import '../widgets/navigationbar.dart';
import 'profileeditpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yesnomaybeapp/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'polls_list_page.dart';
import 'notifications_page.dart';
import 'package:provider/provider.dart';
import '../providers/polls_provider.dart';
import '../models/poll.dart';
import 'edit_poll_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:yesnomaybeapp/l10n/app_localizations.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

const Map<String, String> kAvailableLanguages = {
  'en': 'English (UK)',
  'uk': 'Українська',
};

const int _pollListLimit = 3;

class _UserProfilePageState extends State<UserProfilePage> {

  String? _expandedPollId;
  String? _expandedVotedPollId;

  // state variables
  String _userName = 'Unknown';
  Set<String> _userInterests = {};
  String _currentLanguage = 'English (UK)';
  String _userHandle = 'unknown';
  String _userBio = '';
  String? _userPhotoUrl;
  late String _preferredLanguage;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // loading user name
  Future<void> _loadProfileData() async {
    final user = FirebaseAuth.instance.currentUser;
    final String defaultHandle = user?.email?.split('@').first ?? 'unknown';

    if ( mounted && user != null) {
      print('Current User UID for Query: ${user.uid}');
      //read from firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final String savedLangCode = userDoc.data()?['preferredLanguageCode'] as String? ?? 'en';

      setState(() {
        _userName = user.displayName ?? defaultHandle;
        _userHandle = defaultHandle;
        // loading _userInterests and bio from Firestore
        _userBio = userDoc.data()?['bio'] ?? 'Write something about yourself!';
        _userPhotoUrl = user.photoURL;
        final List<dynamic> interestsList = userDoc.data()?['interests'] ?? [];
        _preferredLanguage = savedLangCode;
        _currentLanguage = kAvailableLanguages[_preferredLanguage] ?? 'English (UK)';
        _userInterests = Set<String>.from(interestsList);
      });
    }
  }

  // Helper widget to build the top header icons
  Widget _buildHeaderIcon(IconData icon, VoidCallback onTap,
      {Color iconColor = Colors.white}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor, size: 28),
        onPressed: onTap,
      ),
    );
  }

  // Helper widget for section headers
  Widget _buildSectionHeader({required String title, required PollListType type}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A4D4D))),
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PollsListPage(type: type),
              ),
            );
          },
          icon: const Icon(Icons.arrow_forward),
          color: const Color(0xFF4EE06D),
        ),
      ],
    );
  }

  // profile update
  void _editProfile() async {
    final Map<String, dynamic>? result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileEditPage(
          currentInterests: _userInterests,
          currentLanguage: _currentLanguage,
          currentBio: _userBio,
        ),
      ),
    );

    // update state if profile edit page returned new data
    if (result != null) {
      await _loadProfileData();

      setState(() {
        _userName = result['name'] as String;
        _userInterests = result['interests'] as Set<String>;
        _userBio = result['bio'] as String;
      });
    }
  }

  void _handleVoteSubmitted(String pollId, String selectedOption) async {
    // provider call for saving the vote to Firestore
    final provider = Provider.of<PollsProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    try {
      // async vote sending (firestore update)
      await provider.submitVote(pollId, selectedOption);

      // local state and UI update
      if (mounted) {
        setState(() {
          // the card is closing after voting (switch to Less)
          _expandedPollId = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.snackBarVoteSuccess), backgroundColor: Color(0xFF4EE06D),),
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

  void _handleDeletePoll(String pollId, int totalVotes) async {
    final provider = Provider.of<PollsProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    try {
      await provider.deletePoll(pollId, totalVotes);

      // reload the page
      if (mounted) {
        await _loadProfileData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.deletedPollSnackBar), backgroundColor: Color(0xFF4EE06D)),
        );
      }
    } catch (e) {
      String errorMsg = e.toString().contains("Cannot delete")
          ? "Cannot delete poll with votes."
          : "Failed to delete poll.";
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg)));
    }
  }

//edit poll method
  void _handleEditPoll(Poll poll) {
    // go to Edit Poll Page
    print('Editing Poll: ${poll.title}');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPollPage(pollToEdit: poll),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    const Color headerColor = Color(0xFF205F5F);

    final provider = Provider.of<PollsProvider>(context);
    final votedPollIds = provider.votedOptionsMap.keys.toSet();
    final List<Poll> _userCreatedPolls = provider.allPolls
        .where((poll) => poll.authorId == FirebaseAuth.instance.currentUser?.uid) // filter by Poll object
        .toList();
    final List<Poll> _userVotedPolls = provider.allPolls
        .where((poll) => votedPollIds.contains(poll.id))
        .toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header Section
            Container(
              color: headerColor,
              padding: const EdgeInsets.only(top: 30, left: 20, right: 20, bottom: 20),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // Top Icons (Back, Notification, Edit)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildHeaderIcon(Icons.arrow_back, () => Navigator.pop(context)),
                        Row(
                          children: [
                            _buildHeaderIcon(Icons.notifications_outlined, () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const NotificationsPage()),
                              );
                            }),
                            const SizedBox(width: 8),
                            // edit button
                            _buildHeaderIcon(Icons.edit_outlined, _editProfile),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Profile Image
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      backgroundImage: _userPhotoUrl != null
                          ? NetworkImage(_userPhotoUrl!)
                          : null,
                      child: _userPhotoUrl == null
                          ? const Icon(Icons.person, size: 60, color: Colors.grey)
                          : null,
                    ),
                    const SizedBox(height: 12),

                    // User Name
                    Text(
                      _userName, // use state variable
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    // User Handle
                    Text(
                      '@$_userHandle',
                      style: const TextStyle(fontSize: 16, color: Color(0xFF4EE06D)),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Content Section (White Background, Scrollable Content)
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 80.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bio Section
                  Text(l10n.profileBioTitle, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A4D4D))),
                  const SizedBox(height: 4),
                  Text(
                    _userBio,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),

                  // Your Polls Section Header
                  _buildSectionHeader(title: l10n.yourPollsHeader,
                    type: PollListType.Created,
                  ),
                  // const SizedBox(height: 8),

                  if (_userCreatedPolls.isEmpty)
                    Text(l10n.messageNoPolls, style: TextStyle(color: Colors.grey))
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: min(_userCreatedPolls.length, _pollListLimit),
                      itemBuilder: (context, index) {
                        final poll = _userCreatedPolls[index];
                        final List<String> pollOptions = List<String>.from(poll.options as List? ?? []);
                        final String currentPollId = poll.id;
                        final DateTime date = poll.createdAt ?? DateTime.now();
                        final bool isExpanded = _expandedPollId == currentPollId;
                        final bool isVoted = provider.votedOptionsMap.containsKey(currentPollId);
                        final String? userVotedOption = provider.votedOptionsMap[currentPollId];
                        final Map<String, int>? voteResults = Map<String, int>.from(poll.voteCounts as Map? ?? {});
                        final int totalVotes = (poll.totalVotes as num?)?.toInt() ?? 0;
                        final bool canEditOrDelete = poll.totalVotes == 0;

                        return PollCard(
                          key: ValueKey(currentPollId),
                          question: poll.title ?? 'No Title',
                          subtitle: poll.description ?? '',
                          votes: (poll.totalVotes as num?)?.toInt() ?? 0,
                          date: '${date.day}.${date.month}.${date.year}',
                          isVoted: isVoted,
                          voteResults: voteResults,
                          totalVotes: totalVotes,
                          userVotedOption: userVotedOption,
                          options: pollOptions,
                          isExpanded: isExpanded,
                          onExpansionChanged: (isNowExpanded) {
                            setState(() {
                              _expandedPollId = isNowExpanded ? currentPollId : null;
                            });
                          },
                          onVoteSubmitted: (selectedOption) {
                            _handleVoteSubmitted(poll.id, selectedOption);
                          },
                          canEditDelete: canEditOrDelete,

                          onEditTapped: canEditOrDelete ? () => _handleEditPoll(poll) : null,
                          onDeleteTapped: canEditOrDelete ? () => _handleDeletePoll(poll.id, totalVotes) : null,
                          color: const Color(0xFF4EE06D),
                        );
                      },
                    ),

                  const SizedBox(height: 20), //dynamic list space

                  // Your Votes Section Header
                  _buildSectionHeader(title: l10n.yourVotesHeader,
                    type: PollListType.Voted,
                  ),
                  //const SizedBox(height: 16),
                  if (_userVotedPolls.isEmpty)
                    Text(l10n.messageNoVotes, style: TextStyle(color: Colors.grey))
                  else
                    ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: min(_userCreatedPolls.length, _pollListLimit),
                        itemBuilder: (context, index) {
                          final poll = _userVotedPolls[index];
                          final String currentPollId = poll.id;

                          final List<String> pollOptions = List<String>.from(poll.options as List? ?? []);
                          final DateTime date = poll.createdAt ?? DateTime.now();

                          // for this section isVoted is always true
                          final bool isVoted = poll.isVoted;
                          final String? userVotedOption = provider.votedOptionsMap[currentPollId];

                          final Map<String, int>? voteResults = Map<String, int>.from(poll.voteCounts as Map? ?? {});
                          final int totalVotes = (poll.totalVotes as num?)?.toInt() ?? 0;

                          final bool isExpanded = _expandedVotedPollId == currentPollId;

                          return PollCard(
                            key: ValueKey(currentPollId),
                            question: poll.title ?? 'No Title',
                            subtitle: poll.description as String? ?? '',
                            votes: totalVotes,
                            date: '${date.day}.${date.month}.${date.year}',
                            isVoted: isVoted,
                            options: pollOptions,
                            voteResults: voteResults,
                            totalVotes: totalVotes,
                            userVotedOption: userVotedOption,
                            isExpanded: isExpanded,
                            onExpansionChanged: (isNowExpanded) {
                              setState(() {
                                _expandedVotedPollId = isNowExpanded ? currentPollId : null;
                              });
                            },
                            color: const Color(0xFF4EE06D),
                          );
                        },
                    ),
          ],
              ),
            ),
    ],
      ),
    ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }
}