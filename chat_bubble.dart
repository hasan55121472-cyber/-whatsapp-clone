import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../utils/helpers.dart';
import '../models/message_model.dart';

class ChatBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final bool showTail;
  final bool antiDeleteOn; // receiver anti-delete setting (only relevant for incoming)
  final String viewerUid;
  final void Function(String url)? onPlayVoice;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.viewerUid,
    this.showTail = true,
    this.antiDeleteOn = false,
    this.onPlayVoice,
  });

  @override
  Widget build(BuildContext context) {
    final isDeleted = message.isDeletedForEveryone;
    // Hide if deleted for the current viewer.
    if (message.isDeletedForMe(viewerUid)) {
      return const SizedBox.shrink();
    }

    final bubbleColor = isMe
        ? AppTheme.outgoingBubble
        : AppTheme.incomingBubble;
    final deletedColor = Colors.grey.shade400;

    String displayText = message.text;
    if (isDeleted) {
      if (!isMe && antiDeleteOn) {
        // Receiver has anti-delete ON: reveal original.
        displayText =
            '🚫 Sender deleted this message - Original: ${message.originalText}';
      } else {
        displayText = '🚫 This message was deleted';
      }
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78),
        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDeleted ? deletedColor : bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(12),
          ),
        ),
        child: message.type == 'voice' && !isDeleted
            ? _voiceRow(context)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    displayText,
                    style: TextStyle(
                      fontSize: 15,
                      color: isDeleted ? Colors.white70 : Colors.black87,
                      fontStyle: isDeleted ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        formatMessageTime(message.timestamp),
                        style: TextStyle(
                            fontSize: 10,
                            color: isDeleted
                                ? Colors.white60
                                : Colors.black45),
                      ),
                      if (isMe && !isDeleted) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.done_all,
                            size: 14, color: AppTheme.primaryLight),
                      ],
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _voiceRow(BuildContext context) {
    return GestureDetector(
      onTap: () => onPlayVoice?.call(message.voiceUrl),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.play_arrow,
              color: isMe ? AppTheme.primary : AppTheme.primaryLight),
          const SizedBox(width: 6),
          const SizedBox(
            width: 100,
            height: 24,
            child: _Waveform(),
          ),
          const SizedBox(width: 6),
          Text(formatMessageTime(message.timestamp),
              style: const TextStyle(fontSize: 10, color: Colors.black45)),
        ],
      ),
    );
  }

  // The viewer uid is passed in by the chat screen for the "deleted for me" check.
}

class _Waveform extends StatelessWidget {
  const _Waveform();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _WavePainter(),
      size: const Size(100, 24),
    );
  }
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryLight
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2;
    const bars = 18;
    final step = size.width / bars;
    final heights = [
      0.3, 0.5, 0.8, 0.6, 0.9, 0.4, 0.7, 1.0, 0.5, 0.6,
      0.8, 0.4, 0.7, 0.9, 0.5, 0.6, 0.4, 0.7
    ];
    for (int i = 0; i < bars; i++) {
      final h = size.height * heights[i];
      final x = i * step + step / 2;
      canvas.drawLine(
        Offset(x, (size.height - h) / 2),
        Offset(x, (size.height + h) / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
