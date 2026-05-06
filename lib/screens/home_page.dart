// lib/screens/home_page.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:librarytrackerapp/data/user_session.dart';
import '../data/app_store.dart';
import '../theme/app_styles.dart';
import 'login_screen.dart';
import 'add_book.dart';
import 'my_borrows_screen.dart';
import 'library_map_screen.dart'; // ← NEW import

// ─── BORROW RECORD MODEL ──────────────────────────────────────────────────────

class BorrowRecord {
  final String txnId;
  final String bookTitle;
  final String borrowDate;
  final String dueDate;
  final String status; // 'borrowed' | 'returned' | 'overdue'

  const BorrowRecord({
    required this.txnId,
    required this.bookTitle,
    required this.borrowDate,
    required this.dueDate,
    required this.status,
  });

  factory BorrowRecord.fromJson(
    Map<String, dynamic> txn,
    Map<int, String> bookTitles,
  ) {
    final bookId = txn['bookID'] as int? ?? 0;
    final title = bookTitles[bookId] ?? 'Book #$bookId';
    return BorrowRecord(
      txnId: 'TXN-${txn['transactionID']?.toString() ?? '—'}',
      bookTitle: title,
      borrowDate: _formatDate(txn['borrowDate']),
      dueDate: _formatDate(txn['returnDate']),
      status: _parseStatus(txn['status']?.toString() ?? ''),
    );
  }

  static String _formatDate(dynamic raw) {
    if (raw == null || raw.toString().isEmpty) return '—';
    try {
      final dt = DateTime.parse(raw.toString());
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
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
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
}

// ─── HOME PAGE ────────────────────────────────────────────────────────────────

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  int _totalBooksCount = 0;
  List<BorrowRecord> _borrowRecords = [];
  bool _borrowLoading = false;
  String? _borrowError;
  String _borrowFilter = 'all';

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
    _fetchBorrowRecords();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ─── API ──────────────────────────────────────────────────────────────────

  String get _baseUrl =>
      kIsWeb ? 'http://localhost:5000' : 'http://10.0.2.2:5000';

  Future<void> _fetchBorrowRecords() async {
    if (Session.studentId == null) return;

    setState(() {
      _borrowLoading = true;
      _borrowError = null;
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
        dio.get('$_baseUrl/api/Transaction/student/${Session.studentId}'),
        dio.get('$_baseUrl/api/Book/all'),
      ]);

      if (!mounted) return;

      final txnData = results[0].data;
      final bookData = results[1].data;

      // Count total books
      if (bookData is List) {
        _totalBooksCount = bookData.length;
      } else if (bookData is Map && bookData['data'] is List) {
        _totalBooksCount = (bookData['data'] as List).length;
      }

      // Build bookID → title map
      final Map<int, String> bookTitles = {};
      final rawBooks = bookData is List
          ? bookData
          : (bookData is Map && bookData['data'] is List
                ? bookData['data'] as List
                : []);
      for (final b in rawBooks) {
        if (b is Map<String, dynamic>) {
          final id = b['bookID'] as int?;
          final title = b['title']?.toString();
          if (id != null && title != null) bookTitles[id] = title;
        }
      }

      // Parse transactions
      final List<dynamic> txnList = txnData is List
          ? txnData
          : (txnData is Map && txnData['data'] is List
                ? txnData['data'] as List
                : []);

      setState(() {
        _borrowRecords = txnList
            .map(
              (e) =>
                  BorrowRecord.fromJson(e as Map<String, dynamic>, bookTitles),
            )
            .toList();
        _borrowLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _borrowError = 'Could not load borrow records.';
        _borrowLoading = false;
      });
    }
  }

  // ─── HELPERS ──────────────────────────────────────────────────────────────

  String get _displayName {
    final name = (Session.username ?? '').isNotEmpty
        ? Session.username!
        : 'Reader';
    return name[0].toUpperCase() + name.substring(1).toLowerCase();
  }

  String get _initials {
    final name = (Session.username ?? '').isNotEmpty ? Session.username! : 'R';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.substring(0, name.length.clamp(1, 2)).toUpperCase();
  }

  List<BorrowRecord> get _filteredRecords {
    if (_borrowFilter == 'all') return _borrowRecords;
    return _borrowRecords.where((r) => r.status == _borrowFilter).toList();
  }

  int get _activeBorrows =>
      _borrowRecords.where((r) => r.status == 'borrowed').length;
  int get _overdueBorrows =>
      _borrowRecords.where((r) => r.status == 'overdue').length;
  int get _returnedBorrows =>
      _borrowRecords.where((r) => r.status == 'returned').length;

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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1B3A2E),
      foregroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.auto_stories,
              color: Color(0xFF52B788),
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'LibraryTracker',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
      actions: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'STUDENT',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 9,
                letterSpacing: 1,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _displayName,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: _showLogoutDialog,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF52B788),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24, width: 1.5),
            ),
            child: Center(
              child: Text(
                _initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        TextButton.icon(
          onPressed: _showLogoutDialog,
          icon: const Icon(Icons.logout, size: 14, color: Colors.white60),
          label: const Text(
            'Logout',
            style: TextStyle(color: Colors.white60, fontSize: 11),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 6),
          ),
        ),
        const SizedBox(width: 4),
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
              backgroundColor: const Color(0xFF1B3A2E),
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

  // ─── BODY ─────────────────────────────────────────────────────────────────

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return const SizedBox();
      case 2:
        return const MyBorrowsScreen();
      case 3:
        return const LibraryMapScreen(); // ← REAL MAP
      case 4:
        return _buildProfile();
      default:
        return _buildDashboard();
    }
  }

  // ─── BOTTOM NAV ───────────────────────────────────────────────────────────

  BottomNavigationBar _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (i) async {
        if (i == 1) {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddBookScreen()),
          );
          setState(() {});
        } else {
          setState(() => _selectedIndex = i);
        }
      },
      selectedItemColor: const Color(0xFF1B3A2E),
      unselectedItemColor: AppStyles.warmGrey,
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
          icon: Icon(Icons.add_circle_outline),
          activeIcon: Icon(Icons.add_circle),
          label: 'Add Book',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2_outlined),
          activeIcon: Icon(Icons.inventory_2),
          label: 'My Borrows',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map_outlined),
          activeIcon: Icon(Icons.map),
          label: 'Library Map',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  // ─── DASHBOARD ────────────────────────────────────────────────────────────

  Widget _buildDashboard() {
    final allBooks = BookStore.all;

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHero(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _statCard(
                      'Total Books',
                      _totalBooksCount.toString(),
                      Icons.library_books,
                      const Color(0xFF52B788),
                      'In library collection',
                      'Books',
                    ),
                    const SizedBox(width: 10),
                    _statCard(
                      'Active Borrows',
                      _activeBorrows.toString(),
                      Icons.menu_book,
                      const Color(0xFFD97706),
                      'Currently borrowed',
                      'Active',
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _statCard(
                      'Overdue Books',
                      _overdueBorrows.toString(),
                      Icons.warning_amber_rounded,
                      Colors.redAccent,
                      'Needs attention',
                      'Urgent',
                    ),
                    const SizedBox(width: 10),
                    _statCard(
                      'Returned Books',
                      _returnedBorrows.toString(),
                      Icons.check_circle_outline,
                      Colors.blueAccent,
                      'All time returns',
                      'Done',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildStatusPieCard(
                        _activeBorrows,
                        _overdueBorrows,
                        _returnedBorrows,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: _buildActivityBarCard(allBooks)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildQuickActionsCard(),
                const SizedBox(height: 20),
                _buildRecentBorrowsTable(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── HERO ──────────────────────────────────────────────────────────────────

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1B3A2E), Color(0xFF2D5A41)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'STUDENT PORTAL',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Hello, $_displayName! 👋',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Track your books, borrows, and reading activity.',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
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
              const SizedBox(height: 8),
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
        ],
      ),
    );
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
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }

  // ── STAT CARD ─────────────────────────────────────────────────────────────

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
                    color: color.withValues(alpha: 0.12),
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
                    color: color.withValues(alpha: 0.12),
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

  // ── PIE CARD ──────────────────────────────────────────────────────────────

  Widget _buildStatusPieCard(int active, int overdue, int returned) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader('📊', 'Borrow Status'),
          const SizedBox(height: 12),
          Center(
            child: SizedBox(
              width: 90,
              height: 90,
              child: CustomPaint(
                painter: _PieChartPainter(active, overdue, returned),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${active + overdue + returned}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B3A2E),
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
          _pieLegend(const Color(0xFF52B788), 'Active', active),
          const SizedBox(height: 4),
          _pieLegend(const Color(0xFFEF4444), 'Overdue', overdue),
          const SizedBox(height: 4),
          _pieLegend(const Color(0xFFD1D5DB), 'Returned', returned),
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
            style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
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

  // ── ACTIVITY BAR ──────────────────────────────────────────────────────────

  Widget _buildActivityBarCard(List<Book> books) {
    final Map<String, int> monthCounts = {};
    for (final b in books) {
      const key = 'Apr';
      monthCounts[key] = (monthCounts[key] ?? 0) + 1;
    }
    final maxVal = monthCounts.isEmpty
        ? 1
        : monthCounts.values.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _cardHeader('📈', 'Reading Activity'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B3A2E).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_borrowRecords.length} txns',
                  style: const TextStyle(fontSize: 9, color: Color(0xFF6B7280)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: monthCounts.isEmpty
                ? const Center(
                    child: Text(
                      '📭 No activity',
                      style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                    ),
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: monthCounts.entries.map((e) {
                      final pct = e.value / maxVal;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            e.value.toString(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Container(
                            width: 28,
                            height: 55 * pct,
                            decoration: BoxDecoration(
                              color: const Color(0xFF52B788),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            e.key,
                            style: const TextStyle(
                              fontSize: 9,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  // ── QUICK ACTIONS ─────────────────────────────────────────────────────────

  Widget _buildQuickActionsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader('⚡', 'Quick Actions'),
          const SizedBox(height: 12),
          _quickActionBtn(
            icon: '📖',
            label: 'Browse Books',
            desc: 'Find and borrow a book',
            primary: true,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddBookScreen()),
              );
              setState(() {});
            },
          ),
          const SizedBox(height: 8),
          _quickActionBtn(
            icon: '📦',
            label: 'My Borrows',
            desc: 'View borrowed books',
            primary: false,
            onTap: () => setState(() => _selectedIndex = 2),
          ),
          const SizedBox(height: 8),
          _quickActionBtn(
            icon: '🗺️',
            label: 'Library Map',
            desc: 'Find your way to library',
            primary: false,
            onTap: () => setState(() => _selectedIndex = 3),
          ),
        ],
      ),
    );
  }

  Widget _quickActionBtn({
    required String icon,
    required String label,
    required String desc,
    required bool primary,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: primary ? const Color(0xFF1B3A2E) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: primary ? Colors.transparent : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: primary
                    ? Colors.white.withValues(alpha: 0.12)
                    : const Color(0xFF1B3A2E).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: primary ? Colors.white : const Color(0xFF111827),
                    ),
                  ),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 11,
                      color: primary ? Colors.white54 : const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward,
              size: 16,
              color: primary ? Colors.white54 : const Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }

  // ── RECENT BORROWS TABLE ──────────────────────────────────────────────────

  Widget _buildRecentBorrowsTable() {
    return Container(
      decoration: _cardDecoration(),
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
                      Icons.menu_book_rounded,
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
                        'Borrow history',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      Text(
                        'Statuses update when admin processes returns',
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
                        color: const Color(0xFF1B3A2E).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_borrowRecords.length} records',
                        style: const TextStyle(
                          fontSize: 9,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: _fetchBorrowRecords,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF1B3A2E,
                          ).withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.refresh,
                          size: 14,
                          color: Color(0xFF1B3A2E),
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
            child: Row(
              children: [
                _filterTab('All', 'all'),
                const SizedBox(width: 6),
                _filterTab('Active', 'borrowed'),
                const SizedBox(width: 6),
                _filterTab('Returned', 'returned'),
              ],
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
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          if (_borrowLoading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF1B3A2E),
                  strokeWidth: 2,
                ),
              ),
            )
          else if (_borrowError != null)
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
                      _borrowError!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _fetchBorrowRecords,
                      icon: const Icon(Icons.refresh, size: 14),
                      label: const Text('Retry'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF1B3A2E),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (_filteredRecords.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  _borrowRecords.isEmpty
                      ? '📭 No borrow records found.'
                      : '📭 No records for this filter.',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                ),
              ),
            )
          else
            ..._filteredRecords.map((r) => _borrowRow(r)),
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
                    'Book returns are processed by the library admin.',
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
    final isActive = _borrowFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _borrowFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF111827) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? const Color(0xFF111827) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isActive ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  Widget _borrowRow(BorrowRecord r) {
    Color statusColor;
    Color statusBg;
    String statusLabel;

    switch (r.status) {
      case 'borrowed':
        statusColor = const Color(0xFF166534);
        statusBg = const Color(0xFFEAF3DE);
        statusLabel = 'Borrowed';
        break;
      case 'overdue':
        statusColor = const Color(0xFF991B1B);
        statusBg = const Color(0xFFFCEBEB);
        statusLabel = 'Overdue';
        break;
      default:
        statusColor = const Color(0xFF4B5563);
        statusBg = const Color(0xFFF3F4F6);
        statusLabel = 'Returned';
    }

    final isDueSoon = r.status == 'borrowed';

    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: [
            // Student
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
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
                        _initials,
                        style: const TextStyle(
                          color: Color(0xFF1A6E2E),
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
                          _displayName,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Text(
                          'Student',
                          style: TextStyle(
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
            // TXN ID
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  r.txnId,
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
            const SizedBox(width: 4),
            // Book
            Expanded(
              flex: 2,
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
                      r.bookTitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF374151),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // Due date
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: isDueSoon
                      ? const Color(0xFFFFF7ED)
                      : const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDueSoon
                        ? const Color(0xFFFED7AA)
                        : const Color(0xFFBBF7D0),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  r.dueDate,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: isDueSoon
                        ? const Color(0xFFC2410C)
                        : const Color(0xFF166534),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(width: 4),
            // Status
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
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
          ],
        ),
      ),
    );
  }

  // ─── PROFILE ──────────────────────────────────────────────────────────────

  Widget _buildProfile() {
    final finished = BookStore.all
        .where((b) => b.status == ReadingStatus.finished)
        .toList();
    final avgRating = finished.isEmpty
        ? 0.0
        : finished
                  .where((b) => b.rating > 0)
                  .fold(0.0, (sum, b) => sum + b.rating) /
              (finished.where((b) => b.rating > 0).length.clamp(1, 9999));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF52B788),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF1B3A2E), width: 2.5),
            ),
            child: Center(
              child: Text(
                _initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Text(
            _displayName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'LibraryTracker Member',
            style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                _profileStatRow(
                  'Total Borrows',
                  '${_borrowRecords.length}',
                  Icons.receipt_long,
                ),
                const Divider(),
                _profileStatRow(
                  'Active Borrows',
                  '$_activeBorrows',
                  Icons.menu_book,
                ),
                const Divider(),
                _profileStatRow(
                  'Overdue',
                  '$_overdueBorrows',
                  Icons.warning_amber,
                ),
                const Divider(),
                _profileStatRow(
                  'Returned',
                  '$_returnedBorrows',
                  Icons.check_circle,
                ),
                const Divider(),
                _profileStatRow(
                  'Avg. Rating',
                  avgRating > 0 ? avgRating.toStringAsFixed(1) : '—',
                  Icons.star,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1B3A2E), size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF374151), fontSize: 14),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF1B3A2E),
            ),
          ),
        ],
      ),
    );
  }

  // ─── HELPERS ──────────────────────────────────────────────────────────────

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: const Color(0xFFF1F5F9)),
    boxShadow: const [
      BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
    ],
  );

  Widget _cardHeader(String emoji, String title) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: const Color(0xFF1B3A2E).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 13))),
      ),
      const SizedBox(width: 7),
      Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Color(0xFF111827),
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

// ─── PIE CHART PAINTER ────────────────────────────────────────────────────────

class _PieChartPainter extends CustomPainter {
  final int active, overdue, returned;
  _PieChartPainter(this.active, this.overdue, this.returned);

  @override
  void paint(Canvas canvas, Size size) {
    final total = active + overdue + returned;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 14.0;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    if (total == 0) {
      paint.color = Colors.grey.shade200;
      canvas.drawCircle(center, radius - strokeWidth / 2, paint);
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
      final sweepAngle = (seg.$1 / total) * 2 * 3.14159;
      paint.color = seg.$2;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
