import 'package:flutter/material.dart';

class FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onTap;
  final String? restaurantName;

  const FavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onTap,
    this.restaurantName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: IconButton(
        icon: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: Colors.red,
        ),
        onPressed: () {
          onTap();
          final message = isFavorite
              ? '${restaurantName ?? 'Restoran'} dihapus dari favorit'
              : '${restaurantName ?? 'Restoran'} ditambahkan ke favorit';
              
          final controller = ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              action: isFavorite
                  ? SnackBarAction(
                      label: 'BATAL',
                      textColor: Colors.orange,
                      onPressed: () {
                        // Call onTap again to toggle back
                        onTap();
                      },
                    )
                  : null,
            ),
          );
          
          // Handle the case where the snackbar is dismissed without pressing the action
          controller.closed.then((SnackBarClosedReason reason) {
            if (reason == SnackBarClosedReason.timeout && isFavorite) {
              // The snackbar was dismissed by timeout, no action needed
            }
          });
        },
      ),
    );
  }
}
