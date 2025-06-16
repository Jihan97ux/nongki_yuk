import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../models/place_model.dart';

class ReviewPage extends StatefulWidget {
  final Review? existingReview;
  const ReviewPage({super.key, this.existingReview});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  late double _rating;
  late final TextEditingController _controller;
  late final String _reviewId;
  late final String _userId;
  List<String> _footageUrls = [];
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _rating = widget.existingReview?.rating ?? 4;
    _controller = TextEditingController(text: widget.existingReview?.comment ?? '');
    _reviewId = widget.existingReview?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    _userId = widget.existingReview?.userId ?? '';
    _footageUrls = widget.existingReview?.footage ?? [];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showMediaSourceDialog(AppState appState, {bool isReplace = false}) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                isReplace ? 'Replace Footage' : 'Add Footage',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMediaOption(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      _pickFromCamera(appState, isReplace);
                    },
                  ),
                  _buildMediaOption(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _pickMultipleFootage(appState, isReplace);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMediaOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              size: 30,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFromCamera(AppState appState, bool isReplace) async {
    try {
      // Show dialog to choose between photo or video
      final result = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Choose Media Type'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Take Photo'),
                  onTap: () => Navigator.pop(context, 'photo'),
                ),
                ListTile(
                  leading: const Icon(Icons.videocam),
                  title: const Text('Record Video'),
                  onTap: () => Navigator.pop(context, 'video'),
                ),
              ],
            ),
          );
        },
      );

      if (result != null) {
        XFile? pickedFile;
        if (result == 'photo') {
          pickedFile = await _picker.pickImage(source: ImageSource.camera);
        } else {
          pickedFile = await _picker.pickVideo(source: ImageSource.camera);
        }

        if (pickedFile != null) {
          setState(() => _isUploading = true);
          final urls = await appState.uploadMultipleFootage([pickedFile]);
          setState(() {
            _isUploading = false;
            if (isReplace) {
              _footageUrls = urls;
            } else {
              _footageUrls.addAll(urls);
            }
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking from camera: $e')),
      );
    }
  }

  Future<void> _pickMultipleFootage(AppState appState, bool isReplace) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.media,
    );

    if (result != null && result.files.isNotEmpty) {
      List<XFile> xFiles = result.files
          .where((file) => file.path != null)
          .map((file) => XFile(file.path!))
          .toList();

      if (xFiles.isNotEmpty) {
        setState(() => _isUploading = true);
        final urls = await appState.uploadMultipleFootage(xFiles);
        setState(() {
          _isUploading = false;
          if (isReplace) {
            _footageUrls = urls;
          } else {
            _footageUrls.addAll(urls);
          }
        });
      }
    }
  }

  bool _isVideoUrl(String url) {
    final videoExtensions = ['.mp4', '.mov', '.avi', '.mkv', '.wmv', '.flv', '.webm'];
    final lowerUrl = url.toLowerCase();

    for (String ext in videoExtensions) {
      if (lowerUrl.contains(ext)) return true;
    }

    return url.contains('cloudinary.com') && url.contains('video/');
  }

  String _getCloudinaryThumbnail(String videoUrl) {
    if (videoUrl.contains('cloudinary.com')) {
      return videoUrl.replaceAll(
          '/video/upload/',
          '/video/upload/so_0,h_200,w_200,c_fill,f_jpg/'
      );
    }
    return videoUrl;
  }

  Widget _buildMediaGrid() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      physics: const NeverScrollableScrollPhysics(),
      children: _footageUrls.map((url) {
        final isVideo = _isVideoUrl(url);

        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Tampilkan gambar atau video thumbnail
              Image.network(
                isVideo ? _getCloudinaryThumbnail(url) : url,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: Icon(
                      isVideo ? Icons.video_library : Icons.broken_image,
                      color: Colors.grey[600],
                      size: 32,
                    ),
                  );
                },
              ),

              // Play button untuk video
              if (isVideo)
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(Icons.play_arrow, color: Colors.white, size: 24),
                  ),
                ),

              // Media type indicator
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    isVideo ? Icons.videocam : Icons.image,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final place = ModalRoute.of(context)?.settings.arguments as Place;
    final appState = Provider.of<AppState>(context, listen: false);
    final currentUser = appState.currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.network(place.imageUrl, width: double.infinity, height: 220, fit: BoxFit.cover),
            ),
            const SizedBox(height: 16),
            Text(
              place.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              place.address,
              style: TextStyle(color: Theme.of(context).disabledColor, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const Text('How was your hangout?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) => IconButton(
                icon: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 36,
                ),
                onPressed: () => setState(() => _rating = index + 1.0),
              )),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Write your review here...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (_isUploading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(height: 8),
                    Text('Uploading footage...'),
                  ],
                ),
              )
            else ...[
              if (_footageUrls.isEmpty)
                ElevatedButton.icon(
                  onPressed: () => _showMediaSourceDialog(appState),
                  icon: const Icon(Icons.upload),
                  label: const Text('Upload Footage'),
                )
              else if (widget.existingReview != null)
                TextButton.icon(
                  onPressed: () => _showMediaSourceDialog(appState, isReplace: true),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Replace Footage'),
                ),
              if (_footageUrls.isNotEmpty) _buildMediaGrid(),
              const SizedBox(height: 32),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () async {
                  if (_controller.text.trim().isNotEmpty && currentUser != null) {
                    final review = Review(
                      id: _reviewId,
                      userId: currentUser.id,
                      userName: currentUser.name ?? 'Anonymous',
                      userAvatarUrl: currentUser.profileImageUrl ?? '',
                      rating: _rating,
                      comment: _controller.text.trim(),
                      createdAt: widget.existingReview?.createdAt ?? DateTime.now(),
                      footage: _footageUrls,
                    );

                    bool success = false;

                    try {
                      await appState.saveReviewToFirestore(place.id, review);

                      if (widget.existingReview != null) {
                        appState.updateReview(place.id, review);
                      } else {
                        appState.addReview(place.id, review);
                      }

                      await appState.reloadPlaceFromService(place.id);
                      success = true;

                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    try {
                      await appState.reloadPlaceFromService(place.id);
                    } catch (_) {
                      // optional: log silently
                    }

                    if (success) {
                      Navigator.pop(context, {
                        'refresh': true,
                        'goReviewTab': true,
                        'showMessage': widget.existingReview != null
                            ? 'Review updated successfully!'
                            : 'Review submitted successfully!',
                      });
                    }
                  }
                },
                child: Text(
                  widget.existingReview != null ? 'UPDATE' : 'SUBMIT',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}