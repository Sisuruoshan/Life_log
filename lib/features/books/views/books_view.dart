import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:life_log/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:life_log/features/books/viewmodels/book_viewmodel.dart';
import 'package:life_log/features/books/models/book_model.dart';
import 'package:life_log/features/books/views/add_edit_book_view.dart';

class BooksView extends StatefulWidget {
  const BooksView({super.key});

  @override
  State<BooksView> createState() => _BooksViewState();
}

class _BooksViewState extends State<BooksView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthViewModel>().user;
      if (user != null) {
        context.read<BookViewModel>().loadBooks(user.uid);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Tracker'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: theme.primaryColor,
          tabs: const [
            Tab(text: 'Reading'),
            Tab(text: 'Completed'),
            Tab(text: 'Wishlist'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBooksList(context, 'Reading'),
          _buildBooksList(context, 'Completed'),
          _buildBooksList(context, 'Wishlist'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditBookView()),
          );
        },
        backgroundColor: theme.primaryColor,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildBooksList(BuildContext context, String status) {
    final bookViewModel = context.watch<BookViewModel>();

    if (bookViewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final books = bookViewModel.books.where((b) {
      return b.status == status;
    }).toList();

    if (books.isEmpty) {
      return const Center(child: Text('No books found.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: books.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _buildBookCard(context, books[index], status);
      },
    );
  }

  ImageProvider _getImageProvider(String imageUrl) {
    if (imageUrl.startsWith('data:image')) {
      try {
        final base64String = imageUrl.split(',').last;
        return MemoryImage(base64Decode(base64String));
      } catch (_) {}
    }
    return NetworkImage(imageUrl);
  }

  Widget _buildBookCard(BuildContext context, BookModel book, String status) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddEditBookView(isEditing: true, book: book)),
        );
      },
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book Cover Placeholder
              Container(
                width: 80,
                height: 120,
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  image: book.imageUrl.isNotEmpty
                      ? DecorationImage(
                          image: _getImageProvider(book.imageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: book.imageUrl.isEmpty 
                    ? Icon(Icons.menu_book_rounded, size: 40, color: theme.colorScheme.secondary) 
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.author.isNotEmpty ? book.author : 'Unknown Author',
                      style: theme.textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    if (book.category.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          book.category,
                          style: TextStyle(color: theme.primaryColor, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.check_circle_outline),
                tooltip: 'Mark Completed',
                onPressed: () {
                  if (book.status != 'Completed') {
                    context.read<BookViewModel>().updateBookStatus(book, 'Completed');
                  } else {
                    context.read<BookViewModel>().updateBookStatus(book, 'Reading');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
