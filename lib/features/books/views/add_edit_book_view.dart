import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:life_log/core/widgets/custom_text_field.dart';
import 'package:life_log/core/services/storage_service.dart';
import 'package:life_log/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:life_log/features/books/viewmodels/book_viewmodel.dart';
import 'package:life_log/features/books/models/book_model.dart';

class AddEditBookView extends StatefulWidget {
  final bool isEditing;
  final BookModel? book;

  const AddEditBookView({super.key, this.isEditing = false, this.book});

  @override
  State<AddEditBookView> createState() => _AddEditBookViewState();
}

class _AddEditBookViewState extends State<AddEditBookView> {
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _categoryController = TextEditingController();
  File? _selectedImage;
  String? _existingImageUrl;
  final _picker = ImagePicker();
  bool _isSaving = false;
  String _status = 'Reading'; // Reading, Completed, Wishlist

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.book != null) {
      _titleController.text = widget.book!.title;
      _authorController.text = widget.book!.author;
      _categoryController.text = widget.book!.category;
      _existingImageUrl = widget.book!.imageUrl;
      _status = widget.book!.status;
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery, 
        imageQuality: 50,
        maxWidth: 600,
        maxHeight: 600,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  Widget _buildExistingImage() {
    if (_existingImageUrl == null || _existingImageUrl!.isEmpty) {
      return const SizedBox.shrink();
    }
    
    if (_existingImageUrl!.startsWith('data:image')) {
      try {
        final base64String = _existingImageUrl!.split(',').last;
        return Image.memory(base64Decode(base64String), fit: BoxFit.cover);
      } catch (e) {
        return const Icon(Icons.broken_image, size: 40);
      }
    } else {
      // Fallback for old network URLs if any
      return Image.network(_existingImageUrl!, fit: BoxFit.cover);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Book' : 'Add Book'),
        actions: [
          if (widget.isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () {
                if (widget.book != null) {
                  if (mounted) Navigator.pop(context);
                  context.read<BookViewModel>().deleteBook(widget.book!.id);
                }
              },
            ),
          IconButton(
            icon: _isSaving 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.check_rounded),
            onPressed: _isSaving ? null : () {
              final user = context.read<AuthViewModel>().user;
              if (user == null || _titleController.text.trim().isEmpty) return;
              
              final bookViewModel = context.read<BookViewModel>();
              
              setState(() { _isSaving = true; });

              // Pop immediately so the user doesn't have to wait on the image upload
              if (mounted) Navigator.pop(context);

              try {
                String finalImageUrl = _existingImageUrl ?? '';
                if (_selectedImage != null) {
                  final storageService = StorageService();
                  // Fire off the save asynchronously
                  storageService.uploadImage(_selectedImage!, user.uid, 'books').then((uploadedUrl) {
                    if (uploadedUrl != null) {
                      finalImageUrl = uploadedUrl;
                    }
                    _saveBookBackground(bookViewModel, finalImageUrl, user.uid);
                  }).catchError((e) {
                     debugPrint('Storage Error: $e');
                     _saveBookBackground(bookViewModel, finalImageUrl, user.uid);
                  });
                } else {
                  _saveBookBackground(bookViewModel, finalImageUrl, user.uid);
                }
              } catch (e) {
                debugPrint('Failed to save book: ${e.toString()}');
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                label: 'Book Title',
                controller: _titleController,
                hint: 'Enter book title',
              ),
              const SizedBox(height: 20),
              
              CustomTextField(
                label: 'Author',
                controller: _authorController,
                hint: 'Enter author name',
              ),
              const SizedBox(height: 20),

              CustomTextField(
                label: 'Category',
                controller: _categoryController,
                hint: 'e.g. Self-Help, Fiction, Tech',
              ),
              const SizedBox(height: 20),

              Text(
                'Cover Image',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.inputDecorationTheme.fillColor ?? Colors.grey.withOpacity(0.1),
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_selectedImage!, fit: BoxFit.cover),
                        )
                      : (_existingImageUrl != null && _existingImageUrl!.isNotEmpty)
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: _buildExistingImage(),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate_rounded, size: 40, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('Tap to select image', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Status',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: InputDecoration(
                  fillColor: theme.inputDecorationTheme.fillColor,
                  border: theme.inputDecorationTheme.border,
                ),
                items: const [
                  DropdownMenuItem(value: 'Reading', child: Text('Reading')),
                  DropdownMenuItem(value: 'Completed', child: Text('Completed')),
                  DropdownMenuItem(value: 'Wishlist', child: Text('Wishlist')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _status = value;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveBookBackground(BookViewModel bookViewModel, String finalImageUrl, String userId) {
    if (widget.isEditing && widget.book != null) {
       final updatedBook = widget.book!.copyWith(
         title: _titleController.text.trim(),
         author: _authorController.text.trim(),
         category: _categoryController.text.trim(),
         status: _status,
         imageUrl: finalImageUrl,
       );
       bookViewModel.updateBook(updatedBook).catchError((e) {
         debugPrint('Error updating book: $e');
       });
    } else {
       final newBook = BookModel(
         id: '',
         userId: userId,
         title: _titleController.text.trim(),
         author: _authorController.text.trim(),
         category: _categoryController.text.trim(),
         status: _status,
         imageUrl: finalImageUrl,
         createdAt: DateTime.now(),
       );
       bookViewModel.addBook(newBook).catchError((e) {
         debugPrint('Error adding book: $e');
       });
    }
  }
}
