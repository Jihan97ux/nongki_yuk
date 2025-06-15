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

  Future<void> _pickMultipleFootage(AppState appState) async {
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
        final urls = await appState.uploadMultipleFootage(xFiles);
        setState(() {
          _footageUrls.addAll(urls);
        });
      }
    }
  }

  void _replaceFootage(AppState appState) async {
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
        final urls = await appState.uploadMultipleFootage(xFiles);
        setState(() {
          _footageUrls = urls;
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
            if (_footageUrls.isEmpty)
              ElevatedButton.icon(
                onPressed: () => _pickMultipleFootage(appState),
                icon: const Icon(Icons.upload),
                label: const Text('Upload Footage'),
              )
            else if (widget.existingReview != null)
              TextButton.icon(
                onPressed: () => _replaceFootage(appState),
                icon: const Icon(Icons.refresh),
                label: const Text('Upload Footage'),
              ),
            const SizedBox(height: 16),
            if (_footageUrls.isNotEmpty) _buildMediaGrid(),
            const SizedBox(height: 32),
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

                    if (widget.existingReview != null) {
                      appState.updateReview(place.id, review);
                    } else {
                      appState.addReview(place.id, review);
                    }

                    await appState.saveReviewToFirestore(place.id, review);
                    Navigator.pop(context, true);
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