import 'dart:async';
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
  
  // Progress & feedback state
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _errorMessage;
  bool _showSuccessFeedback = false;
  Timer? _progressTimer;
  Timer? _feedbackTimer;

  @override
  void initState() {
    super.initState();
    _currentBase64 = widget.initialBase64;
    if (_currentBase64 != null && _currentBase64!.isNotEmpty) {
      _fileName = _currentBase64!.startsWith('data:application/pdf')
          ? 'Certificate Document (PDF)'
          : 'Certificate Preview (Image)';
    }
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _feedbackTimer?.cancel();
    super.dispose();
  }

  Future<void> _pickFile() async {
    _progressTimer?.cancel();
    _feedbackTimer?.cancel();
    
    setState(() {
      _errorMessage = null;
      _showSuccessFeedback = false;
    });

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
          // Validate file size (limit to 4MB for memory/firestore constraints)
          final double sizeInMb = fileBytes.length / (1024 * 1024);
          if (sizeInMb > 4.0) {
            setState(() {
              _errorMessage = 'File too large (${sizeInMb.toStringAsFixed(1)}MB). Max size is 4MB.';
            });
            return;
          }

          // Trigger simulated progress indicator
          setState(() {
            _isUploading = true;
            _uploadProgress = 0.0;
          });

          const duration = Duration(milliseconds: 30);
          _progressTimer = Timer.periodic(duration, (timer) {
            if (!mounted) {
              timer.cancel();
              return;
            }
            setState(() {
              _uploadProgress += 0.08;
              if (_uploadProgress >= 1.0) {
                _uploadProgress = 1.0;
                _isUploading = false;
                
                final String base64Content = base64Encode(fileBytes);
                final String mimeType = _getMimeType(file.extension ?? '');
                final String dataUrl = 'data:$mimeType;base64,$base64Content';

                _currentBase64 = dataUrl;
                _fileName = file.name;
                _showSuccessFeedback = true;

                widget.onFileLoaded(dataUrl);
                timer.cancel();

                // Hide success feedback banner after 3 seconds
                _feedbackTimer = Timer(const Duration(seconds: 3), () {
                  if (mounted) {
                    setState(() {
                      _showSuccessFeedback = false;
                    });
                  }
                });
              }
            });
          });
        } else {
          setState(() {
            _errorMessage = 'Failed to read file bytes.';
          });
        }
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
      setState(() {
        _isUploading = false;
        _errorMessage = 'Error picking file: ${e.toString()}';
      });
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
    _progressTimer?.cancel();
    _feedbackTimer?.cancel();
    
    setState(() {
      _currentBase64 = null;
      _fileName = null;
      _isUploading = false;
      _uploadProgress = 0.0;
      _errorMessage = null;
      _showSuccessFeedback = false;
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
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppTheme.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),

        // Drop zone or Preview container
        MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.surface.withValues(alpha: _isHovered ? 0.6 : 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _errorMessage != null
                    ? Colors.redAccent.withValues(alpha: 0.6)
                    : (_isHovered ? AppTheme.primary : AppTheme.border),
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildUploaderContent(hasFile, isPdf),
            ),
          ),
        ),
        
        // Success / Error Feedback Banners
        if (_errorMessage != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.error_outline_rounded, size: 14, color: Colors.redAccent),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(fontSize: 12, color: Colors.redAccent, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ],
        if (_showSuccessFeedback) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded, size: 14, color: Colors.green),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'File uploaded successfully!',
                  style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildUploaderContent(bool hasFile, bool isPdf) {
    // 1. Loading state
    if (_isUploading) {
      return Container(
        height: 160,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                value: _uploadProgress,
                strokeWidth: 4,
                backgroundColor: AppTheme.border,
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Parsing File... ${(_uploadProgress * 100).toInt()}%',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    // 2. Has uploaded file -> Show large preview area
    if (hasFile) {
      return Column(
        children: [
          // Large Preview area
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF0B0F19).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.border, width: 1),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: isPdf
                    ? _buildPdfPreview()
                    : _buildImagePreview(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // File label details
          Text(
            _fileName ?? 'Uploaded File',
            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.refresh_rounded, size: 14),
                label: const Text('Replace', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.surface,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: const BorderSide(color: AppTheme.border),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _clearFile,
                icon: const Icon(Icons.delete_forever_rounded, size: 14),
                label: const Text('Remove', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
                  foregroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: const BorderSide(color: Colors.redAccent),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    // 3. Empty state
    return GestureDetector(
      onTap: _pickFile,
      child: Container(
        height: 150,
        width: double.infinity,
        color: Colors.transparent, // Ensure gesture detector captures taps
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_upload_outlined, color: AppTheme.primary, size: 42),
            const SizedBox(height: 12),
            const Text(
              'Click to upload certificate',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Supported: ${widget.allowedExtensions.join(', ').toUpperCase()}',
              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 4),
            const Text(
              'Max size: 4MB',
              style: TextStyle(fontSize: 10, color: AppTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    try {
      final base64String = _currentBase64!.split(',').last;
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.memory(
          base64Decode(base64String),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.broken_image, color: Colors.grey, size: 48),
        ),
      );
    } catch (e) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image, color: Colors.redAccent, size: 40),
          SizedBox(height: 8),
          Text('Invalid image data', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
        ],
      );
    }
  }

  Widget _buildPdfPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.25)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.picture_as_pdf_rounded, color: Colors.redAccent, size: 48),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'PDF Document',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
              ),
              SizedBox(height: 4),
              Text(
                'Ready to save',
                style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
