// lib/screens/add_book.dart
import 'package:flutter/material.dart';
import '../data/app_store.dart';
import '../data/user_session.dart';
import '../services/api_service.dart';
import '../theme/app_styles.dart';
import 'borrow_receipt_screen.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  // Books loaded from API
  List<Map<String, dynamic>> _books = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Maps genre keywords to emoji + color for display
  static const _genreEmoji = {
    'fiction': ('📖', Color(0xFF7F1D1D)),
    'science': ('🔬', Color(0xFF1B3A5C)),
    'history': ('📜', Color(0xFF1E3A2E)),
    'self-help': ('🧠', Color(0xFF7C2D12)),
    'finance': ('💰', Color(0xFF14532D)),
    'fantasy': ('🧙', Color(0xFF166534)),
    'default': ('📚', Color(0xFF1E3A5F)),
  };

  (String, Color) _emojiForGenre(String genre) {
    final key = genre.toLowerCase();
    for (final entry in _genreEmoji.entries) {
      if (key.contains(entry.key)) return entry.value;
    }
    return _genreEmoji['default']!;
  }

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Load books from API ────────────────────────────────────────────────────

  Future<void> _loadBooks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final apiBooks = await ApiService.getBooks();

    if (!mounted) return;

    if (apiBooks.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not load books. Check your connection.';
      });
      return;
    }

    // Map API response to display format
    setState(() {
      _isLoading = false;
      _books = apiBooks.map((b) {
        final (emoji, color) = _emojiForGenre(b['genre'] ?? '');
        final qty = (b['quantity'] ?? 0) as int;
        return {
          'id': b['bookID'],
          'title': b['title'] ?? 'Unknown',
          'author': b['author'] ?? 'Unknown',
          'category': b['genre'] ?? 'General',
          'emoji': emoji,
          'color': color,
          'available': qty > 0,
          'quantity': qty,
          'isFavorite': false,
        };
      }).toList();
    });
  }

  // ── Filter ────────────────────────────────────────────────────────────────

  List<Map<String, dynamic>> get _filteredBooks {
    if (_searchQuery.isEmpty) return _books;
    final q = _searchQuery.toLowerCase();
    return _books.where((b) {
      return (b['title'] as String).toLowerCase().contains(q) ||
          (b['author'] as String).toLowerCase().contains(q) ||
          (b['category'] as String).toLowerCase().contains(q);
    }).toList();
  }

  // ── Borrow confirmation ────────────────────────────────────────────────────

  Future<void> _confirmBorrow(Map<String, dynamic> book) async {
    if (!(book['available'] as bool)) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.cancel_outlined, color: Colors.redAccent),
              SizedBox(width: 8),
              Text("Unavailable"),
            ],
          ),
          content: Text(
            '"${book['title']}" is currently unavailable for borrowing.',
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppStyles.primaryBrown,
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text("OK", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Text(book['emoji'] as String, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                "Borrow Book?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Are you going to borrow this book?",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9F4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppStyles.mutedGreen.withOpacity(0.4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book['title'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF1E3A2E),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "by ${book['author']}",
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _pill(book['category'] as String, AppStyles.primaryBrown),
                      const SizedBox(width: 6),
                      _pill("Qty: ${book['quantity']}", AppStyles.mutedGreen),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.black45),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppStyles.primaryBrown,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              "Yes, Borrow!",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // ── Show loading ───────────────────────────────────────────────
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      // ── Call API ───────────────────────────────────────────────────
      final success = await ApiService.borrowBook(
        studentId: Session.studentId ?? 0,
        bookId: book['id'] as int,
        quantity: 1,
      );

      if (!mounted) return;
      Navigator.pop(context); // close loading

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to borrow book. Please try again.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      // ── Save to local BookStore so dashboard updates ───────────────
      BookStore.addBook(
        Book(
          id: book['id'].toString(),
          title: book['title'] as String,
          author: book['author'] as String,
          genre: book['category'] as String,
          coverEmoji: book['emoji'] as String,
          totalPages: 200,
          status: ReadingStatus.reading,
        ),
      );

      // Update local quantity so card flips to "Borrowed" if stock runs out
      setState(() {
        final qty = (book['quantity'] as int) - 1;
        book['quantity'] = qty;
        if (qty <= 0) book['available'] = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BorrowReceiptScreen(book: book)),
      );
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _pill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredBooks;

    return Scaffold(
      backgroundColor: AppStyles.creamBackground,
      body: Column(
        children: [
          // ── HEADER ──────────────────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1B3A2E), Color(0xFF2D5A41)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: AppStyles.mutedGreen.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(
                              color: AppStyles.mutedGreen.withOpacity(0.35),
                            ),
                          ),
                          child: const Center(
                            child: Text("📚", style: TextStyle(fontSize: 14)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "LibraryTrack",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                letterSpacing: 0.2,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: AppStyles.mutedGreen,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                "STUDENT",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 7,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        _navPill("📖 Book List", true),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "📖 Browse Books",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      "Find your next great read and borrow it today.",
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: "Search by title, author, or category...",
                          hintStyle: const TextStyle(
                            color: Colors.black38,
                            fontSize: 13,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.black38,
                            size: 18,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.clear,
                                    size: 16,
                                    color: Colors.black38,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 13,
                          ),
                        ),
                        onChanged: (v) => setState(() => _searchQuery = v),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Book count or loading indicator
                    _isLoading
                        ? const Text(
                            "Loading books...",
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 13,
                            ),
                          )
                        : RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "${filtered.length}",
                                  style: const TextStyle(
                                    color: AppStyles.accentGold,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const TextSpan(
                                  text: " books found",
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),

          // ── BOOK GRID ────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.cloud_off,
                          size: 52,
                          color: Colors.black26,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.black45,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _loadBooks,
                          icon: const Icon(Icons.refresh),
                          label: const Text("Retry"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppStyles.primaryBrown,
                          ),
                        ),
                      ],
                    ),
                  )
                : filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 52,
                          color: Colors.black.withOpacity(0.2),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "No books found matching your search.",
                          style: TextStyle(color: Colors.black45, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadBooks,
                    child: GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 0.62,
                          ),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) => _bookCard(filtered[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _navPill(String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: active
            ? AppStyles.mutedGreen.withOpacity(0.2)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: active
              ? AppStyles.mutedGreen.withOpacity(0.5)
              : Colors.white24,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? const Color(0xFF86EFAC) : Colors.white60,
          fontSize: 11,
          fontWeight: active ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _bookCard(Map<String, dynamic> book) {
    final isAvailable = book['available'] as bool;
    final isFavorite = book['isFavorite'] as bool;
    final color = book['color'] as Color;

    return GestureDetector(
      onTap: () => _confirmBorrow(book),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.black.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withOpacity(0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          book['emoji'] as String,
                          style: const TextStyle(fontSize: 46),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            book['title'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              shadows: [
                                Shadow(color: Colors.black26, blurRadius: 4),
                              ],
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isAvailable
                            ? const Color(0xFF52B788)
                            : const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        isAvailable ? "Available" : "Unavailable",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => book['isFavorite'] = !isFavorite),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 4),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            isFavorite ? "❤️" : "🤍",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (book['category'] as String).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.black45,
                        letterSpacing: 0.6,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      book['title'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      book['author'] as String,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.black45,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(
                          Icons.inventory_2_outlined,
                          size: 11,
                          color: Colors.black45,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          "${book['quantity']} left",
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.black45,
                          ),
                        ),
                      ],
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
}
