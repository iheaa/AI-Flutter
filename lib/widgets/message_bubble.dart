import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final DateTime time;

  const MessageBubble({
    super.key,
    required this.text,
    required this.isUser,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final radius = Radius.circular(14);
    final bg = isUser
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.surfaceContainerHighest;
    final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final textColor = isUser ? Colors.white : Colors.black87;

    return Row(
      mainAxisAlignment: isUser
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        if (!isUser) ...[
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: Icon(Icons.smart_toy, color: Colors.white),
            ),
          ),
        ],
        Flexible(
          child: Column(
            crossAxisAlignment: align,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.only(
                    topLeft: isUser ? radius : Radius.zero,
                    topRight: isUser ? Radius.zero : radius,
                    bottomLeft: radius,
                    bottomRight: radius,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Text(text, style: TextStyle(color: textColor)),
              ),
              const SizedBox(height: 4),
              Text(
                _formatTime(time),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        if (isUser) ...[
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(Icons.person, color: Colors.white),
            ),
          ),
        ],
      ],
    );
  }

  String _formatTime(DateTime t) {
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}
