enum ReadingStatus { wantToRead, reading, finished }

class Book {
  final String id;
  final String title;
  final String author;
  final String genre;
  final String coverEmoji;
  final int totalPages;
  int currentPage;
  ReadingStatus status;
  double rating; // 0 to 5
  String notes;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.genre,
    required this.coverEmoji,
    required this.totalPages,
    this.currentPage = 0,
    this.status = ReadingStatus.wantToRead,
    this.rating = 0,
    this.notes = '',
  });

  double get progressPercent =>
      totalPages > 0 ? (currentPage / totalPages).clamp(0.0, 1.0) : 0.0;

  String get statusLabel {
    switch (status) {
      case ReadingStatus.wantToRead:
        return 'Want to Read';
      case ReadingStatus.reading:
        return 'Reading';
      case ReadingStatus.finished:
        return 'Finished';
    }
  }
}

class BookStore {
  static final List<Book> _books = [];

  static List<Book> get all => _books;

  static List<String> get genres {
    final g = _books.map((b) => b.genre).toSet().toList();
    g.sort();
    return ['All', ...g];
  }

  static void addBook(Book book) => _books.add(book);

  static void removeBook(String id) => _books.removeWhere((b) => b.id == id);

  static List<Book> search(
    String query, {
    String genre = 'All',
    ReadingStatus? status,
  }) {
    return _books.where((b) {
      final matchesQuery =
          query.isEmpty ||
          b.title.toLowerCase().contains(query.toLowerCase()) ||
          b.author.toLowerCase().contains(query.toLowerCase());
      final matchesGenre = genre == 'All' || b.genre == genre;
      final matchesStatus = status == null || b.status == status;
      return matchesQuery && matchesGenre && matchesStatus;
    }).toList();
  }

  static Map<String, int> get stats => {
    'total': _books.length,
    'finished': _books.where((b) => b.status == ReadingStatus.finished).length,
    'reading': _books.where((b) => b.status == ReadingStatus.reading).length,
    'wantToRead': _books
        .where((b) => b.status == ReadingStatus.wantToRead)
        .length,
  };
}

class User {
  final String firstName;
  final String lastName;
  final String username;
  final String course;
  final String email;
  final String password;

  User({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.course,
    required this.email,
    required this.password,
  });
}

class AuthService {
  static final List<User> _users = [];

  static bool usernameExists(String username) {
    return _users.any(
      (u) => u.username.toLowerCase() == username.toLowerCase(),
    );
  }

  static void register({
    required String firstName,
    required String lastName,
    required String username,
    required String course,
    required String email,
    required String password,
  }) {
    _users.add(
      User(
        firstName: firstName,
        lastName: lastName,
        username: username,
        course: course,
        email: email,
        password: password,
      ),
    );
  }

  static bool validateCredentials(String username, String password) {
    return _users.any(
      (u) =>
          u.username.toLowerCase() == username.toLowerCase() &&
          u.password == password,
    );
  }

  /// Returns the user matching the username (case-insensitive), or null if none.
  static User? getByUsername(String username) {
    try {
      return _users.firstWhere(
        (u) => u.username.toLowerCase() == username.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }
}
