import 'package:flutter/material.dart';
import 'dart:math' as math;

/// A custom color picker widget with a square preview and circular color palette.
/// 
/// Shows a square color preview that opens a circular color palette when tapped.
/// The palette stays open while the user is touching and selecting colors.
class XtcColorPicker extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onColorChanged;
  final double size;

  const XtcColorPicker({
    super.key,
    required this.initialColor,
    required this.onColorChanged,
    this.size = 60,
  });

  @override
  State<XtcColorPicker> createState() => _XtcColorPickerState();
}

class _XtcColorPickerState extends State<XtcColorPicker> with SingleTickerProviderStateMixin {
  late Color _selectedColor;
  bool _showPalette = false;
  Offset? _paletteOffset;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showColorPalette(BuildContext context, Offset position) {
    setState(() {
      _showPalette = true;
      _paletteOffset = position;
    });
    _animationController.forward();
  }

  void _hideColorPalette() {
    _animationController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _showPalette = false;
          _paletteOffset = null;
        });
      }
    });
  }

  void _selectColor(Color color) {
    setState(() {
      _selectedColor = color;
    });
    widget.onColorChanged(color);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTapDown: (details) {
            final RenderBox renderBox = context.findRenderObject() as RenderBox;
            final position = renderBox.localToGlobal(Offset.zero);
            _showColorPalette(context, position);
          },
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: _selectedColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.withOpacity(0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {},
                  child: const Center(
                    child: Icon(
                      Icons.palette,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_showPalette && _paletteOffset != null)
          Positioned(
            left: _paletteOffset!.dx - 120, // Center the palette
            top: _paletteOffset!.dy + widget.size + 10,
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: ColorPalette(
                    onColorSelected: _selectColor,
                    onDismiss: _hideColorPalette,
                    previewColor: _selectedColor,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

/// Circular color palette widget with common XTC colors.
class ColorPalette extends StatefulWidget {
  final ValueChanged<Color> onColorSelected;
  final VoidCallback onDismiss;
  final Color previewColor;

  const ColorPalette({
    super.key,
    required this.onColorSelected,
    required this.onDismiss,
    required this.previewColor,
  });

  @override
  State<ColorPalette> createState() => _ColorPaletteState();
}

class _ColorPaletteState extends State<ColorPalette> {
  Color _currentPreview = Colors.transparent;

  // Common XTC/pill colors
  static const List<Color> _colors = [
    // Bright/neon colors
    Colors.pink,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.purple,
    Colors.yellow,
    Colors.cyan,
    
    // Pastel colors
    Color(0xFFFFB6C1), // Light pink
    Color(0xFFADD8E6), // Light blue
    Color(0xFF90EE90), // Light green
    Color(0xFFFFE4B5), // Moccasin
    Color(0xFFFFA07A), // Light salmon
    Color(0xFFDDA0DD), // Plum
    Color(0xFFFFFF99), // Light yellow
    Color(0xFFAFEEEE), // Pale turquoise
    
    // Darker colors
    Color(0xFF8B0000), // Dark red
    Color(0xFF00008B), // Dark blue
    Color(0xFF006400), // Dark green
    Color(0xFF8B4513), // Saddle brown
    Color(0xFF4B0082), // Indigo
    Color(0xFF800080), // Purple
    Color(0xFF2F4F4F), // Dark slate gray
    Color(0xFF000000), // Black
  ];

  @override
  void initState() {
    super.initState();
    _currentPreview = widget.previewColor;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onDismiss,
      child: Container(
        width: 240,
        height: 280,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Preview section
            Container(
              width: double.infinity,
              height: 60,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _currentPreview,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  'Vorschau',
                  style: TextStyle(
                    color: _currentPreview.computeLuminance() > 0.5 
                        ? Colors.black 
                        : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            // Color grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _colors.length,
                  itemBuilder: (context, index) {
                    final color = _colors[index];
                    return GestureDetector(
                      onTapDown: (_) {
                        setState(() {
                          _currentPreview = color;
                        });
                      },
                      onTapUp: (_) {
                        widget.onColorSelected(color);
                        widget.onDismiss();
                      },
                      onLongPressStart: (_) {
                        setState(() {
                          _currentPreview = color;
                        });
                      },
                      onLongPressEnd: (_) {
                        widget.onColorSelected(color);
                        widget.onDismiss();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.5),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}