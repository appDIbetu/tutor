import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ExamCodeCard extends StatefulWidget {
  const ExamCodeCard({super.key});

  @override
  State<ExamCodeCard> createState() => _ExamCodeCardState();
}

class _ExamCodeCardState extends State<ExamCodeCard> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _readOnly = true; // Prevents auto keyboard until user taps

  @override
  void initState() {
    super.initState();
    // Prevent programmatic focus by default
    _focusNode.canRequestFocus = false;
    // If focus is lost (e.g., navigate away), lock input again so it won't
    // auto-focus when returning to this screen.
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && !_readOnly) {
        setState(() {
          _readOnly = true;
          _focusNode.canRequestFocus = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      // Let the parent Positioned control horizontal insets exactly.
      margin: EdgeInsets.zero,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your exam code',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textDark,
              ),
            ),
            const Text(
              'To start testing your skill',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    autofocus: false,
                    readOnly: _readOnly,
                    onTap: () {
                      if (_readOnly) {
                        setState(() {
                          _readOnly = false;
                        });
                        // Request focus after enabling editing
                        _focusNode.canRequestFocus = true;
                        Future.microtask(() {
                          FocusScope.of(context).requestFocus(_focusNode);
                        });
                      }
                    },
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      hintText: 'Enter code here',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black26),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black26),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black26,
                          width: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    // Dispatch event placeholder
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text('Enter'),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
