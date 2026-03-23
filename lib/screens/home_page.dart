import 'package:flutter/material.dart';
import '../data/app_store.dart';
import '../theme/app_styles.dart';
import 'login_screen.dart';
import 'add_book.dart';
import 'book_detail.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final _searchController = TextEditingController();
  String _selectedGenre = 'All';
  ReadingStatus? _selectedStatus;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Book> get _filteredBooks => BookStore.search(
    _searchQuery,
    genre: _selectedGenre,
    status: _selectedStatus,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.creamBackground,
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
              backgroundColor: AppStyles.primaryBrown,
              foregroundColor: AppStyles.softParchment,
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddBookScreen()),
                );
                setState(() {});
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppStyles.primaryBrown,
      foregroundColor: AppStyles.softParchment,
      elevation: 0,
      title: Row(
        children: [
          const Icon(Icons.auto_stories, color: AppStyles.accentGold, size: 22),
          const SizedBox(width: 8),
          Text(
            "LibraryTracker",
            style: TextStyle(
              color: AppStyles.softParchment,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout, color: AppStyles.accentGold),
          tooltip: "Sign Out",
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text("Sign Out"),
                content: const Text("Are you sure you want to sign out?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppStyles.primaryBrown,
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: const Text(
                      "Sign Out",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return _buildMyBooks();
      case 2:
        return _buildProfile();
      default:
        return _buildDashboard();
    }
  }

  // ─── DASHBOARD ────────────────────────────────────────────────────────────

  Widget _buildDashboard() {
    final stats = BookStore.stats;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader("📊 Reading Overview"),
          const SizedBox(height: 12),
          Row(
            children: [
              _statCard(
                "Total Books",
                stats['total'].toString(),
                Icons.library_books,
                AppStyles.primaryBrown,
              ),
              const SizedBox(width: 10),
              _statCard(
                "Finished",
                stats['finished'].toString(),
                Icons.check_circle,
                AppStyles.mutedGreen,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _statCard(
                "Reading",
                stats['reading'].toString(),
                Icons.menu_book,
                AppStyles.accentGold,
              ),
              const SizedBox(width: 10),
              _statCard(
                "Want to Read",
                stats['wantToRead'].toString(),
                Icons.bookmark_border,
                AppStyles.warmGrey,
              ),
            ],
          ),
          const SizedBox(height: 24),

          _sectionHeader("📖 Currently Reading"),
          const SizedBox(height: 12),
          ...BookStore.all
              .where((b) => b.status == ReadingStatus.reading)
              .map((b) => _currentlyReadingCard(b)),
          if (BookStore.all
              .where((b) => b.status == ReadingStatus.reading)
              .isEmpty)
            _emptyState("No books in progress.\nAdd one from 'My Books'!"),

          const SizedBox(height: 24),
          _sectionHeader("✅ Recently Finished"),
          const SizedBox(height: 12),
          ...BookStore.all
              .where((b) => b.status == ReadingStatus.finished)
              .map((b) => _finishedBookTile(b)),
          if (BookStore.all
              .where((b) => b.status == ReadingStatus.finished)
              .isEmpty)
            _emptyState("No finished books yet. Keep reading!"),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppStyles.softParchment,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppStyles.accentGold.withOpacity(0.3)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(label, style: AppStyles.subText),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _currentlyReadingCard(Book book) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)),
        );
        setState(() {});
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppStyles.softParchment,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppStyles.accentGold.withOpacity(0.4)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(book.coverEmoji, style: const TextStyle(fontSize: 36)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.title, style: AppStyles.bookTitle),
                  Text(book.author, style: AppStyles.bookAuthor),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: book.progressPercent,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppStyles.mutedGreen,
                      ),
                      minHeight: 7,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${book.currentPage} / ${book.totalPages} pages  (${(book.progressPercent * 100).toStringAsFixed(0)}%)",
                    style: AppStyles.subText.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppStyles.warmGrey),
          ],
        ),
      ),
    );
  }

  Widget _finishedBookTile(Book book) {
    return ListTile(
      leading: Text(book.coverEmoji, style: const TextStyle(fontSize: 28)),
      title: Text(book.title, style: AppStyles.bookTitle),
      subtitle: Text(book.author, style: AppStyles.bookAuthor),
      trailing: book.rating > 0
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: AppStyles.accentGold, size: 16),
                Text(book.rating.toString(), style: AppStyles.subText),
              ],
            )
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    );
  }

  // ─── MY BOOKS ─────────────────────────────────────────────────────────────

  Widget _buildMyBooks() {
    final books = _filteredBooks;
    return Column(
      children: [
        _buildSearchBar(),
        _buildFilterRow(),
        Expanded(
          child: books.isEmpty
              ? _emptyState(
                  "No books found.\nTry adjusting your filters or add a new book.",
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: books.length,
                  itemBuilder: (_, i) => _bookCard(books[i]),
                ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppStyles.primaryBrown,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Search by title or author...",
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: const Icon(Icons.search, color: AppStyles.accentGold),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white54),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white12,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
        onChanged: (val) => setState(() => _searchQuery = val),
      ),
    );
  }

  Widget _buildFilterRow() {
    return Container(
      color: AppStyles.softParchment,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Genre chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: BookStore.genres.map((g) {
                final selected = _selectedGenre == g;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text(
                      g,
                      style: TextStyle(
                        fontSize: 12,
                        color: selected ? Colors.white : AppStyles.primaryBrown,
                      ),
                    ),
                    selected: selected,
                    selectedColor: AppStyles.primaryBrown,
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: AppStyles.accentGold.withOpacity(0.5),
                    ),
                    showCheckmark: false,
                    onSelected: (_) => setState(() => _selectedGenre = g),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 6),
          // Status filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _statusChip("All", null),
                _statusChip("Want to Read", ReadingStatus.wantToRead),
                _statusChip("Reading", ReadingStatus.reading),
                _statusChip("Finished", ReadingStatus.finished),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String label, ReadingStatus? status) {
    final selected = _selectedStatus == status;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: selected ? Colors.white : AppStyles.warmGrey,
          ),
        ),
        selected: selected,
        selectedColor: AppStyles.mutedGreen,
        backgroundColor: Colors.white,
        side: BorderSide(color: AppStyles.accentGold.withOpacity(0.3)),
        showCheckmark: false,
        onSelected: (_) => setState(() => _selectedStatus = status),
      ),
    );
  }

  Widget _bookCard(Book book) {
    Color statusColor;
    switch (book.status) {
      case ReadingStatus.finished:
        statusColor = AppStyles.mutedGreen;
        break;
      case ReadingStatus.reading:
        statusColor = AppStyles.accentGold;
        break;
      case ReadingStatus.wantToRead:
        statusColor = AppStyles.warmGrey;
        break;
    }

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)),
        );
        setState(() {});
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppStyles.softParchment,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppStyles.accentGold.withOpacity(0.3)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(book.coverEmoji, style: const TextStyle(fontSize: 38)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.title, style: AppStyles.bookTitle),
                  const SizedBox(height: 2),
                  Text(book.author, style: AppStyles.bookAuthor),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: statusColor.withOpacity(0.4),
                          ),
                        ),
                        child: Text(
                          book.statusLabel,
                          style: TextStyle(
                            fontSize: 10,
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppStyles.primaryBrown.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          book.genre,
                          style: AppStyles.subText.copyWith(fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                  if (book.status == ReadingStatus.reading) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: book.progressPercent,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppStyles.mutedGreen,
                        ),
                        minHeight: 5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${(book.progressPercent * 100).toStringAsFixed(0)}% complete",
                      style: AppStyles.subText.copyWith(fontSize: 10),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppStyles.warmGrey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // ─── PROFILE ──────────────────────────────────────────────────────────────

  Widget _buildProfile() {
    final stats = BookStore.stats;
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
          // Avatar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppStyles.primaryBrown.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: AppStyles.accentGold, width: 2.5),
            ),
            child: const Icon(
              Icons.person,
              size: 60,
              color: AppStyles.primaryBrown,
            ),
          ),
          const Text(
            "Reader",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppStyles.darkWood,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "LibraryTracker Member",
            style: TextStyle(color: AppStyles.warmGrey, fontSize: 13),
          ),
          const SizedBox(height: 24),

          _sectionHeader("📈 My Reading Stats"),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppStyles.softParchment,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppStyles.accentGold.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                _profileStatRow(
                  "Total Books",
                  "${stats['total']}",
                  Icons.library_books,
                ),
                const Divider(),
                _profileStatRow(
                  "Books Finished",
                  "${stats['finished']}",
                  Icons.check_circle,
                ),
                const Divider(),
                _profileStatRow(
                  "Currently Reading",
                  "${stats['reading']}",
                  Icons.menu_book,
                ),
                const Divider(),
                _profileStatRow(
                  "Want to Read",
                  "${stats['wantToRead']}",
                  Icons.bookmark_border,
                ),
                const Divider(),
                _profileStatRow(
                  "Avg. Rating Given",
                  avgRating > 0 ? avgRating.toStringAsFixed(1) : "—",
                  Icons.star,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _sectionHeader("🏆 Top Rated Books"),
          const SizedBox(height: 12),
          ...(() {
            final topRated = finished.where((b) => b.rating > 0).toList()
              ..sort((a, b) => b.rating.compareTo(a.rating));
            return topRated
                .take(3)
                .map(
                  (b) => ListTile(
                    leading: Text(
                      b.coverEmoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                    title: Text(b.title, style: AppStyles.bookTitle),
                    subtitle: Text(b.author, style: AppStyles.bookAuthor),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star,
                          color: AppStyles.accentGold,
                          size: 18,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          b.rating.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppStyles.darkWood,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
          })(),
          if (finished.where((b) => b.rating > 0).isEmpty)
            _emptyState("Rate your finished books to see them here!"),
        ],
      ),
    );
  }

  Widget _profileStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: AppStyles.primaryBrown, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(color: AppStyles.darkWood, fontSize: 14),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppStyles.primaryBrown,
            ),
          ),
        ],
      ),
    );
  }

  // ─── HELPERS ──────────────────────────────────────────────────────────────

  Widget _sectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppStyles.darkWood,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Divider(color: AppStyles.accentGold.withOpacity(0.5))),
      ],
    );
  }

  Widget _emptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.menu_book_outlined,
              size: 48,
              color: AppStyles.warmGrey,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppStyles.subText.copyWith(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBar _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (i) => setState(() => _selectedIndex = i),
      selectedItemColor: AppStyles.primaryBrown,
      unselectedItemColor: AppStyles.warmGrey,
      backgroundColor: AppStyles.softParchment,
      type: BottomNavigationBarType.fixed,
      selectedFontSize: 12,
      unselectedFontSize: 11,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: "Dashboard",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.library_books_outlined),
          activeIcon: Icon(Icons.library_books),
          label: "My Books",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: "Profile",
        ),
      ],
    );
  }
}
