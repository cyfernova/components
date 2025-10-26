import 'package:flutter/material.dart';

/// An animated search bar that expands and collapses with smooth transitions
class AnimatedSearchBar extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSearch;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;
  final String hintText;
  final double height;
  final double collapsedWidth;
  final double expandedWidth;

  const AnimatedSearchBar({
    super.key,
    this.onChanged,
    this.onSearch,
    this.backgroundColor = Colors.white,
    this.iconColor = Colors.grey,
    this.textColor = Colors.black,
    this.hintText = 'Search...',
    this.height = 50,
    this.collapsedWidth = 50,
    this.expandedWidth = 300,
  });

  @override
  State<AnimatedSearchBar> createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<AnimatedSearchBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _widthAnimation;
  late Animation<double> _fadeAnimation;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _widthAnimation = Tween<double>(
      begin: widget.collapsedWidth,
      end: widget.expandedWidth,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
    ));

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _textController.text.isEmpty) {
        _collapse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _expand() {
    if (!_isExpanded) {
      setState(() => _isExpanded = true);
      _controller.forward();
      Future.delayed(const Duration(milliseconds: 200), () {
        _focusNode.requestFocus();
      });
    }
  }

  void _collapse() {
    if (_isExpanded) {
      setState(() => _isExpanded = false);
      _controller.reverse();
      _focusNode.unfocus();
    }
  }

  void _clear() {
    _textController.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(final BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: _widthAnimation.value,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(widget.height / 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: _isExpanded ? widget.onSearch : _expand,
                child: Container(
                  width: widget.height,
                  height: widget.height,
                  decoration: BoxDecoration(
                    color: _isExpanded
                        ? Colors.blue.withOpacity(0.1)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.search,
                    color: widget.iconColor,
                    size: 24,
                  ),
                ),
              ),
              if (_isExpanded)
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      onChanged: widget.onChanged,
                      onSubmitted: (_) => widget.onSearch?.call(),
                      style: TextStyle(
                        color: widget.textColor,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: widget.hintText,
                        hintStyle: TextStyle(
                          color: widget.iconColor,
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ),
                ),
              if (_isExpanded && _textController.text.isNotEmpty)
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: GestureDetector(
                    onTap: _clear,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.clear,
                        color: widget.iconColor,
                        size: 20,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
