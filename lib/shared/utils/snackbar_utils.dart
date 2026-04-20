import 'package:flutter/material.dart';

class SnackBarUtils {
  static void show(
    BuildContext context,
    String message, {
    bool isError = false,
    IconData? icon,
  }) {
    // Ocultar cualquier SnackBar anterior
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ??
                    (isError
                        ? Icons.error_outline
                        : Icons.check_circle_outline),
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade900 : Colors.green.shade900,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: 24,
          left: MediaQuery.of(context).size.width > 600
              ? MediaQuery.of(context).size.width * 0.3
              : 24,
          right: MediaQuery.of(context).size.width > 600
              ? MediaQuery.of(context).size.width * 0.3
              : 24,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        elevation: 0,
        duration: const Duration(seconds: 3),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
