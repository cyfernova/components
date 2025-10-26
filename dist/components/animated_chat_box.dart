import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Model for chat messages
class ChatMessage {
  final String message;
  final bool isMe;
  final DateTime timestamp;
  final String? senderName;

  ChatMessage({
    required this.message,
    required this.isMe,
    required this.timestamp,
    this.senderName,
  });
}

/// Modern animated chat box component
class AnimatedChatBox extends StatefulWidget {
  final List<ChatMessage> messages;
  final Function(String)? onSendMessage;
  final String? currentUserName;
  final Color? myMessageColor;
  final Color? otherMessageColor;

  const AnimatedChatBox({
    Key? key,
    required this.messages,
    this.onSendMessage,
    this.currentUserName,
    this.myMessageColor,
    this.otherMessageColor,
  }) : super(key: key);

  @override
  State<AnimatedChatBox> createState() => _AnimatedChatBoxState();
}

class _AnimatedChatBoxState extends State<AnimatedChatBox>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  late AnimationController _typingController;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _typingController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    _textController.addListener(() {
      setState(() {
        _isTyping = _textController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _typingController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_textController.text.trim().isEmpty) return;

    final message = _textController.text.trim();
    _textController.clear();
    widget.onSendMessage?.call(message);

    // Auto scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final myMessageColor =
        widget.myMessageColor ?? Theme.of(context).primaryColor;
    final otherMessageColor = widget.otherMessageColor ??
        (isDark ? Colors.grey[800]! : Colors.grey[200]!);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [myMessageColor, myMessageColor.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.currentUserName ?? 'Chat',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.greenAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Active now',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // Messages list
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: widget.messages.length,
                itemBuilder: (context, index) {
                  return _MessageBubble(
                    message: widget.messages[index],
                    myMessageColor: myMessageColor,
                    otherMessageColor: otherMessageColor,
                    isDark: isDark,
                    index: index,
                  );
                },
              ),
            ),

            // Typing indicator
            AnimatedBuilder(
              animation: _typingController,
              builder: (context, child) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _isTyping ? 0 : 40,
                  child: _isTyping
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.only(left: 20, bottom: 8),
                          child: Row(
                            children: [
                              _TypingDot(
                                animation: _typingController,
                                delay: 0.0,
                              ),
                              const SizedBox(width: 4),
                              _TypingDot(
                                animation: _typingController,
                                delay: 0.2,
                              ),
                              const SizedBox(width: 4),
                              _TypingDot(
                                animation: _typingController,
                                delay: 0.4,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'typing...',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.grey[500]
                                      : Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                );
              },
            ),

            // Input field
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.grey[100],
                border: Border(
                  top: BorderSide(
                    color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Emoji button
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.emoji_emotions_outlined,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        size: 22,
                      ),
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Text field
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _textController,
                        focusNode: _focusNode,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(
                            color: isDark ? Colors.grey[500] : Colors.grey[400],
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                        ),
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Send button
                  AnimatedScale(
                    scale: _isTyping ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            myMessageColor,
                            myMessageColor.withOpacity(0.8)
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send_rounded,
                            color: Colors.white, size: 20),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatefulWidget {
  final ChatMessage message;
  final Color myMessageColor;
  final Color otherMessageColor;
  final bool isDark;
  final int index;

  const _MessageBubble({
    required this.message,
    required this.myMessageColor,
    required this.otherMessageColor,
    required this.isDark,
    required this.index,
  });

  @override
  State<_MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<_MessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(widget.message.isMe ? 0.3 : -0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: widget.message.isMe
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              if (!widget.message.isMe) ...[
                CircleAvatar(
                  radius: 16,
                  backgroundColor: widget.otherMessageColor,
                  child: Text(
                    widget.message.senderName?[0].toUpperCase() ?? 'U',
                    style: TextStyle(
                      color: widget.isDark ? Colors.white : Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: widget.message.isMe
                        ? LinearGradient(
                            colors: [
                              widget.myMessageColor,
                              widget.myMessageColor.withOpacity(0.8)
                            ],
                          )
                        : null,
                    color:
                        widget.message.isMe ? null : widget.otherMessageColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(widget.message.isMe ? 20 : 4),
                      bottomRight:
                          Radius.circular(widget.message.isMe ? 4 : 20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.message.message,
                        style: TextStyle(
                          color: widget.message.isMe
                              ? Colors.white
                              : (widget.isDark ? Colors.white : Colors.black),
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTime(widget.message.timestamp),
                        style: TextStyle(
                          color: widget.message.isMe
                              ? Colors.white70
                              : (widget.isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600]),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (widget.message.isMe) const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}

class _TypingDot extends StatelessWidget {
  final Animation<double> animation;
  final double delay;

  const _TypingDot({
    required this.animation,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final value = math.sin((animation.value - delay) * math.pi * 2);
        return Transform.translate(
          offset: Offset(0, value * 4),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[500] : Colors.grey[600],
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
