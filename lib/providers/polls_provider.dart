import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/polls_repository.dart';
import '../models/poll.dart';

enum PollsState { Loading, Loaded, Error }

class PollsProvider with ChangeNotifier {
  // inject repository for working with Firestore
  final PollsRepository _repository;

  PollsState _state = PollsState.Loading;
  List<Poll> _allPolls = [];
  String _errorMessage = '';

  String _currentSearchQuery = '';
  String? _selectedTagFilter;

  // saves Map: {PollId: VotedOption}
  Map<String, String> _votedOptionsMap = {};

  // Getters
  String get currentSearchQuery => _currentSearchQuery;
  String? get selectedTagFilter => _selectedTagFilter;
  PollsState get state => _state;
  List<Poll> get allPolls => _allPolls;
  String get errorMessage => _errorMessage;
  Map<String, String> get votedOptionsMap => _votedOptionsMap;

  // constructor -> get repository
  PollsProvider(this._repository);

  // fetch and search polls function
  Future<void> searchPolls({String? query, String? tag}) async {
    _state = PollsState.Loading;
    notifyListeners();

    final user = FirebaseAuth.instance.currentUser;
    _currentSearchQuery = query?.trim() ?? '';
    _selectedTagFilter = tag;

    try {
      // get List<Poll> from repository
      final polls = await _repository.fetchPolls(
          query: query,
          tag: tag,
          //userId: user?.uid
      );

      // update voting status (from repository)
      if (user != null) {
        _votedOptionsMap = await _repository.fetchUserVotedOptions(user.uid);
        notifyListeners();
      } else {
        _votedOptionsMap = {};
      }

      _allPolls = polls;
      _state = PollsState.Loaded;

    } catch (e) {
      _errorMessage = e.toString();
      _state = PollsState.Error;
    }
    notifyListeners();
  }

  // load all polls
  Future<void> fetchPolls() async {
    return searchPolls(query: '', tag: null);
  }

  // create new poll
  Future<void> createNewPoll(Map<String, dynamic> pollData) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final newPoll = Poll(
      id: '', // ID would be defined from Firestore
      title: pollData['title'] as String,
      description: pollData['description'] as String,
      options: List<String>.from(pollData['options'] ?? []),
      totalVotes: 0,
      voteCounts: {},
      authorId: user.uid,
      authorName: user.displayName ?? 'Anonymous',
      tag: pollData['tag'] as String? ?? 'General',
      createdAt: DateTime.now(),
    );

    // call repository for saving
    await _repository.createPoll(newPoll);

    // update the general list
    await fetchPolls();
  }

  Future<void> submitVote(String pollId, String selectedOption) async {
    // call repository for transaction
    await _repository.submitVoteTransaction(pollId, selectedOption);

    // after successful transaction - update list
    await fetchPolls();
  }

  // edit poll method
  Future<void> updateExistingPoll(Poll updatedPoll) async {
    // check if there is no votes
    if (updatedPoll.totalVotes > 0) {
      throw Exception("Cannot edit poll that already has votes.");
    }

    _state = PollsState.Loading;
    notifyListeners();

    try {
      await _repository.updatePoll(updatedPoll);

      //update general list
      await fetchPolls();

    } catch (e) {
      _errorMessage = 'Failed to update poll: $e';
      _state = PollsState.Error;
      notifyListeners();
      rethrow;
    }
  }

  // delete method
  Future<void> deletePoll(String pollId, int totalVotes) async {
    // check if there is no votes
    if (totalVotes > 0) {
      throw Exception("Cannot delete poll that already has votes.");
    }

    _state = PollsState.Loading;
    notifyListeners();

    try {
      await _repository.deletePoll(pollId);

      //update the general list
      await fetchPolls();

    } catch (e) {
      _errorMessage = 'Failed to delete poll: $e';
      _state = PollsState.Error;
      notifyListeners();
      rethrow;
    }
  }
}