import 'package:flutter/material.dart';
import '../data/app_store.dart';
import '../theme/app_styles.dart';
import 'borrow_receipt_screen.dart';

// ─── STATIC BOOK CATALOGUE ────────────────────────────────────────────────────
// Matches the 12 books in add_book.dart / browse_books_screen
class BookCatalogue {
  static const List<Map<String, dynamic>> books = [
    {
      'id': 1,
      'title': 'Clean Code',
      'author': 'Robert Martin',
      'category': 'Science',
      'year': '2024',
      'price': 500,
      'emoji': '💻',
      'color': Color(0xFF1B3A5C),
      'available': false,
      'quantity': 0,
      'description':
          'A handbook of agile software craftsmanship. Robert Martin presents a revolutionary paradigm with Clean Code, a book that will instill the values of a software craftsman and make you a better programmer.',
      'pages': 431,
      'publisher': 'Prentice Hall',
      'isbn': '978-0132350884',
      'tags': ['Programming', 'Software Engineering', 'Best Practices'],
    },
    {
      'id': 2,
      'title': 'Atomic Habits',
      'author': 'James Clear',
      'category': 'Self-Help',
      'year': '2023',
      'price': 450,
      'emoji': '⚛️',
      'color': Color(0xFFB45309),
      'available': true,
      'quantity': 3,
      'description':
          'An easy and proven way to build good habits and break bad ones. James Clear distills the most fundamental information about habit formation and provides practical strategies.',
      'pages': 320,
      'publisher': 'Avery Publishing',
      'isbn': '978-0735211292',
      'tags': ['Habits', 'Self-Improvement', 'Psychology'],
    },
    {
      'id': 3,
      'title': '1984',
      'author': 'George Orwell',
      'category': 'Fiction',
      'year': '2024',
      'price': 300,
      'emoji': '👁️',
      'color': Color(0xFF7F1D1D),
      'available': false,
      'quantity': 0,
      'description':
          'A dystopian social science fiction novel and cautionary tale. Orwell\'s chilling classic depicts a totalitarian society ruled by Big Brother, where truth is whatever the Party says it is.',
      'pages': 328,
      'publisher': 'Secker & Warburg',
      'isbn': '978-0451524935',
      'tags': ['Dystopia', 'Classic', 'Political Fiction'],
    },
    {
      'id': 4,
      'title': 'Sapiens',
      'author': 'Yuval Noah Harari',
      'category': 'History',
      'year': '2023',
      'price': 600,
      'emoji': '🌍',
      'color': Color(0xFF1E3A2E),
      'available': true,
      'quantity': 2,
      'description':
          'A brief history of humankind. From a renowned historian comes a groundbreaking narrative of humanity\'s creation and evolution exploring how biology and history have defined us.',
      'pages': 443,
      'publisher': 'Harper Collins',
      'isbn': '978-0062316097',
      'tags': ['History', 'Anthropology', 'Evolution'],
    },
    {
      'id': 5,
      'title': 'The Alchemist',
      'author': 'Paulo Coelho',
      'category': 'Fiction',
      'year': '2024',
      'price': 350,
      'emoji': '🏜️',
      'color': Color(0xFF78350F),
      'available': true,
      'quantity': 4,
      'description':
          'A magical story about following your dreams. Santiago, an Andalusian shepherd boy, journeys from Spain to Egypt in search of a worldly treasure as extraordinary as any ever found.',
      'pages': 208,
      'publisher': 'HarperOne',
      'isbn': '978-0062315007',
      'tags': ['Adventure', 'Philosophy', 'Inspirational'],
    },
    {
      'id': 6,
      'title': 'Rich Dad Poor Dad',
      'author': 'Robert Kiyosaki',
      'category': 'Finance',
      'year': '2023',
      'price': 400,
      'emoji': '💰',
      'color': Color(0xFF14532D),
      'available': false,
      'quantity': 0,
      'description':
          'What the rich teach their kids about money that the poor and middle class do not. Kiyosaki challenges conventional wisdom about money with lessons from his two "dads."',
      'pages': 336,
      'publisher': 'Plata Publishing',
      'isbn': '978-1612680194',
      'tags': ['Finance', 'Investing', 'Personal Finance'],
    },
    {
      'id': 7,
      'title': 'Harry Potter',
      'author': 'J.K. Rowling',
      'category': 'Fiction',
      'year': '2024',
      'price': 550,
      'emoji': '⚡',
      'color': Color(0xFF4C1D95),
      'available': true,
      'quantity': 6,
      'description':
          'The Sorcerer\'s Stone — Harry Potter has never even heard of Hogwarts when the letters start dropping on the doorstep. A letter changes everything as Harry discovers the magical world.',
      'pages': 309,
      'publisher': 'Scholastic',
      'isbn': '978-0439708180',
      'tags': ['Fantasy', 'Magic', 'Adventure'],
    },
    {
      'id': 8,
      'title': 'Think and Grow Rich',
      'author': 'Napoleon Hill',
      'category': 'Self-Help',
      'year': '2023',
      'price': 420,
      'emoji': '🧠',
      'color': Color(0xFF7C2D12),
      'available': true,
      'quantity': 2,
      'description':
          'The landmark bestseller now revised and updated for the 21st century. Hill draws on stories of Andrew Carnegie, Thomas Edison, Henry Ford, and other millionaires of his generation.',
      'pages': 320,
      'publisher': 'TarcherPerigee',
      'isbn': '978-1585424337',
      'tags': ['Success', 'Mindset', 'Wealth'],
    },
    {
      'id': 9,
      'title': 'The Hobbit',
      'author': 'J.R.R. Tolkien',
      'category': 'Fiction',
      'year': '2024',
      'price': 480,
      'emoji': '🧙',
      'color': Color(0xFF166534),
      'available': false,
      'quantity': 0,
      'description':
          'Bilbo Baggins is a hobbit who enjoys a comfortable life, never doing anything unexpected. That all changes when the wizard Gandalf and a company of dwarves arrive on his doorstep.',
      'pages': 310,
      'publisher': 'Houghton Mifflin',
      'isbn': '978-0547928227',
      'tags': ['Fantasy', 'Classic', 'Adventure'],
    },
    {
      'id': 10,
      'title': 'Deep Work',
      'author': 'Cal Newport',
      'category': 'Science',
      'year': '2023',
      'price': 530,
      'emoji': '🎯',
      'color': Color(0xFF1E3A5F),
      'available': true,
      'quantity': 1,
      'description':
          'Rules for focused success in a distracted world. Deep work is the ability to focus without distraction on a cognitively demanding task — a skill that is becoming increasingly valuable in our economy.',
      'pages': 296,
      'publisher': 'Grand Central Publishing',
      'isbn': '978-1455586691',
      'tags': ['Productivity', 'Focus', 'Work'],
    },
    {
      'id': 11,
      'title': 'Psychology of Money',
      'author': 'Morgan Housel',
      'category': 'Finance',
      'year': '2024',
      'price': 460,
      'emoji': '💵',
      'color': Color(0xFF064E3B),
      'available': true,
      'quantity': 3,
      'description':
          'Timeless lessons on wealth, greed, and happiness. Doing well with money isn\'t necessarily about what you know. It\'s about how you behave. And behavior is hard to teach, even to smart people.',
      'pages': 256,
      'publisher': 'Harriman House',
      'isbn': '978-0857197689',
      'tags': ['Finance', 'Behavior', 'Investing'],
    },
    {
      'id': 12,
      'title': 'Brief History of Time',
      'author': 'Stephen Hawking',
      'category': 'Science',
      'year': '2023',
      'price': 650,
      'emoji': '🔭',
      'color': Color(0xFF1E1B4B),
      'available': false,
      'quantity': 0,
      'description':
          'From the Big Bang to Black Holes. A landmark volume in science writing by one of the great minds of our time, Stephen Hawking\'s book explores such profound questions as the origin of the universe.',
      'pages': 212,
      'publisher': 'Bantam Books',
      'isbn': '978-0553380163',
      'tags': ['Physics', 'Cosmology', 'Science'],
    },
  ];

  static Map<String, dynamic>? findByTitle(String title) {
    try {
      return books.firstWhere(
        (b) => (b['title'] as String).toLowerCase() == title.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }
}

// ─── BOOK DETAIL SCREEN ───────────────────────────────────────────────────────

class BookDetailScreen extends StatefulWidget {
  final Book book;

  const BookDetailScreen({super.key, required this.book});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _currentPageController;
  late TextEditingController _notesController;
  late ReadingStatus _status;
  late double _rating;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  Map<String, dynamic>? _catalogueData;

  @override
  void initState() {
    super.initState();
    _currentPageController = TextEditingController(
      text: widget.book.currentPage.toString(),
    );
    _notesController = TextEditingController(text: widget.book.notes);
    _status = widget.book.status;
    _rating = widget.book.rating;

    _catalogueData = BookCatalogue.findByTitle(widget.book.title);

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _currentPageController.dispose();
    _notesController.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final pages =
        int.tryParse(_currentPageController.text) ?? widget.book.currentPage;
    widget.book.currentPage = pages.clamp(0, widget.book.totalPages);
    widget.book.status = _status;
    widget.book.rating = _rating;
    widget.book.notes = _notesController.text;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Progress saved! 📖"),
        backgroundColor: AppStyles.mutedGreen,
      ),
    );
    Navigator.pop(context);
  }

  Future<void> _confirmBorrow() async {
    final cat = _catalogueData;
    if (cat == null) return;

    if (!(cat['available'] as bool)) {
      showDialog(
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
            '"${widget.book.title}" is currently unavailable for borrowing.',
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
            Text(cat['emoji'] as String, style: const TextStyle(fontSize: 26)),
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
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9F4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppStyles.mutedGreen.withOpacity(0.4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cat['title'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF1E3A2E),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "by ${cat['author']}",
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _pill(cat['category'] as String, AppStyles.primaryBrown),
                      const SizedBox(width: 6),
                      _pill("₱${cat['price']}", AppStyles.mutedGreen),
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BorrowReceiptScreen(book: cat)),
      );
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final cat = _catalogueData;
    final coverColor = cat != null
        ? cat['color'] as Color
        : AppStyles.primaryBrown;
    final emoji = cat != null ? cat['emoji'] as String : widget.book.coverEmoji;
    final isAvailable = cat != null ? cat['available'] as bool : false;

    return Scaffold(
      backgroundColor: AppStyles.creamBackground,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          slivers: [
            // ── SLIVER APP BAR with book cover ────────────────────────
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              backgroundColor: coverColor,
              foregroundColor: Colors.white,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                      size: 18,
                    ),
                  ),
                  tooltip: "Remove Book",
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("Remove Book"),
                        content: Text(
                          "Remove '${widget.book.title}' from your library?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () {
                              BookStore.removeBook(widget.book.id);
                              Navigator.pop(ctx);
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "Remove",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(width: 4),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [coverColor, coverColor.withOpacity(0.75)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 50),
                      // Big emoji cover
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 52),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Availability badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: isAvailable
                              ? const Color(0xFF52B788)
                              : const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.black26, blurRadius: 4),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isAvailable ? Icons.check_circle : Icons.cancel,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              isAvailable ? "Available" : "Borrowed",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── BODY CONTENT ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── TITLE + AUTHOR ──────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: _cardDeco(),
                      child: Column(
                        children: [
                          Text(
                            widget.book.title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppStyles.darkWood,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "by ${widget.book.author}",
                            style: AppStyles.bookAuthor.copyWith(fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          // Tags row
                          if (cat != null)
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                _pill(cat['category'] as String, coverColor),
                                _pill("${cat['year']}", AppStyles.primaryBrown),
                                _pill("₱${cat['price']}", AppStyles.mutedGreen),
                                _pill(
                                  "${cat['pages']} pages",
                                  Colors.blueAccent,
                                ),
                                ...(cat['tags'] as List<String>).map(
                                  (t) => _pill(
                                    t,
                                    AppStyles.accentGold.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── DESCRIPTION ──────────────────────────────────
                    if (cat != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: _cardDeco(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionHeader("📖", "About this Book"),
                            const SizedBox(height: 10),
                            Text(
                              cat['description'] as String,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ── BOOK INFO TABLE ──────────────────────────
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: _cardDeco(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionHeader("📋", "Book Details"),
                            const SizedBox(height: 12),
                            _infoRow(
                              Icons.person_outline,
                              "Author",
                              cat['author'] as String,
                              coverColor,
                            ),
                            _divider(),
                            _infoRow(
                              Icons.category_outlined,
                              "Category",
                              cat['category'] as String,
                              coverColor,
                            ),
                            _divider(),
                            _infoRow(
                              Icons.calendar_today_outlined,
                              "Year",
                              cat['year'] as String,
                              coverColor,
                            ),
                            _divider(),
                            _infoRow(
                              Icons.format_list_numbered,
                              "Pages",
                              "${cat['pages']}",
                              coverColor,
                            ),
                            _divider(),
                            _infoRow(
                              Icons.business_outlined,
                              "Publisher",
                              cat['publisher'] as String,
                              coverColor,
                            ),
                            _divider(),
                            _infoRow(
                              Icons.qr_code,
                              "ISBN",
                              cat['isbn'] as String,
                              coverColor,
                            ),
                            _divider(),
                            _infoRow(
                              Icons.inventory_2_outlined,
                              "Stock",
                              cat['available'] as bool
                                  ? "${cat['quantity']} available"
                                  : "Out of stock",
                              cat['available'] as bool
                                  ? AppStyles.mutedGreen
                                  : Colors.redAccent,
                            ),
                            _divider(),
                            _infoRow(
                              Icons.monetization_on_outlined,
                              "Price",
                              "₱${cat['price']}",
                              AppStyles.mutedGreen,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // ── READING STATUS ───────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: _cardDeco(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionHeader("📚", "Reading Status"),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _statusBtn(
                                "Want to Read",
                                ReadingStatus.wantToRead,
                              ),
                              const SizedBox(width: 8),
                              _statusBtn("Reading", ReadingStatus.reading),
                              const SizedBox(width: 8),
                              _statusBtn("Finished", ReadingStatus.finished),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── READING PROGRESS ─────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: _cardDeco(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionHeader("📈", "Reading Progress"),
                          const SizedBox(height: 14),
                          // Progress percentage label
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${(widget.book.progressPercent * 100).toStringAsFixed(0)}% complete",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: coverColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "${widget.book.currentPage} / ${widget.book.totalPages} pages",
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.black45,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: widget.book.progressPercent,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                coverColor,
                              ),
                              minHeight: 10,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _currentPageController,
                                  keyboardType: TextInputType.number,
                                  decoration: AppStyles.inputDecoration(
                                    "Current Page",
                                    Icons.bookmark,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "/ ${widget.book.totalPages}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppStyles.darkWood,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── RATING (only when finished) ──────────────────
                    if (_status == ReadingStatus.finished) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: _cardDeco(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionHeader("⭐", "Your Rating"),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (i) {
                                final starValue = (i + 1).toDouble();
                                return GestureDetector(
                                  onTap: () =>
                                      setState(() => _rating = starValue),
                                  child: Icon(
                                    _rating >= starValue
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: AppStyles.accentGold,
                                    size: 38,
                                  ),
                                );
                              }),
                            ),
                            if (_rating > 0)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    "${_rating.toStringAsFixed(0)} / 5 stars",
                                    style: AppStyles.subText,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // ── NOTES ────────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: _cardDeco(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionHeader("📝", "Notes & Thoughts"),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _notesController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText:
                                  "Write your thoughts about this book...",
                              hintStyle: AppStyles.subText,
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: AppStyles.accentGold.withOpacity(0.4),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: AppStyles.accentGold.withOpacity(0.3),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: coverColor),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── ACTION BUTTONS ───────────────────────────────
                    // Borrow button (only if catalogue match found)
                    if (cat != null) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isAvailable
                                ? AppStyles.mutedGreen
                                : Colors.grey.shade400,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: isAvailable ? 4 : 0,
                          ),
                          icon: Icon(
                            isAvailable ? Icons.library_add : Icons.block,
                          ),
                          label: Text(
                            isAvailable
                                ? "BORROW THIS BOOK"
                                : "CURRENTLY UNAVAILABLE",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          onPressed: isAvailable ? _confirmBorrow : null,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],

                    // Save progress button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppStyles.primaryBrown,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.save, size: 18),
                        label: const Text(
                          "SAVE PROGRESS",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: _saveChanges,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── HELPERS ───────────────────────────────────────────────────────────────

  BoxDecoration _cardDeco() => BoxDecoration(
    color: AppStyles.softParchment,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: AppStyles.accentGold.withOpacity(0.3)),
    boxShadow: const [
      BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
    ],
  );

  Widget _sectionHeader(String emoji, String title) => Row(
    children: [
      Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: AppStyles.primaryBrown.withOpacity(0.08),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 14))),
      ),
      const SizedBox(width: 8),
      Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppStyles.darkWood,
        ),
      ),
    ],
  );

  Widget _infoRow(
    IconData icon,
    String label,
    String value,
    Color valueColor,
  ) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: valueColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 14, color: valueColor),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black45),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    ),
  );

  Widget _divider() =>
      Divider(color: AppStyles.accentGold.withOpacity(0.2), height: 1);

  Widget _statusBtn(String label, ReadingStatus status) {
    final isSelected = _status == status;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _status = status;
          if (status == ReadingStatus.finished) {
            _currentPageController.text = widget.book.totalPages.toString();
          }
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppStyles.primaryBrown : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? AppStyles.primaryBrown
                  : AppStyles.accentGold.withOpacity(0.4),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: isSelected ? Colors.white : AppStyles.warmGrey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
