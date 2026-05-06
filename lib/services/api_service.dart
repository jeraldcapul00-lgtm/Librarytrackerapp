// lib/services/api_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;

class ApiService {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:5000';
    return 'http://10.0.2.2:5000';
  }

  static Dio get _dio => Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      validateStatus: (status) => true,
    ),
  );

  // ── GET BOOKS ─────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getBooks() async {
    try {
      final response = await _dio.get('/api/Book/all');

      if (response.statusCode == 200) {
        final body = response.data;

        if (body is Map && body['data'] is List) {
          return (body['data'] as List)
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }

        if (body is List) {
          return body.map((e) => Map<String, dynamic>.from(e)).toList();
        }
      }

      return [];
    } catch (e) {
      debugPrint('getBooks error: $e');
      return [];
    }
  }

  // ── BORROW BOOK ───────────────────────────────────────────
  static Future<bool> borrowBook({
    required int studentId,
    required int bookId,
    required int quantity,
  }) async {
    try {
      final now = DateTime.now().toIso8601String();
      final due = DateTime.now()
          .add(const Duration(days: 14))
          .toIso8601String();

      final response = await _dio.post(
        '/api/Transaction/borrow',
        data: {
          "studentID": studentId,
          "bookID": bookId,
          "borrowDate": now,
          "returnDate": due,
          "quantity": quantity,
          "type": "Borrow",
          "status": "Active",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = response.data;
        if (body is Map && body.containsKey('success')) {
          return body['success'] == true;
        }
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('borrowBook error: $e');
      return false;
    }
  }

  // ── GET ALL TRANSACTIONS ──────────────────────────────────
  static Future<List<Map<String, dynamic>>> getTransactions() async {
    try {
      final response = await _dio.get('/api/Transaction');

      if (response.statusCode == 200) {
        final body = response.data;

        if (body is Map && body['data'] is List) {
          return (body['data'] as List)
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }

        if (body is List) {
          return body.map((e) => Map<String, dynamic>.from(e)).toList();
        }
      }

      return [];
    } catch (e) {
      debugPrint('getTransactions error: $e');
      return [];
    }
  }

  // ── ✅ GET MY BORROWS ─────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getMyBorrows(int studentId) async {
    try {
      final response = await _dio.get('/api/Transaction');

      if (response.statusCode != 200) return [];

      final body = response.data;

      List rawList = [];

      if (body is Map && body['data'] is List) {
        rawList = body['data'];
      } else if (body is List) {
        rawList = body;
      }

      final now = DateTime.now();

      final myBorrows = rawList
          .map((e) => Map<String, dynamic>.from(e))
          // ✅ SAFE student filter
          .where((t) => (t['studentID'] ?? t['studentId']) == studentId)
          // ✅ SAFE mapping
          .map((t) {
            final borrowDate = DateTime.tryParse(t['borrowDate'] ?? '');
            final returnDate = DateTime.tryParse(t['returnDate'] ?? '');

            final rawStatus = (t['status'] ?? '').toString().toLowerCase();

            final isReturned = rawStatus.contains('return');
            final isActive =
                rawStatus.contains('active') || rawStatus.contains('borrow');

            final isOverdue =
                isActive && returnDate != null && returnDate.isBefore(now);

            return {
              "txnId": t['transactionID'] ?? t['id'],
              "bookId": t['bookID'],
              "bookTitle": t['bookTitle'] ?? "Book #${t['bookID']}",

              "borrowDate": _formatDate(borrowDate),
              "dueDate": _formatDate(returnDate),

              "status": isReturned ? "Returned" : "Borrowed",
              "isOverdue": isOverdue,

              "raw": t,
            };
          })
          .toList();

      return myBorrows;
    } catch (e) {
      debugPrint('getMyBorrows error: $e');
      return [];
    }
  }

  // ── DATE FORMAT ───────────────────────────────────────────
  static String _formatDate(DateTime? d) {
    if (d == null) return "N/A";

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return "${months[d.month - 1]} ${d.day}, ${d.year}";
  }
}
