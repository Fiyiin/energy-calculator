import 'package:flutter/material.dart';

class Decorations {
  static InputDecoration formInputDecoration(BuildContext context) {
    final theme = Theme.of(context);
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      filled: theme.brightness == Brightness.dark ? false : true,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      labelStyle: TextStyle(
        fontSize: 16,
        color: theme.brightness == Brightness.dark
            ? Colors.white.withOpacity(0.38)
            : Colors.black.withOpacity(0.50),
      ),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(8.0),
        ),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(8),
        ),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.secondary,
          width: 2.0,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(8.0),
        ),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.error,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(8.0),
        ),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.error,
        ),
      ),
    );
  }

  static InputDecoration dropDownDecoration(BuildContext context) {
    final theme = Theme.of(context);
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 2, vertical: 12),
      filled: theme.brightness == Brightness.dark ? false : true,
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(8.0),
        ),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(8),
        ),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.secondary,
          width: 2.0,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(8.0),
        ),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.error,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(8.0),
        ),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.error,
        ),
      ),
    );
  }
}
