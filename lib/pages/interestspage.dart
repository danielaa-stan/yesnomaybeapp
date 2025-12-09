import 'package:flutter/material.dart';
import 'homepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yesnomaybeapp/auth.dart';

class InterestsPage extends StatefulWidget {
  const InterestsPage({Key? key}) : super(key: key);

  @override
  State<InterestsPage> createState() => _InterestsPageState();
}

class _InterestsPageState extends State<InterestsPage> {
  // List to track which interests are selected
  final Set<String> _selectedInterests = {};

  // List of all available interests
  final List<String> _interests = [
    'Sports',
    'Movies/TV shows',
    'Life choices',
    'Food',
    'Books',
    'Fashion',
    'Hiking',
    'Arts',
    'Social/Volunteering',
    'Travelling',
    'Gym & Fitness',
    'Computer science',
    'Music',
  ];

  // Toggle interest selection
  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else {
        _selectedInterests.add(interest);
      }
    });
  }

  void _finishSelection() {
    // use pop for returning chosen Set<String>
    Navigator.pop(context, _selectedInterests);
  }

  //Navigate to home page
  void _goToHomePage() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && _selectedInterests.isNotEmpty) {
      try {
        // saving interests to Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .set({
          'interests': _selectedInterests.toList(), // convert Set to List
          'onboarding_complete': true, // finish flag
          'updated_at': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

      } catch (e) {
        print("Error saving interests to Firestore: $e");
        // no blocking in case of error while saving
      }
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A4D4D), // Dark teal background
      body: SafeArea(
        child: Column(
          children: [
            // Top decorative section with geometric shapes
            Container(
              height: 200,
              width: double.infinity,
              child: Stack(
                children: [
                  // Large yellow circle in center
                  Positioned(
                    left: MediaQuery.of(context).size.width / 2 - 100,
                    top: 80,
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCEF45E),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Purple semi-circle on left
                  Positioned(
                    left: -8,
                    top: 5,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB8A6D9),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Green semi-circle on top right
                  Positioned(
                    right: 8,
                    top: 5,
                    child: Transform.rotate(
                      angle: 2.3,
                      child: ClipRect(
                        child: Align(
                          alignment: Alignment.topRight,
                          widthFactor: 0.5,
                          heightFactor: 1.0,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4EE06D),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Small green square on left bottom
                  Positioned(
                    left: 65,
                    bottom: 5,
                    child: Transform.rotate(
                      angle: 1.0,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4EE06D),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main content area with white background
            Expanded(    //fills all the remaining vertical space
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    // Skip button in top right
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextButton(
                          onPressed: _goToHomePage,
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFF1A4D4D),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Skip',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Title
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        "Decide what's hot",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A4D4D),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Scrollable interests chips
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: _interests.map((interest) {
                            final isSelected = _selectedInterests.contains(interest);
                            return GestureDetector(
                              onTap: () => _toggleInterest(interest),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF4EE06D)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF4EE06D)
                                        : Colors.grey.shade300,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  interest,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF1A4D4D),
                                    fontSize: 16,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    // Bottom navigation buttons
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Back button
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.arrow_back,
                              size: 32,
                              color: Color(0xFF1A4D4D),
                            ),
                          ),

                          // Continue button
                          ElevatedButton(
                            onPressed: _goToHomePage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A4D4D),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: const Text(
                              'CONTINUE',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}