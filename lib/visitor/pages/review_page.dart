import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../models/place_model.dart';
import '../constants/app_constants.dart';

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

  @override
  void initState() {
    super.initState();
    _rating = widget.existingReview?.rating ?? 4;
    _controller = TextEditingController(text: widget.existingReview?.comment ?? '');
    _reviewId = widget.existingReview?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    _userId = widget.existingReview?.userId ?? '';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final place = ModalRoute.of(context)?.settings.arguments as Place;
    final appState = Provider.of<AppState>(context, listen: false);
    final currentUser = appState.currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.existingReview != null ? 'Edit Review' : 'Write Review',
          style: TextStyle(
            color: Theme.of(context).appBarTheme.foregroundColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.network(place.imageUrl, width: double.infinity, height: 220, fit: BoxFit.cover),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.title,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      place.address,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
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
                  onPressed: () {
                    setState(() {
                      _rating = index + 1.0;
                    });
                  },
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
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    if (_controller.text.trim().isNotEmpty && currentUser != null) {
                      final review = Review(
                        id: _reviewId,
                        userId: currentUser.id,
                        userName: currentUser.name ?? 'Anonymous',
                        userAvatarUrl: currentUser.profileImageUrl ?? '',
                        rating: _rating,
                        comment: _controller.text.trim(),
                        createdAt: widget.existingReview?.createdAt ?? DateTime.now(),
                      );

                      if (widget.existingReview != null) {
                        appState.updateReview(place.id, review);
                      } else {
                        appState.addReview(place.id, review);
                      }
                    }
                    Navigator.pop(context);
                  },
                  child: Text(
                    widget.existingReview != null ? 'UPDATE' : 'SUBMIT',
                    style: const TextStyle(fontWeight: FontWeight.bold)
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 