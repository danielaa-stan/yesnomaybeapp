import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/poll.dart';

abstract class PollsRepository {
  Future<List<Poll>> fetchPolls({String? query, String? tag});
  Future<void> createPoll(Poll poll);
  Future<void> submitVoteTransaction(String pollId, String selectedOption);
  Future<Map<String, String>> fetchUserVotedOptions(String userId);
  Future<void> updatePoll(Poll poll);
  Future<void> deletePoll(String pollId);
}

class FirestorePollsRepository implements PollsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<Map<String, String>> fetchUserVotedOptions(String userId) async {
    final votedSnapshot = await _firestore.collection('user_votes')
        .where('user_id', isEqualTo: userId)
        .get();

    return {
      for (var doc in votedSnapshot.docs)
        (doc.data()['poll_id'] as String): (doc.data()['option_voted_for'] as String)
    };
  }

  // update poll method
  @override
  Future<void> updatePoll(Poll poll) async {
    if (poll.id.isEmpty) {
      throw Exception("Cannot update poll: ID is missing.");
    }

    // Poll.toFirestore() has all the fields except for ID
    //use update to save existing counters for votes
    await _firestore.collection('polls').doc(poll.id).update({
      'title': poll.title,
      'description': poll.description,
      'options': poll.options, // options are also updated
      'tag': poll.tag,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  // delete poll method
  @override
  Future<void> deletePoll(String pollId) async {
    // delete the poll itself
    await _firestore.collection('polls').doc(pollId).delete();

    //delete the records about this in user_votes
    final userVotes = await _firestore.collection('user_votes')
        .where('poll_id', isEqualTo: pollId)
        .get();

    for (var doc in userVotes.docs) {
      await doc.reference.delete();
    }
  }

  // fetch/search method
  @override
  Future<List<Poll>> fetchPolls({String? query, String? tag}) async {
    final currentUser = _auth.currentUser;
    // get the map of voted options if the user logged in
    final votedOptionsMap = currentUser != null
        ? await _fetchUserVotedOptions(currentUser.uid)
        : <String, String>{};

    Query pollsRef = _firestore.collection('polls');

    // filter and sort logic
    if (tag != null && tag != 'All') {
      pollsRef = pollsRef.where('tag', isEqualTo: tag);
    }

    if (query != null && query.isNotEmpty) {
      String endText = query + '\uf8ff';
      pollsRef = pollsRef.where('title', isGreaterThanOrEqualTo: query).where('title', isLessThan: endText).orderBy('title', descending: true);
    } else {
      pollsRef = pollsRef.orderBy('created_at', descending: true);
    }

    final snapshot = await pollsRef.get();

    // mapping in the List<Poll> with adding status isVoted and userVotedOption
    return snapshot.docs.map((doc) {
      final pollId = doc.id;
      final isVoted = votedOptionsMap.containsKey(pollId);
      final userVotedOption = votedOptionsMap[pollId];

      return Poll.fromFirestore(
        doc as DocumentSnapshot<Map<String, dynamic>>,
        isVoted: isVoted,
        userVotedOption: userVotedOption,
      );
    }).toList();
  }

  // create poll method
  @override
  Future<void> createPoll(Poll poll) async {
    await _firestore.collection('polls').add(poll.toFirestore());
  }

  // vote method - uses transaction
  @override
  Future<void> submitVoteTransaction(String pollId, String selectedOption) async {
    final userId = _auth.currentUser!.uid;

    await _firestore.runTransaction((transaction) async {
      final userVoteRef = _firestore.collection('user_votes').doc('${pollId}_$userId');

      //check for double vote
      final userVoteDoc = await transaction.get(userVoteRef);
      if (userVoteDoc.exists) {
        throw Exception("User has already voted.");
      }

      //update Polls counters
      final pollRef = _firestore.collection('polls').doc(pollId);
      final pollSnapshot = await transaction.get(pollRef);

      if (!pollSnapshot.exists) {
        throw Exception("Poll does not exist.");
      }

      final currentData = pollSnapshot.data()!;
      final currentTotalVotes = (currentData['total_votes'] as num?)?.toInt() ?? 0;

      // get/create Map vote_counts
      final currentVoteCounts = Map<String, int>.from(currentData['vote_counts'] as Map? ?? {});

      // increase the counter for chosen option
      currentVoteCounts[selectedOption] = (currentVoteCounts[selectedOption] ?? 0) + 1;

      // update the Poll document
      transaction.update(pollRef, {
        'total_votes': currentTotalVotes + 1,
        'vote_counts': currentVoteCounts,
      });

      // save the user voting action
      transaction.set(userVoteRef, {
        'poll_id': pollId,
        'user_id': userId,
        'option_voted_for': selectedOption,
        'voted_at': FieldValue.serverTimestamp(),
      });
    });
  }

  // helper method - load the voted options
  Future<Map<String, String>> _fetchUserVotedOptions(String userId) async {
    final votedSnapshot = await _firestore.collection('user_votes')
        .where('user_id', isEqualTo: userId)
        .get();

    // map the results in Map<PollId, VotedOption>
    return {
      for (var doc in votedSnapshot.docs)
        (doc.data()['poll_id'] as String): (doc.data()['option_voted_for'] as String)
    };
  }

}