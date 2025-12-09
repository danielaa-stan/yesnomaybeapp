import 'package:flutter/material.dart';
import 'poll_results_view.dart';
import 'package:yesnomaybeapp/l10n/app_localizations.dart';

class PollCard extends StatefulWidget {
  // widget parameters
  final String question;
  final String subtitle;
  final int votes;
  final String date;
  final Color? color;

  final bool isVoted;
  final ValueChanged<String>? onVoteSubmitted; // Callback for sending the vote
  final List<String> options; // options for expanded view

  final ValueChanged<bool>? onExpansionChanged; // Callback for parent widget
  final bool isExpanded; // external state: managing parent widget

  //new parameters for displaying the results
  final Map<String, int>? voteResults;
  final int totalVotes;
  final String? userVotedOption;

  // flag to show if this is the authr
  final bool canEditDelete;

  // Callbacks for Edit/Delete
  final VoidCallback? onEditTapped;
  final VoidCallback? onDeleteTapped;

  const PollCard({
    Key? key,
    required this.question,
    required this.subtitle,
    required this.votes,
    required this.date,
    required this.options,
    this.onExpansionChanged,
    required this.isExpanded,
    required this.isVoted,
    this.onVoteSubmitted,
    this.voteResults,
    this.totalVotes = 0,
    this.userVotedOption,
    this.canEditDelete = false,
    this.onEditTapped,
    this.onDeleteTapped,
    this.color,
  }) : super(key: key);

  @override
  State<PollCard> createState() => _PollCardState();
}

class _PollCardState extends State<PollCard> {
  // internal state - only for chosen option (Radio selection)
  String? _selectedOption;
  //BUILDERS
  // expanded card view (options and "Make your pick" button)
  Widget _buildExpandedContent() {
    final l10n = AppLocalizations.of(context)!;
    if (widget.isVoted) {
      if (widget.voteResults == null || widget.totalVotes == 0) {
        return Padding(
          padding: EdgeInsets.only(top: 10, bottom: 20),
          child: Center(
            child: Text(l10n.resultsAreProcessing, style: TextStyle(color: Colors.grey)),
          ),
        );
      }

      //use PollResultsView for displaying progress bars
      return Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        child: PollResultsView(
          pollResults: widget.voteResults!,
          totalVotes: widget.totalVotes,
          options: widget.options,
          userVotedOption: widget.userVotedOption,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),

        //displaying all the options
        ...widget.options.map((option) {
          final isSelected = _selectedOption == option;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedOption = isSelected ? null : option;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.grey.shade300 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(option, style: TextStyle(fontSize: 16, color: const Color(0xFF1A4D4D), fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
              ),
            ),
          );
        }).toList(),

        const SizedBox(height: 15),

        //"Make your pick" button
        Center(
          child: SizedBox(
            width: 150,
            child: ElevatedButton(
              onPressed: () {
                // call callback and pass the chosen option
                if (_selectedOption != null) {
                  // onVoteSubmitted запустить логіку Firestore в батьківському віджеті
                  widget.onVoteSubmitted?.call(_selectedOption!);

                  // close the card after sending the vote
                  widget.onExpansionChanged?.call(false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A4D4D),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(l10n.makePickButton, style: TextStyle(fontSize: 14, color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }

  //MAIN BUILD
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.question,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A4D4D)),
              ),
              // green checkmark for voted poll
              if (widget.isVoted)
                const Icon(Icons.check_circle, size: 20, color: Colors.green),

              // Edit/Delete buttons (if it is the author and there is no votes yet)
              if (widget.canEditDelete) ...[
                const SizedBox(width: 8),

                // Edit button
                GestureDetector(
                  onTap: widget.onEditTapped,
                  child: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF1A4D4D)),
                ),
                const SizedBox(width: 8),

                // Delete button
                GestureDetector(
                  onTap: widget.onDeleteTapped,
                  child: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),

          // Sub Header / Description
          Text(widget.subtitle, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          const SizedBox(height: 16),

          // conditional display
          if (widget.isExpanded) _buildExpandedContent(),

          // LOWER INFO ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Votes amount & Date
              Row(
                children: [
                  Icon(Icons.people_outline, size: 18, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(widget.votes.toString(), style: TextStyle(fontSize: 14, color: Colors.grey[600])),

                  const SizedBox(width: 15),
                  Text(widget.date, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                ],
              ),

              // More / Less Button
              GestureDetector(
                onTap: () {
                  // call callback so the parent could update the state
                  widget.onExpansionChanged?.call(!widget.isExpanded);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: widget.color ?? const Color(0xFF4EE06D),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Text(
                        // button text change
                        widget.isExpanded ? l10n.lessButton : l10n.moreButton,
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        // button icon change
                        widget.isExpanded ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 12,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}