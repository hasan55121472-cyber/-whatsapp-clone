import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/theme.dart';

/// Avatar that respects photoPrivacy ('nobody' shows the initial letter).
class Avatar extends StatelessWidget {
  final String name;
  final String photoUrl;
  final String photoPrivacy;
  final double radius;

  const Avatar({
    super.key,
    required this.name,
    required this.photoUrl,
    this.photoPrivacy = 'everyone',
    this.radius = 26,
  });

  @override
  Widget build(BuildContext context) {
    final showPhoto = photoPrivacy == 'everyone' && photoUrl.isNotEmpty;
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppTheme.primaryLight,
      backgroundImage:
          showPhoto ? CachedNetworkImageProvider(photoUrl) : null,
      child: !showPhoto
          ? Text(
              _initial(name),
              style: TextStyle(
                  color: Colors.white,
                  fontSize: radius * 0.7,
                  fontWeight: FontWeight.w600),
            )
          : null,
    );
  }

  String _initial(String n) =>
      n.isEmpty ? '?' : n.trim().substring(0, 1).toUpperCase();
}
