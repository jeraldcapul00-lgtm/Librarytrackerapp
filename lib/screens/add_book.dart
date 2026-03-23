import 'package:flutter/material.dart';
import '../data/app_store.dart';
import '../theme/app_styles.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _pagesController = TextEditingController();

  String _selectedGenre = 'Classic';
  ReadingStatus _selectedStatus = ReadingStatus.wantToRead;
  String _selectedEmoji = '📗';

  final List<String> _genres = [
    'Classic',
    'Sci-Fi',
    'Fantasy',
    'Mystery',
    'Romance',
    'Non-Fiction',
    'Dystopian',
    'Thriller',
    'Biography',
    'Self-Help',
  ];
  final List<String> _emojiOptions = [
    '📗',
    '📘',
    '📙',
    '📕',
    '📒',
    '📔',
    '📚',
    '📖',
    '🔖',
    '🗒️',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _pagesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.creamBackground,
      appBar: AppBar(
        backgroundColor: AppStyles.primaryBrown,
        foregroundColor: AppStyles.softParchment,
        title: const Text("Add New Book"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: AppStyles.cardBox,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cover Emoji Picker
                const Text("Choose a Cover", style: AppStyles.headline),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  children: _emojiOptions.map((e) {
                    final isSelected = e == _selectedEmoji;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedEmoji = e),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppStyles.primaryBrown.withOpacity(0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? AppStyles.primaryBrown
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Text(e, style: const TextStyle(fontSize: 28)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: AppStyles.inputDecoration(
                    "Book Title",
                    Icons.title,
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? "Title is required" : null,
                ),
                const SizedBox(height: 14),

                // Author
                TextFormField(
                  controller: _authorController,
                  decoration: AppStyles.inputDecoration(
                    "Author",
                    Icons.person_outline,
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? "Author is required" : null,
                ),
                const SizedBox(height: 14),

                // Pages
                TextFormField(
                  controller: _pagesController,
                  keyboardType: TextInputType.number,
                  decoration: AppStyles.inputDecoration(
                    "Total Pages",
                    Icons.format_list_numbered,
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Pages required";
                    if (int.tryParse(v) == null || int.parse(v) <= 0)
                      return "Enter a valid number";
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Genre
                DropdownButtonFormField<String>(
                  initialValue: _selectedGenre,
                  decoration: AppStyles.inputDecoration(
                    "Genre",
                    Icons.category_outlined,
                  ),
                  items: _genres
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedGenre = v!),
                ),
                const SizedBox(height: 14),

                // Status
                const Text(
                  "Reading Status",
                  style: TextStyle(color: AppStyles.warmGrey, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _statusOption("Want to Read", ReadingStatus.wantToRead),
                    const SizedBox(width: 8),
                    _statusOption("Reading", ReadingStatus.reading),
                    const SizedBox(width: 8),
                    _statusOption("Finished", ReadingStatus.finished),
                  ],
                ),
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: AppStyles.primaryButton,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text("ADD TO LIBRARY"),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final book = Book(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: _titleController.text.trim(),
                          author: _authorController.text.trim(),
                          genre: _selectedGenre,
                          coverEmoji: _selectedEmoji,
                          totalPages: int.parse(_pagesController.text),
                          status: _selectedStatus,
                        );
                        BookStore.addBook(book);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Book added to your library! 📚"),
                            backgroundColor: AppStyles.mutedGreen,
                          ),
                        );
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusOption(String label, ReadingStatus status) {
    final isSelected = _selectedStatus == status;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedStatus = status),
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
