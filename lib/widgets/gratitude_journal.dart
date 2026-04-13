import 'package:flutter/cupertino.dart';
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
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),

        if (_isEditing) ...[
          // Editable text field
          CupertinoTextField(
            controller: _controller,
            maxLines: 3,
            minLines: 2,
            onChanged: (_) => setState(() {}),
            placeholder: 'I am grateful for...',
            placeholderStyle: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 15,
            ),
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.text,
              height: 1.4,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 12),

          // Save button
          if (_hasText)
            Align(
              alignment: Alignment.centerRight,
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 8),
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(20),
                minimumSize: const Size(44, 36),
                onPressed: () {
                  widget.onSave(_controller.text.trim());
                  setState(() => _isEditing = false);
                },
                child: const Text(
                  'Save',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.white,
                  ),
                ),
              ),
            ),
        ] else ...[
          // Read-only display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
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
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              onPressed: () => setState(() => _isEditing = true),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(CupertinoIcons.pencil, size: 15, color: AppColors.accent),
                  SizedBox(width: 6),
                  Text(
                    'Edit',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
