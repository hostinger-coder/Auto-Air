// ===== lib/features/dashboard/screens/firmware_update_screen.dart =====

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:AutoAir/widgets/app_background.dart';

class FirmwareUpdateScreen extends StatelessWidget {
  const FirmwareUpdateScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _FirmwareAppBar(),
        body: _FirmwareUpdateBody(),
      ),
    );
  }
}

class _FirmwareAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _FirmwareAppBar();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.system_update, size: 16, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 8),
          Text(
            'Firmware Update',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _FirmwareUpdateBody extends StatefulWidget {
  const _FirmwareUpdateBody();

  @override
  State<_FirmwareUpdateBody> createState() => _FirmwareUpdateBodyState();
}

class _FirmwareUpdateBodyState extends State<_FirmwareUpdateBody> {
  String? _fileName;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  Timer? _uploadTimer;

  @override
  void dispose() {
    _uploadTimer?.cancel();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['bin'],
    );
    if (result != null) {
      setState(() {
        _fileName = result.files.single.name;
        _isUploading = false;
        _uploadProgress = 0.0;
      });
    }
  }

  void _startUpload() {
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    _uploadTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        _uploadProgress += 0.01;
        if (_uploadProgress >= 1.0) {
          _uploadProgress = 1.0;
          _isUploading = false;
          timer.cancel();
          _showCompletionDialog();
        }
      });
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: AlertDialog(
            backgroundColor: const Color(0xFF1C1C1E).withOpacity(0.9),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            title: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.lightGreenAccent),
                const SizedBox(width: 8),
                const Text('Update Complete', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            content: const Text('Your device will restart automatically.'),
            actions: [
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey.shade800,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              _SectionTitle(icon: Icons.info_outline, title: 'Current Version'),
              SizedBox(height: 12),
              _CurrentVersionRows(),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _GlassCard(
          gradientBorder: true,
          child: const _WarningCard(),
        ),
        const SizedBox(height: 16),
        _GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _SectionTitle(icon: Icons.file_present, title: 'Select Firmware File (.bin)'),
              const SizedBox(height: 12),
              _FilePickerBox(fileName: _fileName, onChooseFile: _pickFile),
              const SizedBox(height: 8),
              const Text(
                'Use the main .bin file (e.g., AAI_ESP32ino.bin), not bootloader or partition files.',
                style: TextStyle(color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (_fileName != null)
                _FileMeta(name: _fileName!, onClear: () => setState(() => _fileName = null)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _SectionTitle(icon: Icons.upload, title: 'Upload'),
              const SizedBox(height: 12),
              _buildUploadButton(theme),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _isUploading
                    ? Padding(
                  key: const ValueKey('uploading_hint'),
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    'Please do not close the app while uploading.',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _isUploading ? null : () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUploadButton(ThemeData theme) {
    final isComplete = _uploadProgress >= 1.0;
    final isDisabled = _fileName == null || isComplete;

    String buttonText;
    IconData leading;
    if (isComplete) {
      buttonText = 'Uploaded (100%)';
      leading = Icons.check_rounded;
    } else if (_isUploading) {
      buttonText = 'Uploading…  ${(_uploadProgress * 100).toInt()}%';
      leading = Icons.sync_rounded;
    } else {
      buttonText = 'Upload Firmware';
      leading = Icons.cloud_upload_rounded;
    }

    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: theme.colorScheme.primary.withOpacity(0.2),
          ),
          clipBehavior: Clip.antiAlias,
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: _isUploading ? _uploadProgress.clamp(0.0, 1.0) : 0.0,
              child: Container(
                color: theme.colorScheme.primary.withOpacity(0.65),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: isDisabled ? null : _startUpload,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent, // progress layer sets color
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              minimumSize: const Size.fromHeight(48),
            ),
            icon: Icon(leading, color: Colors.white),
            label: Text(buttonText),
          ),
        ),
      ],
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child, this.gradientBorder = false});
  final Widget child;
  final bool gradientBorder;

  @override
  Widget build(BuildContext context) {
    final border = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: gradientBorder ? Colors.white.withOpacity(0.0) : Colors.white.withOpacity(0.10),
          width: 1.0,
        ),
        gradient: gradientBorder
            ? LinearGradient(
          colors: [
            Colors.amber.withOpacity(0.35),
            Colors.orange.withOpacity(0.20),
            Colors.pink.withOpacity(0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : null,
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E).withOpacity(0.45),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              // border layer
              Positioned.fill(child: IgnorePointer(child: border)),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: Colors.white),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _CurrentVersionRows extends StatelessWidget {
  const _CurrentVersionRows();

  @override
  Widget build(BuildContext context) {
    Widget row(String a, String b) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(child: Text(a, style: const TextStyle(color: Colors.white70))),
          Text(b, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
    return Column(
      children: [
        row('Version', '20.0.1 – Enhanced'),
        row('Build', 'Build-008'),
        row('Build Date', 'Jul 31 2025'),
      ],
    );
  }
}

class _WarningCard extends StatelessWidget {
  const _WarningCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            Colors.amber.withOpacity(0.18),
            Colors.deepOrange.withOpacity(0.12),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.amber.withOpacity(0.35)),
      ),
      child: Row(
        children: const [
          Icon(Icons.warning_amber_rounded, color: Colors.amber),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Do not power off the device during the update. It will restart automatically after a successful update.',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilePickerBox extends StatelessWidget {
  const _FilePickerBox({this.fileName, required this.onChooseFile});
  final String? fileName;
  final VoidCallback onChooseFile;

  @override
  Widget build(BuildContext context) {
    final hasFile = fileName != null;

    return _CustomDottedBorder(
      color: Colors.white38,
      strokeWidth: 2,
      dashPattern: const <double>[8, 6],
      radius: const Radius.circular(12),
      child: InkWell(
        onTap: onChooseFile,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            children: [
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 250),
                crossFadeState: hasFile ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                firstChild: Column(
                  children: const [
                    Icon(Icons.upload_file, size: 40, color: Colors.white70),
                    SizedBox(height: 10),
                    Text(
                      'Choose a file or tap to browse',
                      style: TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                secondChild: Column(
                  children: [
                    const Icon(Icons.insert_drive_file, size: 40, color: Colors.white70),
                    const SizedBox(height: 10),
                    Text(
                      fileName ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: onChooseFile,
                icon: const Icon(Icons.folder_open),
                label: const Text('Choose File'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tiny chip for the selected file meta + clear
class _FileMeta extends StatelessWidget {
  const _FileMeta({required this.name, required this.onClear});
  final String name;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.insert_drive_file, size: 14, color: Colors.white70),
            const SizedBox(width: 6),
            Text(
              name,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onClear,
              child: const Icon(Icons.close, size: 14, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

/// ----- Custom dotted border (no third-party) -----

class _CustomDottedBorder extends StatelessWidget {
  final Widget child;
  final Color color;
  final double strokeWidth;
  final List<double> dashPattern;
  final Radius radius;

  const _CustomDottedBorder({
    Key? key,
    required this.child,
    this.color = Colors.black,
    this.strokeWidth = 1,
    this.dashPattern = const <double>[3, 1],
    this.radius = Radius.zero,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: CustomPaint(
            painter: _DottedPainter(
              color: color,
              strokeWidth: strokeWidth,
              dashPattern: dashPattern,
              radius: radius,
            ),
          ),
        ),
        // Padding so the stroke won’t clip the child content
        Padding(
          padding: EdgeInsets.all(maxRadiusPadding(strokeWidth)),
          child: child,
        ),
      ],
    );
  }

  double maxRadiusPadding(double stroke) => stroke / 2;
}

class _DottedPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final List<double> dashPattern;
  final Radius radius;

  _DottedPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashPattern,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(strokeWidth / 2, strokeWidth / 2, size.width - strokeWidth, size.height - strokeWidth);

    final Path source = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, radius));

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path dashed = _dashPath(source, dashArray: _CircularIntervalList<double>(dashPattern));

    canvas.drawPath(dashed, paint);
  }

  @override
  bool shouldRepaint(covariant _DottedPainter oldDelegate) {
    return color != oldDelegate.color ||
        strokeWidth != oldDelegate.strokeWidth ||
        radius != oldDelegate.radius ||
        dashPattern != oldDelegate.dashPattern;
  }

  Path _dashPath(
      Path source, {
        required _CircularIntervalList<double> dashArray,
      }) {
    final Path dest = Path();
    for (final PathMetric metric in source.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        final double len = dashArray.next;
        if (draw) {
          final double next = (distance + len).clamp(0.0, metric.length);
          dest.addPath(metric.extractPath(distance, next), Offset.zero);
          distance = next;
        } else {
          distance += len;
        }
        draw = !draw;
      }
    }
    return dest;
  }
}

class _CircularIntervalList<T> {
  final List<T> _values;
  int _idx = 0;

  _CircularIntervalList(this._values);

  T get next {
    if (_values.isEmpty) {
      throw StateError('dashPattern cannot be empty');
    }
    if (_idx >= _values.length) _idx = 0;
    return _values[_idx++];
  }
}
