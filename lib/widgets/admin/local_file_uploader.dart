import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../theme/app_theme.dart';

class LocalFileUploader extends StatefulWidget {
  final String label;
  final String? initialBase64;
  final List<String> allowedExtensions;
  final void Function(String base64String) onFileLoaded;
  final VoidCallback? onCleared;

  const LocalFileUploader({
    super.key,
    required this.label,
    this.initialBase64,
    required this.allowedExtensions,
    required this.onFileLoaded,
    this.onCleared,
  });

  @override
  State<LocalFileUploader> createState() => _LocalFileUploaderState();
}

class _LocalFileUploaderState extends State<LocalFileUploader> {
  String? _currentBase64;
  String? _fileName;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _currentBase64 = widget.initialBase64;
    if (_currentBase64 != null && _currentBase64!.isNotEmpty) {
      _fileName = 'Previously Uploaded File';
    }
  }

  Future<void> _pickFile() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: widget.allowedExtensions,
        withData: true, // Need data bytes for Web/Base64
      );

      if (result != null && result.files.isNotEmpty) {
        final PlatformFile file = result.files.first;
        final Uint8List? fileBytes = file.bytes;

        if (fileBytes != null) {
          final String base64Content = base64Encode(fileBytes);
          final String mimeType = _getMimeType(file.extension ?? '');
          final String dataUrl = 'data:$mimeType;base64,$base64Content';

          setState(() {
            _currentBase64 = dataUrl;
            _fileName = file.name;
          });

          widget.onFileLoaded(dataUrl);
        }
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
    }
  }

  String _getMimeType(String ext) {
    switch (ext.toLowerCase()) {
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'gif':
        return 'image/gif';
      case 'pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }

  void _clearFile() {
    setState(() {
      _currentBase64 = null;
      _fileName = null;
    });
    if (widget.onCleared != null) {
      widget.onCleared!();
    } else {
      widget.onFileLoaded('');
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasFile = _currentBase64 != null && _currentBase64!.isNotEmpty;
    final isPdf = _currentBase64?.startsWith('data:application/pdf') ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: _pickFile,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.surface.withValues(alpha: _isHovered ? 0.8 : 0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isHovered ? AppTheme.primary : AppTheme.border,
                  width: 1.5,
                ),
              ),
              child: hasFile
                  ? Stack(
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: isPdf
                                ? const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 40),
                                      SizedBox(height: 8),
                                      Text(
                                        'PDF Document Uploaded',
                                        style: TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.memory(
                                      base64Decode(_currentBase64!.split(',').last),
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Icons.broken_image, color: Colors.grey, size: 40),
                                    ),
                                  ),
                          ),
                        ),
                        // Hover info overlay
                        Positioned(
                          top: 8,
                          right: 8,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.black54,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.close, size: 16, color: Colors.white),
                              onPressed: () {
                                _clearFile();
                              },
                            ),
                          ),
                        ),
                      ],
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload_outlined, color: AppTheme.primary, size: 36),
                        SizedBox(height: 8),
                        Text(
                          'Click to pick file',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Supported files: PNG, JPG, JPEG, PDF',
                          style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        if (_fileName != null && !hasFile) ...[
          const SizedBox(height: 4),
          Text(
            _fileName!,
            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }
}
