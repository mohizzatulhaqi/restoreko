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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black54 : Colors.black26, 
            blurRadius: 4, 
            offset: const Offset(0, 2)
          ),
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
              
          final duration = isFavorite ? 2 : 3;
          final controller = ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                message,
                style: TextStyle(
                  color: isDark ? Colors.black : null,
                ),
              ),
              backgroundColor: isDark ? Colors.grey[300] : null,
              duration: Duration(seconds: duration),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              action: SnackBarAction(
                label: 'BATAL',
                textColor: Colors.orange,
                onPressed: () {
                  onTap();
                },
              ),
            ),
          );
          
          controller.closed.then((SnackBarClosedReason reason) {
            if (reason == SnackBarClosedReason.timeout) {
              // Perform any action when snackbar is dismissed by timeout
            }
          });
        },
      ),
    );
  }
}
