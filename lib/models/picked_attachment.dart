import 'dart:typed_data';

class PickedAttachment {
  final String name;
  final String? path; // null on Web
  final Uint8List? bytes; // null on Mobile

  PickedAttachment({
    required this.name,
    this.path,
    this.bytes,
  });

  bool get isImage {
    final ext = name.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(ext);
  }
}
