import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book_model.dart';

class BookRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<BookModel>> getBooks(String userId) {
    return _firestore
        .collection('books')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final books = snapshot.docs
          .map((doc) => BookModel.fromMap(doc.data(), doc.id))
          .toList();
      books.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return books;
    });
  }

  Future<void> addBook(BookModel book) async {
    await _firestore.collection('books').add(book.toMap());
  }

  Future<void> updateBook(BookModel book) async {
    await _firestore.collection('books').doc(book.id).update(book.toMap());
  }

  Future<void> deleteBook(String id) async {
    await _firestore.collection('books').doc(id).delete();
  }
}
