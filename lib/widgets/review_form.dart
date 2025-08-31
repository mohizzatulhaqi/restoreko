import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/restaurant_detail_provider.dart';

class ReviewForm extends StatefulWidget {
  final String restaurantId;
  final VoidCallback? onSuccess;

  const ReviewForm({super.key, required this.restaurantId, this.onSuccess});

  @override
  State<ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<ReviewForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _reviewController = TextEditingController();
  bool _isExpanded = false;

  @override
  void dispose() {
    _nameController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _nameController.clear();
    _reviewController.clear();
    setState(() {
      _isExpanded = false;
    });
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<RestaurantDetailProvider>();

    // Clear any previous submit errors
    provider.clearSubmitError();

    final success = await provider.submitReview(
      id: widget.restaurantId,
      name: _nameController.text.trim(),
      review: _reviewController.text.trim(),
    );

    if (success) {
      // Clear form and collapse on success
      _clearForm();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                const Expanded(child: Text('Ulasan berhasil dikirim!')),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );

        // Call onSuccess callback
        widget.onSuccess?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RestaurantDetailProvider>(
      builder: (context, provider, _) {
        final state = provider.state;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.rate_review,
                      color: Colors.orange[800],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Berikan Ulasan',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[800],
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: state.isSubmitting
                          ? null
                          : () {
                              setState(() {
                                _isExpanded = !_isExpanded;
                              });
                            },
                      icon: Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.orange[800],
                      ),
                    ),
                  ],
                ),

                // Show submit error if any
                if (state.submitError != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red[600],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            state.submitError!,
                            style: TextStyle(
                              color: Colors.red[600],
                              fontSize: 13,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: provider.clearSubmitError,
                          icon: Icon(
                            Icons.close,
                            color: Colors.red[600],
                            size: 18,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                ],

                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            enabled: !state.isSubmitting,
                            decoration: InputDecoration(
                              labelText: 'Nama Anda',
                              hintText: 'Masukkan nama Anda',
                              prefixIcon: Icon(
                                Icons.person,
                                color: Colors.orange[600],
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.orange[600]!,
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Nama tidak boleh kosong';
                              }
                              if (value.trim().length < 2) {
                                return 'Nama minimal 2 karakter';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _reviewController,
                            enabled: !state.isSubmitting,
                            maxLines: 4,
                            decoration: InputDecoration(
                              labelText: 'Ulasan Anda',
                              hintText:
                                  'Bagikan pengalaman Anda di restoran ini...',
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(bottom: 60),
                                child: Icon(
                                  Icons.comment,
                                  color: Colors.orange[600],
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.orange[600]!,
                                  width: 2,
                                ),
                              ),
                              alignLabelWithHint: true,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Ulasan tidak boleh kosong';
                              }
                              if (value.trim().length < 10) {
                                return 'Ulasan minimal 10 karakter';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: state.isSubmitting
                                    ? null
                                    : () {
                                        _clearForm();
                                      },
                                child: const Text('Batal'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: state.isSubmitting
                                    ? null
                                    : _submitReview,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange[600],
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                                child: state.isSubmitting
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : const Text('Kirim Ulasan'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  crossFadeState: _isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
