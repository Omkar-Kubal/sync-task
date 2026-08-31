import 'package:flutter/material.dart';

SnackBar undoSnackBar({
  required String message,
  required VoidCallback onUndo,
}) {
  return SnackBar(
    content: Text(message),
    action: SnackBarAction(label: 'Undo', onPressed: onUndo),
  );
}
