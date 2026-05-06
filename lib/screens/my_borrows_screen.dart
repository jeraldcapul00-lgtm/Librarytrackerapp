import 'package:flutter/material.dart';
import '../data/user_session.dart';
import '../services/api_service.dart';
import '../theme/app_styles.dart';

class MyBorrowsScreen extends StatefulWidget {
  const MyBorrowsScreen({super.key});

  @override
  State<MyBorrowsScreen> createState() => _MyBorrowsScreenState();
}

class _MyBorrowsScreenState extends State<MyBorrowsScreen> {
  List<Map<String, dynamic>> _borrows = [];
  bool _isLoading = true;

  int total = 0;
  int active = 0;
  int returned = 0;
  int overdue = 0;

  @override
  void initState() {
    super.initState();
    _loadBorrows();
  }

  Future<void> _loadBorrows() async {
    setState(() => _isLoading = true);

    final data = await ApiService.getMyBorrows(Session.studentId ?? 0);

    if (!mounted) return;

    _borrows = data;

    total = data.length;
    active = data.where((b) => b['status'] == 'Borrowed').length;
    returned = data.where((b) => b['status'] == 'Returned').length;
    overdue = data.where((b) => b['isOverdue'] == true).length;

    setState(() => _isLoading = false);
  }

  // ── HEADER ───────────────────────────────────────────────
  Widget _header() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1B3A2E), Color(0xFF2D5A41)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.menu_book, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text(
                    "LibraryTrack",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _loadBorrows,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text("Refresh"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                "📦 My Borrowed Books",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                "Your borrow history and statuses",
                style: TextStyle(color: Colors.white60),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── SUMMARY CARDS ─────────────────────────────────────────
  Widget _stats() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _statCard("All", total),
          _statCard("Active", active),
          _statCard("Returned", returned),
          _statCard("Overdue", overdue),
        ],
      ),
    );
  }

  Widget _statCard(String label, int value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8),
          ],
        ),
        child: Column(
          children: [
            Text(
              "$value",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // ── BORROW LIST ───────────────────────────────────────────
  Widget _borrowList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_borrows.isEmpty) {
      return const Center(child: Text("No borrow records found."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _borrows.length,
      itemBuilder: (_, i) {
        final b = _borrows[i];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
            ],
          ),
          child: Row(
            children: [
              // LEFT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      b['bookTitle'] ?? 'Unknown Book',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Borrowed: ${b['borrowDate']}",
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      "Due: ${b['dueDate']}",
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),

              // STATUS
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: b['status'] == 'Returned'
                      ? Colors.grey[300]
                      : Colors.green[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  b['status'] ?? 'Borrowed',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: b['status'] == 'Returned'
                        ? Colors.black54
                        : Colors.green,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── BUILD ────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.creamBackground,
      body: Column(
        children: [
          _header(),
          _stats(),
          Expanded(child: _borrowList()),
        ],
      ),
    );
  }
}
