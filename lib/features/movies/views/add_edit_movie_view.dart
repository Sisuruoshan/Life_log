import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:life_log/core/widgets/custom_text_field.dart';
import 'package:life_log/core/services/storage_service.dart';
import 'package:life_log/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:life_log/features/movies/viewmodels/movie_viewmodel.dart';
import 'package:life_log/features/movies/models/movie_model.dart';

class AddEditMovieView extends StatefulWidget {
  final bool isEditing;
  final MovieModel? movie;

  const AddEditMovieView({super.key, this.isEditing = false, this.movie});

  @override
  State<AddEditMovieView> createState() => _AddEditMovieViewState();
}

class _AddEditMovieViewState extends State<AddEditMovieView> {
  final _titleController = TextEditingController();
  final _genreController = TextEditingController();
  final _ratingController = TextEditingController();
  File? _selectedImage;
  String? _existingImageUrl;
  final _picker = ImagePicker();
  bool _isSaving = false;
  String _status = 'Watched'; // Watched, Watchlist

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.movie != null) {
      _titleController.text = widget.movie!.title;
      _genreController.text = widget.movie!.genre;
      _ratingController.text = widget.movie!.rating.toString();
      _existingImageUrl = widget.movie!.imageUrl;
      _status = widget.movie!.isWatched ? 'Watched' : 'Watchlist';
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
        title: Text(widget.isEditing ? 'Edit Movie' : 'Add Movie'),
        actions: [
          if (widget.isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () {
                if (widget.movie != null) {
                  if (mounted) Navigator.pop(context);
                  context.read<MovieViewModel>().deleteMovie(widget.movie!.id);
                }
              },
            ),
          IconButton(
            icon: _isSaving 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.check_rounded),
            onPressed: _isSaving ? null : () {
              final user = context.read<AuthViewModel>().user;
              if (user == null) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please log in to save movie.')),
                  );
                }
                return;
              }

              final title = _titleController.text.trim();
              if (title.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Movie title is required.')),
                );
                return;
              }

              final movieViewModel = context.read<MovieViewModel>();
              final parsedRating = double.tryParse(_ratingController.text.trim()) ?? 0.0;
              final rating = parsedRating.clamp(0.0, 5.0);
              final isWatched = _status == 'Watched';

              setState(() { _isSaving = true; });

              // Pop immediately so the user doesn't have to wait on the image upload
              if (mounted) Navigator.pop(context);

              try {
                String finalImageUrl = _existingImageUrl ?? '';
                if (_selectedImage != null) {
                  final storageService = StorageService();
                  // Fire off the save asynchronously
                  storageService.uploadImage(_selectedImage!, user.uid, 'movies').then((uploadedUrl) {
                    if (uploadedUrl != null) {
                      finalImageUrl = uploadedUrl;
                    }
                    _saveMovieBackground(movieViewModel, title, rating, isWatched, finalImageUrl, user.uid);
                  }).catchError((e) {
                     debugPrint('Storage Error: $e');
                     _saveMovieBackground(movieViewModel, title, rating, isWatched, finalImageUrl, user.uid);
                  });
                } else {
                  _saveMovieBackground(movieViewModel, title, rating, isWatched, finalImageUrl, user.uid);
                }
              } catch (e) {
                debugPrint('Failed to save movie: ${e.toString()}');
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
                label: 'Movie Title',
                controller: _titleController,
                hint: 'Enter movie title',
              ),
              const SizedBox(height: 20),
              
              CustomTextField(
                label: 'Genre',
                controller: _genreController,
                hint: 'e.g. Action, Comedy, Sci-Fi',
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
              const SizedBox(height: 20),

              CustomTextField(
                label: 'Rating (0.0 - 5.0)',
                controller: _ratingController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                hint: 'e.g. 4.5',
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
                  DropdownMenuItem(value: 'Watched', child: Text('Watched')),
                  DropdownMenuItem(value: 'Watchlist', child: Text('Watchlist')),
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

  void _saveMovieBackground(MovieViewModel movieViewModel, String title, double rating, bool isWatched, String finalImageUrl, String userId) {
    if (widget.isEditing && widget.movie != null) {
      final updatedMovie = widget.movie!.copyWith(
        title: title,
        genre: _genreController.text.trim(),
        rating: rating,
        isWatched: isWatched,
        imageUrl: finalImageUrl,
      );
      movieViewModel.updateMovie(updatedMovie).catchError((e) {
        debugPrint('Error updating movie: $e');
      });
    } else {
      final newMovie = MovieModel(
        id: '',
        userId: userId,
        title: title,
        genre: _genreController.text.trim(),
        rating: rating,
        isWatched: isWatched,
        imageUrl: finalImageUrl,
        createdAt: DateTime.now(),
      );
      movieViewModel.addMovie(newMovie).catchError((e) {
        debugPrint('Error adding movie: $e');
      });
    }
  }
}
