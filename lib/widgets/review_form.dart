import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/restaurant_detail_provider.dart';

class ReviewForm extends StatefulWidget {
  final String restaurantId;
  final VoidCallback? onSuccess;

  const ReviewForm({
    super.key,
    required this.restaurantId,
    this.onSuccess,
  });

  @override
  _ReviewFormState createState() => _ReviewFormState();
}

class _ReviewFormState extends State<ReviewForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _reviewController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      final ok = await context.read<RestaurantDetailProvider>().submitReview(
            id: widget.restaurantId,
            name: _nameController.text.trim(),
            review: _reviewController.text.trim(),
          );

      if (mounted && ok) {
        _nameController.clear();
        _reviewController.clear();
        FocusScope.of(context).unfocus();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Ulasan berhasil dikirim!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        widget.onSuccess?.call();
      }
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal mengirim ulasan: $errorMessage"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = context.watch<RestaurantDetailProvider>().state.isSubmitting;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.rate_review, color: Colors.orange[700]),
                  const SizedBox(width: 8),
                  Text(
                    'Beri Ulasan',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.orange[800],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Nama Anda',
                  filled: true,
                  fillColor: Colors.orange[50],
                  prefixIcon: const Icon(Icons.person_outline, color: Colors.black54),
                  labelStyle: const TextStyle(color: Colors.black54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.orange.shade400,
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Nama tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _reviewController,
                style: const TextStyle(color: Colors.black),
                maxLines: 4,
                maxLength: 200,
                decoration: InputDecoration(
                  labelText: 'Ulasan Anda',
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: Colors.orange[50],
                  prefixIcon: const Icon(Icons.message_outlined, color: Colors.black54),
                  labelStyle: const TextStyle(color: Colors.black54),
                  helperStyle: const TextStyle(color: Colors.black54),
                  helperText: 'Input Maksimal 200 karakter',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.orange.shade400,
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) return 'Ulasan tidak boleh kosong';
                  if (text.length > 200) return 'Maksimal 200 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isSubmitting ? null : _submitReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  icon: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.send_rounded, size: 18),
                  label: Text(
                    isSubmitting ? 'Mengirim...' : 'Kirim Ulasan',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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
