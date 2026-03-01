import 'dart:async';
import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../repositories/book_repository.dart';

class BookViewModel extends ChangeNotifier {
  final BookRepository _repository = BookRepository();
  StreamSubscription? _subscription;
  
  List<BookModel> _books = [];
  bool _isLoading = false;

  List<BookModel> get books => _books;
  bool get isLoading => _isLoading;

  void loadBooks(String userId) {
    if (_subscription != null) return; // Prevent multiple subscriptions
    _isLoading = true;
    notifyListeners();

    _subscription = _repository.getBooks(userId).listen((bookList) {
      _books = bookList;
      _isLoading = false;
      notifyListeners();
    }, onError: (_) {
      _books = [];
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addBook(BookModel book) async {
    await _repository.addBook(book);
  }

  Future<void> updateBook(BookModel book) async {
    await _repository.updateBook(book);
  }

  Future<void> deleteBook(String id) async {
    await _repository.deleteBook(id);
  }

  Future<void> updateBookStatus(BookModel book, String status) async {
    final updatedBook = book.copyWith(status: status);
    await _repository.updateBook(updatedBook);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
