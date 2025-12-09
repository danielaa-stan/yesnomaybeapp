import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../providers/polls_provider.dart';
import '../models/poll.dart';
import '../widgets/navigationbar.dart';
import '../l10n/app_localizations.dart';

class EditPollPage extends StatefulWidget {
  // get the Poll object for editing
  final Poll pollToEdit;

  const EditPollPage({Key? key, required this.pollToEdit}) : super(key: key);

  @override
  State<EditPollPage> createState() => _EditPollPageState();
}

class _EditPollPageState extends State<EditPollPage> {
  // controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [];

  final List<String> _tags = [
    'Sports', 'Fashion', 'Travelling', 'Food', 'Books', 'Arts',
    'Social/Volunteering', 'Hiking', 'Computer Science', 'Movies/TV shows',
    'Music', 'Life choices',
  ];

  String? _selectedTag;

  @override
  void initState() {
    super.initState();
    // initialization -> fill up the fields with existing data
    _titleController.text = widget.pollToEdit.title;
    _descriptionController.text = widget.pollToEdit.description;
    _selectedTag = widget.pollToEdit.tag;
    for (var option in widget.pollToEdit.options) {
      _optionControllers.add(TextEditingController(text: option));
    }

    // add minimum 2 empty options controllers if there aren't any
    if (_optionControllers.length < 2) {
      _optionControllers.add(TextEditingController());
      _optionControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addOptionField() {
    setState(() {
      _optionControllers.add(TextEditingController());
    });
  }

  // save button handling for update
  void _handleSaveUpdate() async {
    final l10n = AppLocalizations.of(context)!;
    if (_titleController.text
        .trim()
        .isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.enterTitle)));
      return;
    }
    final validOptions = _optionControllers.where((c) => c.text
        .trim()
        .isNotEmpty).map((c) => c.text.trim()).toList();
    if (validOptions.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.provideAtLeast2Options)));
      return;
    }

    // create new Poll object (with existing ID)
    final updatedPoll = Poll(
      id: widget.pollToEdit.id,
      // save the existing poll ID
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      options: validOptions,
      tag: _selectedTag ?? widget.pollToEdit.tag,

      //save the existing poll data
      totalVotes: widget.pollToEdit.totalVotes,
      voteCounts: widget.pollToEdit.voteCounts,
      authorId: widget.pollToEdit.authorId,
      authorName: widget.pollToEdit.authorName,
      createdAt: widget.pollToEdit.createdAt,
    );

    // Provider call for updating
    final provider = Provider.of<PollsProvider>(context, listen: false);

    try {
      await provider.updateExistingPoll(updatedPoll);

      // Analytics
      FirebaseAnalytics.instance.logEvent(name: 'poll_updated');

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.pollSuccessfullyUpdated)));
      // return to UserProfilePage
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorUpdatingPoll)));
    }
  }
  // Helper widget to build the text fields
  Widget _buildTextField({
    TextEditingController? controller,
    required String hintText,
    required int maxLines,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                l10n.editPoll,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A4D4D),
                ),
              ),
              const SizedBox(height: 30),

              Text(l10n.giveSomeDetails, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A4D4D))),
              const SizedBox(height: 10),

              // Title Input Field
              _buildTextField(controller: _titleController, hintText: l10n.pollTitleHint, maxLines: 1),
              const SizedBox(height: 15),
              // Description Input Field
              _buildTextField(controller: _descriptionController, hintText: l10n.pollDescriptionHint, maxLines: 3),
              const SizedBox(height: 15),

              // Poll Options Input Fields
              ..._optionControllers.asMap().entries.map((entry) {
                int idx = entry.key;
                TextEditingController controller = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: _buildTextField(controller: controller, hintText: '${l10n.pollOption} ${idx + 1}', maxLines: 1),
                );
              }).toList(),

              // Add Option Button
              TextButton.icon(
                onPressed: _addOptionField,
                icon: const Icon(Icons.add, color: Color(0xFF4EE06D)),
                label: Text(l10n.buttonAddOption, style: TextStyle(color: Color(0xFF4EE06D))),
              ),
              const SizedBox(height: 30),

              // Tag Selection Header
              Text(l10n.selectTag, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A4D4D))),
              const SizedBox(height: 10),

              // Tags Wrap
              Wrap(
                spacing: 10, runSpacing: 10,
                children: _tags.map((tag) {
                  final isSelected = _selectedTag == tag;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTag = isSelected ? null : tag;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF4EE06D) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSelected ? const Color(0xFF4EE06D) : Colors.grey.shade300),
                      ),
                      child: Text(tag, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF1A4D4D), fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 50),

              // Post and Cancel Buttons
              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        side: const BorderSide(color: Color(0xFF1A4D4D), width: 2),
                      ),
                      child: Text(l10n.cancelButton, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A4D4D))),
                    ),
                  ),
                  const SizedBox(width: 15),

                  // Save Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _handleSaveUpdate, // calls ANALYTICS
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A4D4D),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: Text(l10n.saveButton, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 50),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }
}