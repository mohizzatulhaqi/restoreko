import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/menu_item.dart' as menu_item_model;

class MenuItemCard extends StatefulWidget {
  final menu_item_model.MenuItem item;
  final Color backgroundColor;
  final IconData icon;

  const MenuItemCard({
    super.key,
    required this.item,
    this.backgroundColor = const Color(0xFFFFF3E0),
    this.icon = Icons.restaurant_menu,
  });

  @override
  State<MenuItemCard> createState() => _MenuItemCardState();
}

class _MenuItemCardState extends State<MenuItemCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  final bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.grey[800]! : widget.backgroundColor;
    final textColor = isDark ? Colors.white : Colors.grey[800];
    final iconColor = isDark ? Colors.orange[300] : Colors.orange[700];
    final borderColor = isDark ? Colors.grey[700]! : Colors.white.withOpacity(0.5);
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                if (!isDark) ...[
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: _isPressed ? 4 : 8,
                    offset: Offset(0, _isPressed ? 2 : 4),
                    spreadRadius: _isPressed ? 0 : 1,
                  ),
                  BoxShadow(
                    color: isDark ? Colors.grey[900]! : Colors.white.withOpacity(0.8),
                    blurRadius: 2,
                    offset: const Offset(-1, -1),
                  ),
                ],
              ],
              border: Border.all(
                color: isDark ? Colors.grey[700]! : borderColor,
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[700] : Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? Colors.grey[600]! : Colors.white.withOpacity(0.6),
                        width: 1,
                      ),
                      boxShadow: isDark
                          ? null
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(1, 1),
                              ),
                            ],
                    ),
                    child: Icon(
                      widget.icon,
                      color: iconColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.item.name,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                          height: 1.1,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
