// lib/screens/borrow_receipt_screen.dart
import 'package:flutter/material.dart';
import '../theme/app_styles.dart';

class BorrowReceiptScreen extends StatefulWidget {
  final Map<String, dynamic> book;

  const BorrowReceiptScreen({super.key, required this.book});

  @override
  State<BorrowReceiptScreen> createState() => _BorrowReceiptScreenState();
}

class _BorrowReceiptScreenState extends State<BorrowReceiptScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  late final String _borrowDate;
  late final String _dueDate;
  late final String _receiptNo;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleAnim = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();

    final now = DateTime.now();
    final due = now.add(const Duration(days: 14));
    _borrowDate = _formatDate(now);
    _dueDate = _formatDate(due);
    _receiptNo = "LT-${now.millisecondsSinceEpoch.toString().substring(7)}";
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) {
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

  @override
  Widget build(BuildContext context) {
    final book = widget.book;

    // ── Safe field access — works whether book came from API or hardcoded ──
    final color = (book['color'] as Color?) ?? const Color(0xFF1E3A2E);
    final emoji = (book['emoji'] as String?) ?? '📚';
    final title = (book['title'] as String?) ?? 'Unknown Title';
    final author = (book['author'] as String?) ?? 'Unknown Author';
    final category = (book['category'] as String?) ?? 'General';
    final price = book['price'];
    final priceLabel = price != null ? '₱$price' : 'N/A';
    final quantity = book['quantity'] ?? 1;

    return Scaffold(
      backgroundColor: const Color(0xFF1B3A2E),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // ── SUCCESS ICON ──────────────────────────────────────
                ScaleTransition(
                  scale: _scaleAnim,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: AppStyles.mutedGreen,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppStyles.mutedGreen.withOpacity(0.5),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  "Borrow Successful!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Your book has been reserved. Pick it up at the library.",
                  style: TextStyle(color: Colors.white60, fontSize: 13),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 28),

                // ── RECEIPT CARD ──────────────────────────────────────
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppStyles.softParchment,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Receipt header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [color, color.withOpacity(0.8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  emoji,
                                  style: const TextStyle(fontSize: 32),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    "by $author",
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      category,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Dashed separator
                      _dashedDivider(),

                      // Receipt body
                      Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          children: [
                            // Receipt number
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.receipt_long,
                                  size: 14,
                                  color: AppStyles.warmGrey,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  "RECEIPT NO. $_receiptNo",
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppStyles.warmGrey,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),

                            _receiptRow(
                              Icons.calendar_today_outlined,
                              "Borrow Date",
                              _borrowDate,
                              AppStyles.mutedGreen,
                            ),
                            const SizedBox(height: 12),
                            _receiptRow(
                              Icons.event_outlined,
                              "Due Date",
                              _dueDate,
                              Colors.redAccent,
                            ),
                            const SizedBox(height: 12),
                            _receiptRow(
                              Icons.inventory_2_outlined,
                              "Quantity",
                              "$quantity",
                              AppStyles.primaryBrown,
                            ),
                            const SizedBox(height: 12),
                            _receiptRow(
                              Icons.category_outlined,
                              "Category",
                              category,
                              AppStyles.primaryBrown,
                            ),
                            const SizedBox(height: 12),
                            _receiptRow(
                              Icons.monetization_on_outlined,
                              "Book Price",
                              priceLabel,
                              AppStyles.mutedGreen,
                            ),
                            const SizedBox(height: 12),
                            _receiptRow(
                              Icons.check_circle_outline,
                              "Status",
                              "✓ Borrowed",
                              AppStyles.mutedGreen,
                            ),

                            const SizedBox(height: 18),

                            // Note box
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppStyles.accentGold.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppStyles.accentGold.withOpacity(0.3),
                                ),
                              ),
                              child: const Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 14,
                                    color: AppStyles.accentGold,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "Please return the book within 14 days to avoid any late fees. Present this receipt when picking up.",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppStyles.warmGrey,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Bottom stamp-style footer
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: const BoxDecoration(
                          color: Color(0xFF1B3A2E),
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(20),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            "📚  LibraryTracker • STUDENT PORTAL",
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ── ACTION BUTTONS ────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppStyles.mutedGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    icon: const Icon(Icons.home_outlined),
                    label: const Text(
                      "Back to Dashboard",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.library_books_outlined),
                    label: const Text("Browse More Books"),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _receiptRow(
    IconData icon,
    String label,
    String value,
    Color valueColor,
  ) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: valueColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: valueColor),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppStyles.warmGrey),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _dashedDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: List.generate(
          30,
          (i) => Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: 1.5,
              color: i % 2 == 0 ? Colors.black12 : Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }
}
