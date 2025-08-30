import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/menu_item.dart' as menu_item_model;
import 'menu_item_card.dart';

class MenuSection extends StatelessWidget {
  final String title;
  final List<menu_item_model.MenuItem> items;
  final Color cardColor;
  final IconData icon;

  const MenuSection({
    super.key,
    required this.title,
    required this.items,
    this.cardColor = const Color(0xFFFFF3E0),
    this.icon = Icons.restaurant_menu,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.grey[900] : Colors.orange[50];
    final iconBackground = isDark ? Colors.grey[800] : Colors.orange[100];
    final textColor = isDark ? Colors.white : Colors.black87;
    final shadowColor = isDark ? Colors.black.withOpacity(0.3) : Colors.orange.withOpacity(0.1);
    final accentColor = isDark ? Colors.orange[300] : Colors.orange[600];
    final cardColor = isDark ? Colors.grey[800] : this.cardColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark 
                        ? [Colors.grey[700]!, Colors.grey[800]!]
                        : [Colors.orange.shade400, Colors.orange.shade600],
                  ),
                ),
                child: Icon(
                  icon,
                  color: isDark ? Colors.orange[300] : Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${items.length} item${items.length > 1 ? 's' : ''} tersedia',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
    
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3.2,
              crossAxisSpacing: 6,
              mainAxisSpacing: 16,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return AnimatedContainer(
                duration: Duration(milliseconds: 200 + (index * 50)),
                child: MenuItemCard(
                  item: items[index],
                  backgroundColor: cardColor!,
                  icon: icon,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
