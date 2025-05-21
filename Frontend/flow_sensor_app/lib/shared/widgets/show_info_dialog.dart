import 'package:flutter/material.dart';

void showInfoDialog(
  BuildContext context, {
  required String title,
  Widget? content,
  Color iconColor = Colors.blue,
}) {
  showDialog(
    context: context,
    builder:
        (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.info_outline, color: iconColor),
              const SizedBox(width: 8),
              Flexible(child: Text(title, style: TextStyle(color: iconColor))),
            ],
          ),
          content: content,
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: iconColor),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cerrar"),
            ),
          ],
        ),
  );
}
