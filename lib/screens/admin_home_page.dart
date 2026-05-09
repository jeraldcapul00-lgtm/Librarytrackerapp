// lib/screens/admin_home_page.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../data/user_session.dart';
import 'login_screen.dart';

// ─── MODELS ───────────────────────────────────────────────────────────────────

class AdminTransaction {
  final int transactionId;
  final int studentId;
  final String studentName;
  final int bookId;
  final String bookTitle;
  final String borrowDate;
  final String dueDate;
  final String status;

  AdminTransaction({
    required this.transactionId,
    required this.studentId,
    required this.studentName,
    required this.bookId,
    required this.bookTitle,
    required this.borrowDate,
    required this.dueDate,
    required this.status,
  });
}

class AdminUser {
  final int studentId;
  final String name;
  final String username;
  final String course;
  final String email;
  final int borrows;
  final int overdue;

  AdminUser({
    required this.studentId,
    required this.name,
    required this.username,
    required this.course,
    required this.email,
    required this.borrows,
    required this.overdue,
  });
}

class AdminBook {
  final int bookId;
  final String title;
  final String author;
  final String genre;
  final int quantity;

  AdminBook({
    required this.bookId,
    required this.title,
    required this.author,
    required this.genre,
    required this.quantity,
  });
}

// ─── ADMIN HOME PAGE ──────────────────────────────────────────────────────────

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  List<AdminTransaction> _transactions = [];
  List<AdminUser> _users = [];
  List<AdminBook> _books = [];
  bool _loading = false;
  String? _error;
  String _txnFilter = 'all';

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
    _fetchAll();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ─── API ──────────────────────────────────────────────────────────────────

  String get _baseUrl =>
      kIsWeb ? 'http://localhost:5000' : 'http://192.168.137.1:5000';

  List<dynamic> _unwrap(dynamic data) {
    if (data == null) return [];
    if (data is List) return data;
    if (data is Map) {
      final inner = data['data'];
      if (inner is List) return inner;
    }
    return [];
  }

  Future<void> _fetchAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          validateStatus: (s) => true,
        ),
      );

      final results = await Future.wait([
        dio.get('$_baseUrl/api/Transaction'),
        dio.get('$_baseUrl/api/Book/all'),
        dio.get('$_baseUrl/Login/GetAllUsers'),
      ]);

      if (!mounted) return;

      final Map<int, String> bookTitles = {};
      final List<AdminBook> books = [];

      for (final b in _unwrap(results[1].data)) {
        if (b is Map) {
          final id = (b['bookID'] ?? 0) as int;
          final title = b['title']?.toString() ?? 'Unknown';
          bookTitles[id] = title;
          books.add(
            AdminBook(
              bookId: id,
              title: title,
              author: b['author']?.toString() ?? '—',
              genre: b['genre']?.toString() ?? '—',
              quantity: (b['quantity'] ?? 0) as int,
            ),
          );
        }
      }

      final List<AdminTransaction> txns = [];
      for (final t in _unwrap(results[0].data)) {
        if (t is Map) {
          final sid = (t['studentID'] ?? 0) as int;
          final bid = (t['bookID'] ?? 0) as int;
          txns.add(
            AdminTransaction(
              transactionId: (t['transactionID'] ?? 0) as int,
              studentId: sid,
              studentName: 'ID $sid',
              bookId: bid,
              bookTitle: bookTitles[bid] ?? 'Book #$bid',
              borrowDate: _fmt(t['borrowDate']),
              dueDate: _fmt(t['returnDate']),
              status: _parseStatus(t['status']?.toString() ?? ''),
            ),
          );
        }
      }

      final Map<int, String> userNames = {};
      final List<AdminUser> users = [];

      for (final u in _unwrap(results[2].data)) {
        if (u is Map) {
          final id = (u['studentId'] ?? u['StudentId'] ?? 0) as int;
          final firstName = u['firstName']?.toString() ?? '';
          final lastName = u['lastName']?.toString() ?? '';
          final fullName = '$firstName $lastName'.trim();
          final displayName = fullName.isEmpty
              ? u['username']?.toString() ?? '—'
              : fullName;
          userNames[id] = displayName;

          final userTxns = txns.where((t) => t.studentId == id).toList();
          users.add(
            AdminUser(
              studentId: id,
              name: displayName,
              username: u['username']?.toString() ?? '—',
              course: u['course']?.toString() ?? '—',
              email: u['email']?.toString() ?? '—',
              borrows: userTxns.length,
              overdue: userTxns.where((t) => t.status == 'overdue').length,
            ),
          );
        }
      }

      final namedTxns = txns
          .map(
            (t) => AdminTransaction(
              transactionId: t.transactionId,
              studentId: t.studentId,
              studentName: userNames[t.studentId] ?? 'ID ${t.studentId}',
              bookId: t.bookId,
              bookTitle: t.bookTitle,
              borrowDate: t.borrowDate,
              dueDate: t.dueDate,
              status: t.status,
            ),
          )
          .toList();

      setState(() {
        _transactions = namedTxns;
        _books = books;
        _users = users;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load data. Please retry.';
        _loading = false;
      });
    }
  }

  Future<void> _returnBook(int transactionId) async {
    try {
      final dio = Dio(BaseOptions(validateStatus: (s) => true));
      final res = await dio.put(
        '$_baseUrl/api/Transaction/return/$transactionId',
      );
      if (!mounted) return;
      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Book returned successfully!'),
            backgroundColor: Color(0xFF1B3A2E),
          ),
        );
        _fetchAll();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to return book.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  static String _fmt(dynamic raw) {
    if (raw == null || raw.toString().isEmpty) return '—';
    try {
      final dt = DateTime.parse(raw.toString());
      const m = [
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
      return '${m[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return raw.toString();
    }
  }

  static String _parseStatus(String raw) {
    final s = raw.toLowerCase();
    if (s.contains('overdue')) return 'overdue';
    if (s.contains('return')) return 'returned';
    return 'borrowed';
  }

  // ─── STATS ────────────────────────────────────────────────────────────────

  int get _totalBooks => _books.length;
  int get _totalUsers => _users.length;
  int get _activeBorrows =>
      _transactions.where((t) => t.status == 'borrowed').length;
  int get _overdueBorrows =>
      _transactions.where((t) => t.status == 'overdue').length;
  int get _returnedBorrows =>
      _transactions.where((t) => t.status == 'returned').length;

  List<AdminTransaction> get _filteredTxns {
    if (_txnFilter == 'all') return _transactions;
    return _transactions.where((t) => t.status == _txnFilter).toList();
  }

  // ─── HELPERS ──────────────────────────────────────────────────────────────

  String get _adminName {
    final name = Session.username ?? 'Admin';
    return name[0].toUpperCase() + name.substring(1).toLowerCase();
  }

  String get _adminInitials {
    final name = Session.username ?? 'A';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length.clamp(1, 2)).toUpperCase();
  }

  String _formattedDate() {
    final now = DateTime.now();
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
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  String _formattedTime() {
    final now = DateTime.now();
    final h = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final m = now.minute.toString().padLeft(2, '0');
    return '$h:$m ${now.hour >= 12 ? 'PM' : 'AM'}';
  }

  // ─── BUILD ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: FadeTransition(opacity: _fadeAnim, child: _buildBody()),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ─── APP BAR ──────────────────────────────────────────────────────────────
  // FIX: Use toolbarHeight + shrink font sizes so ADMINISTRATOR/Admin
  // text column fits without overflowing on narrow phones.

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF0F2318),
      foregroundColor: Colors.white,
      elevation: 0,
      // Slightly taller bar gives the two-line title more breathing room
      toolbarHeight: 52,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Icon(
              Icons.auto_stories,
              color: Color(0xFF52B788),
              size: 16,
            ),
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'LibraryTrack',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 0.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFF52B788).withOpacity(0.25),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: const Text(
                  'ADMIN',
                  style: TextStyle(
                    color: Color(0xFF52B788),
                    fontSize: 7,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      // FIX: Keep ADMINISTRATOR label + Admin name + avatar + logout icon.
      // Reduced font sizes and padding so everything fits on narrow screens.
      actions: [
        // ADMINISTRATOR / Admin name column — kept, just made smaller
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'ADMINISTRATOR',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 7, // reduced from 9 → 7
                letterSpacing: 0.8,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _adminName,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10, // reduced from 12 → 10
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(width: 6),
        // Avatar circle
        GestureDetector(
          onTap: _showLogoutDialog,
          child: Container(
            width: 32, // reduced from 34 → 32
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF52B788),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24, width: 1.5),
            ),
            child: Center(
              child: Text(
                _adminInitials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11, // reduced from 12 → 11
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        // Logout icon
        IconButton(
          onPressed: _showLogoutDialog,
          icon: const Icon(Icons.logout, size: 16, color: Colors.white60),
          tooltip: 'Logout',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
        ),
        const SizedBox(width: 2),
      ],
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F2318),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Session.clear();
              Navigator.pop(ctx);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ─── BOTTOM NAV ───────────────────────────────────────────────────────────

  BottomNavigationBar _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (i) => setState(() => _selectedIndex = i),
      selectedItemColor: const Color(0xFF0F2318),
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      selectedFontSize: 11,
      unselectedFontSize: 10,
      elevation: 12,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.swap_horiz_outlined),
          activeIcon: Icon(Icons.swap_horiz),
          label: 'Transactions',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_outline),
          activeIcon: Icon(Icons.people),
          label: 'Users',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book_outlined),
          activeIcon: Icon(Icons.menu_book),
          label: 'Books',
        ),
      ],
    );
  }

  // ─── BODY ─────────────────────────────────────────────────────────────────

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return _buildTransactions();
      case 2:
        return _buildUsers();
      case 3:
        return _buildBooks();
      default:
        return _buildDashboard();
    }
  }

  // ─── DASHBOARD ────────────────────────────────────────────────────────────

  Widget _buildDashboard() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // HERO — fixed with Column layout to prevent side-by-side overflow
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F2318), Color(0xFF1B3A2E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'ADMIN CONTROL PANEL',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(right: 5),
                            decoration: const BoxDecoration(
                              color: Color(0xFF52B788),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Text(
                            _formattedDate(),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Expanded(
                      child: Text(
                        'Library Overview',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _formattedTime(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Manage books, users, and borrow transactions.',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              children: [
                Row(
                  children: [
                    _statCard(
                      'Total Books',
                      _totalBooks.toString(),
                      Icons.library_books,
                      const Color(0xFF52B788),
                      'In library collection',
                      'Books',
                    ),
                    const SizedBox(width: 10),
                    _statCard(
                      'Registered Users',
                      _totalUsers.toString(),
                      Icons.people,
                      Colors.blueAccent,
                      'Total accounts',
                      'Users',
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _statCard(
                      'Active Borrows',
                      _activeBorrows.toString(),
                      Icons.menu_book,
                      const Color(0xFFD97706),
                      'Currently borrowed',
                      'Active',
                    ),
                    const SizedBox(width: 10),
                    _statCard(
                      'Overdue Books',
                      _overdueBorrows.toString(),
                      Icons.warning_amber_rounded,
                      Colors.redAccent,
                      'Needs attention',
                      'Urgent',
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _statCard(
                      'Returned Books',
                      _returnedBorrows.toString(),
                      Icons.check_circle_outline,
                      Colors.teal,
                      'All time returns',
                      'Done',
                    ),
                    const SizedBox(width: 10),
                    _statCard(
                      'Total Transactions',
                      _transactions.length.toString(),
                      Icons.receipt_long,
                      Colors.purpleAccent,
                      'All records',
                      'Total',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildBorrowStatusCard()),
                    const SizedBox(width: 12),
                    Expanded(child: _buildBooksOverviewCard()),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTransactionCard(limit: 5),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── STAT CARD ────────────────────────────────────────────────────────────

  Widget _statCard(
    String label,
    String value,
    IconData icon,
    Color color,
    String trend,
    String pill,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border(top: BorderSide(color: color, width: 3)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 17),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    pill,
                    style: TextStyle(
                      color: color,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 4),
            Text(trend, style: TextStyle(fontSize: 10, color: color)),
          ],
        ),
      ),
    );
  }

  // ─── BORROW STATUS PIE ────────────────────────────────────────────────────

  Widget _buildBorrowStatusCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(Icons.bar_chart, 'Borrow Status'),
          const SizedBox(height: 12),
          Center(
            child: SizedBox(
              width: 90,
              height: 90,
              child: CustomPaint(
                painter: _PieChartPainter(
                  _activeBorrows,
                  _overdueBorrows,
                  _returnedBorrows,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_transactions.length}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F2318),
                        ),
                      ),
                      const Text(
                        'Total',
                        style: TextStyle(fontSize: 9, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _pieLegend(const Color(0xFF52B788), 'Active', _activeBorrows),
          const SizedBox(height: 4),
          _pieLegend(const Color(0xFFEF4444), 'Overdue', _overdueBorrows),
          const SizedBox(height: 4),
          _pieLegend(const Color(0xFFD1D5DB), 'Returned', _returnedBorrows),
        ],
      ),
    );
  }

  Widget _pieLegend(Color color, String label, int value) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
          ),
        ),
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
      ],
    );
  }

  // ─── BOOKS OVERVIEW PIE ───────────────────────────────────────────────────

  Widget _buildBooksOverviewCard() {
    final available = _books.where((b) => b.quantity > 0).length;
    final outOfStock = _books.where((b) => b.quantity == 0).length;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(Icons.menu_book, 'Books Overview'),
          const SizedBox(height: 12),
          Center(
            child: SizedBox(
              width: 90,
              height: 90,
              child: CustomPaint(
                painter: _BooksPieChartPainter(
                  available,
                  _activeBorrows,
                  outOfStock,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_books.length}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F2318),
                        ),
                      ),
                      const Text(
                        'Books',
                        style: TextStyle(fontSize: 9, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _pieLegend(const Color(0xFF52B788), 'Available', available),
          const SizedBox(height: 4),
          _pieLegend(const Color(0xFFD97706), 'Borrowed', _activeBorrows),
          const SizedBox(height: 4),
          _pieLegend(const Color(0xFFEF4444), 'Out of Stock', outOfStock),
        ],
      ),
    );
  }

  // ─── TRANSACTION CARD ─────────────────────────────────────────────────────

  Widget _buildTransactionCard({int? limit}) {
    final txns = limit != null
        ? _filteredTxns.take(limit).toList()
        : _filteredTxns;

    return Container(
      decoration: _cardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.receipt_long,
                      color: Color(0xFF1B6E2E),
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        limit != null
                            ? 'Recent Transactions'
                            : 'All Borrowed Books',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      Text(
                        '$_activeBorrows active',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F2318).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_transactions.length} records',
                        style: const TextStyle(
                          fontSize: 9,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: _fetchAll,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F2318).withOpacity(0.06),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.refresh,
                          size: 14,
                          color: Color(0xFF0F2318),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterTab('All', 'all'),
                  const SizedBox(width: 6),
                  _filterTab('Borrowed', 'borrowed'),
                  const SizedBox(width: 6),
                  _filterTab('Overdue', 'overdue'),
                  const SizedBox(width: 6),
                  _filterTab('Returned', 'returned'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            color: const Color(0xFFF9FAFB),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            child: const Row(
              children: [
                Expanded(flex: 3, child: _ColHeader('STUDENT')),
                Expanded(flex: 2, child: _ColHeader('TXN ID')),
                Expanded(flex: 2, child: _ColHeader('BOOK')),
                Expanded(flex: 3, child: _ColHeader('DUE DATE')),
                Expanded(flex: 2, child: _ColHeader('STATUS')),
                Expanded(flex: 2, child: _ColHeader('ACTION')),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF0F2318),
                  strokeWidth: 2,
                ),
              ),
            )
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.wifi_off,
                      color: Color(0xFF9CA3AF),
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _fetchAll,
                      icon: const Icon(Icons.refresh, size: 14),
                      label: const Text('Retry'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF0F2318),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (txns.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  '📭 No transactions found.',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                ),
              ),
            )
          else
            ...txns.map((t) => _txnRow(t)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              border: Border(top: BorderSide(color: Colors.grey.shade100)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 13, color: Colors.grey.shade400),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Tap Return to process a book return.',
                    style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterTab(String label, String value) {
    final isActive = _txnFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _txnFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF0F2318) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? const Color(0xFF0F2318) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isActive ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  // Transaction row — wrapped in horizontal SingleChildScrollView so
  // all 6 columns are always visible without Flutter overflow errors.
  Widget _txnRow(AdminTransaction t) {
    Color statusColor;
    Color statusBg;
    String statusLabel;
    bool canReturn = false;

    switch (t.status) {
      case 'borrowed':
        statusColor = const Color(0xFF166534);
        statusBg = const Color(0xFFEAF3DE);
        statusLabel = 'Borrowed';
        canReturn = true;
        break;
      case 'overdue':
        statusColor = const Color(0xFF991B1B);
        statusBg = const Color(0xFFFCEBEB);
        statusLabel = 'Overdue';
        canReturn = true;
        break;
      default:
        statusColor = const Color(0xFF4B5563);
        statusBg = const Color(0xFFF3F4F6);
        statusLabel = 'Returned';
    }

    final initials = t.studentName.trim().isNotEmpty
        ? t.studentName
              .trim()
              .split(' ')
              .map((p) => p[0])
              .take(2)
              .join()
              .toUpperCase()
        : '?';

    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          // Fixed width wide enough for all 6 columns on any screen
          width: 520,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                // STUDENT
                SizedBox(
                  width: 100,
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFC8E6C9),
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            initials,
                            style: const TextStyle(
                              color: Color(0xFF1A6E2E),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.studentName,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF111827),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'ID: ${t.studentId}',
                              style: const TextStyle(
                                fontSize: 8,
                                color: Color(0xFFB0B8C4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                // TXN ID
                SizedBox(
                  width: 68,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'TXN-${t.transactionId}',
                      style: const TextStyle(
                        color: Color(0xFF1D4ED8),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // BOOK
                SizedBox(
                  width: 80,
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          t.bookTitle,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF374151),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                // DUE DATE
                SizedBox(
                  width: 80,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: canReturn
                          ? const Color(0xFFFFF7ED)
                          : const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: canReturn
                            ? const Color(0xFFFED7AA)
                            : const Color(0xFFBBF7D0),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      t.dueDate,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: canReturn
                            ? const Color(0xFFC2410C)
                            : const Color(0xFF166534),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // STATUS
                SizedBox(
                  width: 68,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            statusLabel,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // ACTION
                SizedBox(
                  width: 60,
                  child: canReturn
                      ? GestureDetector(
                          onTap: () => _confirmReturn(t),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F2318),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.undo, size: 10, color: Colors.white),
                                SizedBox(width: 3),
                                Text(
                                  'Return',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              'Done',
                              style: TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmReturn(AdminTransaction t) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Confirm Return'),
        content: Text(
          'Mark "${t.bookTitle}" borrowed by ${t.studentName} as returned?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F2318),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _returnBook(t.transactionId);
            },
            child: const Text('Return', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ─── TRANSACTIONS PAGE ────────────────────────────────────────────────────

  Widget _buildTransactions() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildPageHeader(
            '📋 All Transactions',
            'Manage all borrow and return records',
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildTransactionCard(),
          ),
        ],
      ),
    );
  }

  // ─── USERS PAGE ───────────────────────────────────────────────────────────

  Widget _buildUsers() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildPageHeader('👥 Registered Users', 'All student accounts'),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: _cardDeco(),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.people,
                              color: Color(0xFF1B6E2E),
                              size: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'User List',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              Text(
                                '${_users.length} accounts',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: const Color(0xFFF9FAFB),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    child: const Row(
                      children: [
                        Expanded(flex: 3, child: _ColHeader('NAME')),
                        Expanded(flex: 2, child: _ColHeader('USERNAME')),
                        Expanded(flex: 2, child: _ColHeader('COURSE')),
                        Expanded(flex: 2, child: _ColHeader('BORROWS')),
                        Expanded(flex: 2, child: _ColHeader('STATUS')),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF0F2318),
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  else if (_users.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          '📭 No users found.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                    )
                  else
                    ..._users.map((u) => _userRow(u)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _userRow(AdminUser u) {
    final initials = u.name.trim().isNotEmpty
        ? u.name.trim().split(' ').map((p) => p[0]).take(2).join().toUpperCase()
        : u.username.substring(0, 1).toUpperCase();
    final hasOverdue = u.overdue > 0;

    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.blue.shade100,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          u.name,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'ID: ${u.studentId}',
                          style: const TextStyle(
                            fontSize: 9,
                            color: Color(0xFFB0B8C4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                u.username,
                style: const TextStyle(fontSize: 11, color: Color(0xFF374151)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                u.course,
                style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${u.borrows}',
                  style: const TextStyle(
                    color: Color(0xFF1D4ED8),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: hasOverdue
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCEBEB),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '⚠ Overdue',
                        style: TextStyle(
                          color: Color(0xFF991B1B),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF3DE),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '✓ Clear',
                        style: TextStyle(
                          color: Color(0xFF166534),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── BOOKS PAGE ───────────────────────────────────────────────────────────

  Widget _buildBooks() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildPageHeader('📚 Book List', '${_books.length} books'),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: _cardDeco(),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.menu_book,
                              color: Color(0xFF1B6E2E),
                              size: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Book List',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              Text(
                                '${_books.length} books',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: const Color(0xFFF9FAFB),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    child: const Row(
                      children: [
                        Expanded(flex: 1, child: _ColHeader('#')),
                        Expanded(flex: 3, child: _ColHeader('TITLE')),
                        Expanded(flex: 2, child: _ColHeader('AUTHOR')),
                        Expanded(flex: 2, child: _ColHeader('GENRE')),
                        Expanded(flex: 1, child: _ColHeader('QTY')),
                        Expanded(flex: 2, child: _ColHeader('STATUS')),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF0F2318),
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  else if (_books.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          '📭 No books found.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                    )
                  else
                    ..._books.asMap().entries.map(
                      (e) => _bookRow(e.key + 1, e.value),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bookRow(int index, AdminBook b) {
    final available = b.quantity > 0;
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Text(
                '$index',
                style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                b.title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                b.author,
                style: const TextStyle(fontSize: 10, color: Color(0xFF374151)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                b.genre,
                style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                '${b.quantity}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: available ? const Color(0xFF166534) : Colors.redAccent,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: available
                      ? const Color(0xFFEAF3DE)
                      : const Color(0xFFFCEBEB),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  available ? '+ Available' : '✕ Out of Stock',
                  style: TextStyle(
                    color: available
                        ? const Color(0xFF166534)
                        : const Color(0xFF991B1B),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── PAGE HEADER ──────────────────────────────────────────────────────────

  Widget _buildPageHeader(String title, String subtitle) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0F2318),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ─── HELPERS ──────────────────────────────────────────────────────────────

  BoxDecoration _cardDeco() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: const Color(0xFFF1F5F9)),
    boxShadow: const [
      BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
    ],
  );

  Widget _cardHeader(IconData icon, String title) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: const Color(0xFF0F2318).withOpacity(0.08),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Icon(icon, size: 14, color: const Color(0xFF0F2318)),
        ),
      ),
      const SizedBox(width: 7),
      Flexible(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}

// ─── COL HEADER ───────────────────────────────────────────────────────────────

class _ColHeader extends StatelessWidget {
  final String text;
  const _ColHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.bold,
        color: Color(0xFF9CA3AF),
        letterSpacing: 0.5,
      ),
    );
  }
}

// ─── PIE PAINTERS ─────────────────────────────────────────────────────────────

class _PieChartPainter extends CustomPainter {
  final int active, overdue, returned;
  _PieChartPainter(this.active, this.overdue, this.returned);

  @override
  void paint(Canvas canvas, Size size) {
    final total = active + overdue + returned;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const sw = 14.0;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw
      ..strokeCap = StrokeCap.butt;

    if (total == 0) {
      paint.color = Colors.grey.shade200;
      canvas.drawCircle(center, radius - sw / 2, paint);
      return;
    }

    final segments = [
      (active, const Color(0xFF52B788)),
      (overdue, const Color(0xFFEF4444)),
      (returned, const Color(0xFFD1D5DB)),
    ];
    double startAngle = -3.14159 / 2;
    for (final seg in segments) {
      if (seg.$1 <= 0) continue;
      final sweep = (seg.$1 / total) * 2 * 3.14159;
      paint.color = seg.$2;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - sw / 2),
        startAngle,
        sweep,
        false,
        paint,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}

class _BooksPieChartPainter extends CustomPainter {
  final int available, borrowed, outOfStock;
  _BooksPieChartPainter(this.available, this.borrowed, this.outOfStock);

  @override
  void paint(Canvas canvas, Size size) {
    final total = available + borrowed + outOfStock;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const sw = 14.0;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw
      ..strokeCap = StrokeCap.butt;

    if (total == 0) {
      paint.color = Colors.grey.shade200;
      canvas.drawCircle(center, radius - sw / 2, paint);
      return;
    }

    final segments = [
      (available, const Color(0xFF52B788)),
      (borrowed, const Color(0xFFD97706)),
      (outOfStock, const Color(0xFFEF4444)),
    ];
    double startAngle = -3.14159 / 2;
    for (final seg in segments) {
      if (seg.$1 <= 0) continue;
      final sweep = (seg.$1 / total) * 2 * 3.14159;
      paint.color = seg.$2;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - sw / 2),
        startAngle,
        sweep,
        false,
        paint,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}
