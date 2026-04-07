import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GratitudeJournal extends StatefulWidget {
  final String? existingEntry;
  final ValueChanged<String> onSave;

  const GratitudeJournal({
    super.key,
    this.existingEntry,
    required this.onSave,
  });

  @override
  State<GratitudeJournal> createState() => _GratitudeJournalState();
}

class _GratitudeJournalState extends State<GratitudeJournal> {
  late final TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.existingEntry ?? '');
    // If no existing entry, start in edit mode
    _isEditing = widget.existingEntry == null || widget.existingEntry!.isEmpty;
  }

  @override
  void didUpdateWidget(covariant GratitudeJournal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.existingEntry != oldWidget.existingEntry) {
      _controller.text = widget.existingEntry ?? '';
      _isEditing =
          widget.existingEntry == null || widget.existingEntry!.isEmpty;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _hasText => _controller.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        const Text(
          'Gratitude Journal',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'What are you grateful for today?',
          style: TextStyle(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),

        if (_isEditing) ...[
          // Editable text field
          TextField(
            controller: _controller,
            maxLines: 3,
            minLines: 2,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.text,
              height: 1.4,
            ),
            decoration: InputDecoration(
              hintText: 'I am grateful for...',
              hintStyle: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 15,
              ),
              filled: true,
              fillColor: AppColors.background,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.accent, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Save button — only visible when text is entered
          if (_hasText)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  widget.onSave(_controller.text.trim());
                  setState(() => _isEditing = false);
                },
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Save'),
              ),
            ),
        ] else ...[
          // Read-only display of existing entry
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              _controller.text,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.text,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => setState(() => _isEditing = true),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit_outlined, size: 16),
                  SizedBox(width: 6),
                  Text('Edit'),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
