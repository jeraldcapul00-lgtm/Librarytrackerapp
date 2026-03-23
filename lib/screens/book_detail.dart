import 'package:flutter/material.dart';
import '../data/app_store.dart';
import '../theme/app_styles.dart';

class BookDetailScreen extends StatefulWidget {
  final Book book;

  const BookDetailScreen({super.key, required this.book});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  late TextEditingController _currentPageController;
  late TextEditingController _notesController;
  late ReadingStatus _status;
  late double _rating;

  @override
  void initState() {
    super.initState();
    _currentPageController = TextEditingController(
      text: widget.book.currentPage.toString(),
    );
    _notesController = TextEditingController(text: widget.book.notes);
    _status = widget.book.status;
    _rating = widget.book.rating;
  }

  @override
  void dispose() {
    _currentPageController.dispose();
    _notesController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.creamBackground,
      appBar: AppBar(
        backgroundColor: AppStyles.primaryBrown,
        foregroundColor: AppStyles.softParchment,
        title: const Text("Book Details"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
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
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: AppStyles.cardBox,
              child: Column(
                children: [
                  Text(
                    widget.book.coverEmoji,
                    style: const TextStyle(fontSize: 64),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.book.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppStyles.darkWood,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.book.author,
                    style: AppStyles.bookAuthor.copyWith(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppStyles.primaryBrown.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppStyles.accentGold.withOpacity(0.4),
                      ),
                    ),
                    child: Text(widget.book.genre, style: AppStyles.subText),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppStyles.cardBox,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Reading Status", style: AppStyles.headline),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _statusBtn("Want to Read", ReadingStatus.wantToRead),
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

            // Progress
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppStyles.cardBox,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Reading Progress", style: AppStyles.headline),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: widget.book.progressPercent,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppStyles.mutedGreen,
                      ),
                      minHeight: 10,
                    ),
                  ),
                  const SizedBox(height: 12),
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

            // Rating (only if finished)
            if (_status == ReadingStatus.finished)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: AppStyles.cardBox,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Your Rating", style: AppStyles.headline),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starValue = (index + 1).toDouble();
                        return GestureDetector(
                          onTap: () => setState(() => _rating = starValue),
                          child: Icon(
                            _rating >= starValue
                                ? Icons.star
                                : Icons.star_border,
                            color: AppStyles.accentGold,
                            size: 36,
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
            if (_status == ReadingStatus.finished) const SizedBox(height: 12),

            // Notes
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppStyles.cardBox,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Notes & Thoughts", style: AppStyles.headline),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _notesController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Write your thoughts about this book...",
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
                        borderSide: const BorderSide(
                          color: AppStyles.primaryBrown,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: AppStyles.primaryButton,
                icon: const Icon(Icons.save, size: 18),
                label: const Text("SAVE PROGRESS"),
                onPressed: _saveChanges,
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

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
