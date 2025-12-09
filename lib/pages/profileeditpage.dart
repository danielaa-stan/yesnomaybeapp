import 'package:flutter/material.dart';
import 'package:yesnomaybeapp/auth.dart'; // Для функції signOut
import 'package:firebase_auth/firebase_auth.dart'; // Для User?
import '../widgets/navigationbar.dart';
import 'package:yesnomaybeapp/widget_tree.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as SB;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:yesnomaybeapp/main.dart';

class ProfileEditPage extends StatefulWidget {
  // inherit previous data
  final Set<String> currentInterests;
  final String currentLanguage;
  final String currentBio;

  const ProfileEditPage({
    Key? key,
    required this.currentInterests,
    required this.currentLanguage,
    required this.currentBio,
  }) : super(key: key);

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}


const List<String> kAllAvailableInterests = [
  'Sports', 'Fashion', 'Travelling', 'Food', 'Books', 'Arts',
  'Social/Volunteering', 'Hiking', 'Computer Science',
  'Movies/TV shows', 'Music', 'Life choices',
];

const Map<String, String> kAvailableLanguages = {
  'en': 'English (UK)',
  'uk': 'Українська',
};

class _ProfileEditPageState extends State<ProfileEditPage> {
  // GlobalKey for name validation
  final _formKey = GlobalKey<FormState>();

  //name controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  // local state for interests and language
  late Set<String> _selectedInterests;
  late String _preferredLanguage;
  final String _currentBioText = 'This is all about you';

  final ImagePicker _picker = ImagePicker();
  final SB.SupabaseClient _supabaseClient = SB.Supabase.instance.client;

  //final User? user = Auth().currentUser;
  User? get user => FirebaseAuth.instance.currentUser;


  @override
  void initState() {
    super.initState();
    // initializing fields from Firebase
    _selectedInterests = Set.from(widget.currentInterests);
    _preferredLanguage = _languageNameToCode(widget.currentLanguage);
    _nameController.text = user?.displayName ?? user?.email?.split('@').first ?? 'Unknown';
    _bioController.text = widget.currentBio;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  String _languageNameToCode(String name) {
    // get the code by name
    final code = kAvailableLanguages.entries
        .firstWhere((entry) => entry.value == name, orElse: () => kAvailableLanguages.entries.first)
        .key;
    return code;
  }

//firebase logic
  Future<void> _handleSignOut() async {
    await Auth().signOut();

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        // go to new instance of WidgetTree, which redirects to LoginPage
        MaterialPageRoute(builder: (context) => const WidgetTree()),
            (Route<dynamic> route) => false, // the flag removes all previous routes
      );
    }
  }

  Future<void> _uploadImage() async {
    final l10n = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || !mounted) return;

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final String fileName = '${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String filePath = '${user.uid}/$fileName';

      try {
        // show the load happenning
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.uploadingPhoto)),
        );

        // read file as bytes
        final bytes = await File(image.path).readAsBytes();

        // upload with uploadBinary
        await _supabaseClient.storage
            .from('profile_photos')
            .uploadBinary(
          filePath,
          bytes,
          fileOptions: SB.FileOptions(
            contentType: 'image/jpeg',
            upsert: true,
          ),
        );

        // get the public URL
        final String imageUrl = _supabaseClient.storage
            .from('profile_photos')
            .getPublicUrl(filePath);

        print('Image uploaded: $imageUrl');

        // update Firebase Auth
        await user.updatePhotoURL(imageUrl);
        await user.reload();

        if (mounted) {
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.uploadPhotoSuccess),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        print('❌ Upload error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.uploadPhotoFail),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      final newName = _nameController.text.trim();
      final newBio = _bioController.text.trim();
      final currentUser = Auth().currentUser;

      if (currentUser != null) {
        // name update in Firebase
        currentUser.updateDisplayName(newName);

        //savin bio and interests to firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .set({
          'bio': newBio,
          // turn Set<String> into List<String> for Firestore
          'interests': _selectedInterests.toList(),
          'preferredLanguageCode': _preferredLanguage,
          'updated_at': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true)); // `merge: true` allows to update only these fields
      }

      MyApp.setLocale(context, Locale(_preferredLanguage, ''));

      // create result map for returning
      final Map<String, dynamic> result = {
        'name': newName,
        'interests': _selectedInterests,
        'bio': newBio,
        'language': kAvailableLanguages[_preferredLanguage],
      };

      // return updated data
      Navigator.pop(context, result);
    }
  }

  void _removeInterest(String label) {
    setState(() {
      _selectedInterests.remove(label);
    });
  }

  //builders
  Widget _buildInterestChip(String label) {
    // GestureDetector calls delete on tap
    return GestureDetector(
      onTap: () => _removeInterest(label),
      child: Container(
        margin: const EdgeInsets.only(right: 8, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(color: Color(0xFF1A4D4D)),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.close, // use icon for closing
              size: 14,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  // profile_edit_page.dart (у _ProfileEditPageState)

  void _showInterestsPicker() {
    final l10n = AppLocalizations.of(context)!;
    Set<String> tempSelectedInterests = Set.from(_selectedInterests);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // adds to get more space
      builder: (BuildContext context) {
        return StatefulBuilder(
          // use StatefulBuilder for managing just inside the dialogue
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              height: MediaQuery.of(context).size.height * 0.7, // 70% of screen height
              child: Column(
                children: <Widget>[
                  Text(
                    l10n.selectMoreInterests,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  Expanded(
                    child: ListView.builder(
                      itemCount: kAllAvailableInterests.length,
                      itemBuilder: (context, index) {
                        final interest = kAllAvailableInterests[index];
                        final isSelected = tempSelectedInterests.contains(interest);

                        return CheckboxListTile(
                          title: Text(interest),
                          value: isSelected,
                          onChanged: (bool? value) {
                            setModalState(() {
                              if (value == true) {
                                tempSelectedInterests.add(interest);
                              } else {
                                tempSelectedInterests.remove(interest);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // update the general page state
                      setState(() {
                        _selectedInterests = tempSelectedInterests;
                      });
                      // close modal
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4EE06D),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Text(l10n.interestsConfirmButton, style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const Color headerColor = Color(0xFF205F5F);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Section (Dark Teal)
              Container(
                color: headerColor,
                padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 40),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      // Top Icons (Back, Notification, Edit)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildHeaderIcon(Icons.arrow_back, () => Navigator.pop(context)),
                          _buildHeaderIcon(Icons.edit_outlined, () => _handleSave()),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // Profile Image
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        backgroundImage: user?.photoURL != null
                            ? NetworkImage(user!.photoURL!)
                            : null,
                        child: user?.photoURL == null
                            ? const Icon(Icons.person, size: 60, color: Colors.grey)
                            : null,
                      ),

                      // Change Photo Button
                      TextButton(
                        onPressed: _uploadImage,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(80, 20),
                        ),
                        child: Text(l10n.changePhotoButton, style: TextStyle(color: Color(0xFF4EE06D), fontSize: 12)),
                      ),

                      // Username Field with Validation
                      TextFormField(
                        controller: _nameController,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        decoration: InputDecoration(
                          hintText: l10n.nameHint,
                          hintStyle: TextStyle(color: Colors.white70),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.nameCannotBeEmpty;
                          }
                          if (value.length < 3) {
                            return l10n.nameMustBeAtLeast3Characters;
                          }
                          return null;
                        },
                      ),

                      // User Handle
                      Text(
                        '@${user?.email?.split('@').first ?? 'somebody'}',
                        style: const TextStyle(fontSize: 16, color: Color(0xFF4EE06D)),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Content Section (White Background)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bio Section
                    // Bio Section Title
                    Text(l10n.profileBioTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A4D4D))),
                    const SizedBox(height: 8),

                    // bio input field
                    TextFormField(
                      controller: _bioController,
                      maxLines: 4, // allow up to 4 lines
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                      decoration: InputDecoration(
                        hintText: l10n.profileBioPlaceholder,
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                      // Bio is not necessary, so the validator is not needed
                    ),
                    const SizedBox(height: 30),

                    // Chosen Interests
                    Text(l10n.chosenInterests, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A4D4D))),
                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        // Display user's chosen interests
                        ..._selectedInterests.map((label) => _buildInterestChip(label)),

                        // Add more button
                        ElevatedButton(
                          onPressed: () {
                            _showInterestsPicker();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4EE06D),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            minimumSize: Size.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: Text(l10n.addMoreInterests, style: TextStyle(color: Colors.white, fontSize: 14)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // preferred language section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.languageTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A4D4D))),
                        // DropdownButton for choosing language
                        DropdownButton<String>(
                          value: _preferredLanguage,
                          items: kAvailableLanguages.entries.map((entry) {
                            return DropdownMenuItem<String>(
                              value: entry.key, // 'en' або 'uk'
                              child: Text(entry.value, style: TextStyle(color: Color(0xFF1A4D4D)),), // 'English (UK)' or 'Українська'
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _preferredLanguage = newValue;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // SAVE Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _handleSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A4D4D),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: Text(l10n.saveButton, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // LOG OUT Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _handleSignOut,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Color(0xFF1A4D4D), width: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: Text(l10n.logoutButton, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A4D4D))),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // Bottom navigation bar must be included to avoid conflicts
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }

  // Reusing the header icon builder
  Widget _buildHeaderIcon(IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 28),
        onPressed: onTap,
      ),
    );
  }
}