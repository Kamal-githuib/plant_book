import 'package:flutter/material.dart';
import 'package:plant_book/provider/comment&report_provider.dart';
import 'package:plant_book/styles/apptheme.dart';
import 'package:provider/provider.dart';

class ReportDialog extends StatefulWidget {
  final Map<String, dynamic> post;

  const ReportDialog({super.key, required this.post});

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  String selectedReason = 'Inappropriate content';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final reportProvider = Provider.of<CommentProvider>(context, listen: false);

    return AlertDialog(
      backgroundColor: AppTheme.darkGray,
      elevation: 5,
      title: Text('Report Post', style: TextStyle(color: AppTheme.lightGray)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButton<String>(
            dropdownColor: AppTheme.darkGray,
            value: selectedReason,
            items: const [
              DropdownMenuItem(
                value: 'Inappropriate content',
                child: Text(
                  'Inappropriate content',
                  style: TextStyle(color: AppTheme.lightGray),
                ),
              ),
              DropdownMenuItem(
                value: 'Spam or misleading',
                child: Text(
                  'Spam or misleading',
                  style: TextStyle(color: AppTheme.lightGray),
                ),
              ),
              DropdownMenuItem(
                value: 'Hate speech or abuse',
                child: Text(
                  'Hate speech or abuse',
                  style: TextStyle(color: AppTheme.lightGray),
                ),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedReason = value;
                });
              }
            },
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: CircularProgressIndicator(color: AppTheme.green),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.red)),
        ),
        TextButton(
          onPressed: _isLoading
              ? null
              : () async {
                  setState(() => _isLoading = true);
                  try {
                    await reportProvider.reportPost(
                      postId: widget.post['id'],
                      postData: widget.post,
                      reason: selectedReason,
                    );

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Report submitted')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to submit report')),
                    );
                  } finally {
                    setState(() => _isLoading = false);
                  }
                },
          child: const Text('Report', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
