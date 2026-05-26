import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../../injection_container.dart';
import '../../../../main.dart';
import '../bloc/punch_bloc.dart';

const _primary = Color(0xFF062B78);
const _primaryLight = Color(0xFFEFF6FF);
const _primaryBorder = Color(0xFFBFDBFE);
const _surface = Colors.white;
const _background = Color(0xFFF1F5F9);
const _borderColor = Color(0xFFE2E8F0);
const _textPrimary = Color(0xFF0F172A);
const _textSecondary = Color(0xFF64748B);
const _errorColor = Color(0xFFDC2626);

class PunchScreen extends StatelessWidget {
  const PunchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PunchBloc>(),
      child: const _PunchView(),
    );
  }
}

class _PunchView extends StatefulWidget {
  const _PunchView();

  @override
  State<_PunchView> createState() => _PunchViewState();
}

class _PunchViewState extends State<_PunchView> {
  final _empCodeCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _clientCodeCtrl = TextEditingController();

  final _empCodeFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _submitFocus = FocusNode();
  final _clearFocus = FocusNode();
  final _clientCodeFocus = FocusNode();

  CameraController? _camera;
  bool _cameraReady = false;
  bool _serverConfigured = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    if (cameras.isEmpty) return;
    final cam = cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );
    _camera = CameraController(cam, ResolutionPreset.medium, enableAudio: false);
    await _camera!.initialize();
    if (mounted) setState(() => _cameraReady = true);
  }

  @override
  void dispose() {
    _camera?.dispose();
    _empCodeCtrl.dispose();
    _passwordCtrl.dispose();
    _clientCodeCtrl.dispose();
    _empCodeFocus.dispose();
    _passwordFocus.dispose();
    _submitFocus.dispose();
    _clearFocus.dispose();
    _clientCodeFocus.dispose();
    super.dispose();
  }

  void _showResultDialog(String message, bool isError) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

        title: Text(
          isError ? 'Alert' : 'Success',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: _textPrimary,
          ),
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: _textSecondary,
            height: 1.5,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            autofocus: true,
            style: FilledButton.styleFrom(
              backgroundColor: isError ? _errorColor : _primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              _empCodeFocus.requestFocus();
            },
            child: Text(
              'OK',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _submitPunch() async {
    if (!_cameraReady || _camera == null) {
      _showResultDialog('Camera not initialised.', true);
      return;
    }
    if (_empCodeCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) {
      _showResultDialog('Please enter your credentials.', true);
      return;
    }
    try {
      final file = await _camera!.takePicture();
      final bytes = await file.readAsBytes();
      final b64 = base64Encode(bytes);
      if (mounted) {
        context.read<PunchBloc>().add(SubmitPunchEvent(
          empCode: _empCodeCtrl.text,
          password: _passwordCtrl.text,
          image: b64,
        ));
      }
    } catch (e) {
      _showResultDialog('Camera error: $e', true);
    }
  }

  void _connectToServer() {
    if (_clientCodeCtrl.text.trim().isEmpty) return;
    setState(() => _serverConfigured = true);
    Future.delayed(
      const Duration(milliseconds: 120),
          () => _empCodeFocus.requestFocus(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PunchBloc, PunchState>(
      listener: (context, state) {
        if (state is PunchFailure) {
          _showResultDialog(state.message, true);
        } else if (state is PunchSuccess) {
          _showResultDialog(state.result.message, false);
          _empCodeCtrl.clear();
          _passwordCtrl.clear();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: _background,
          body: Stack(
            children: [
              Column(
                children: [
                  _buildHeader(),
                  Expanded(child: _buildBody(state)),
                  _buildFooter(),
                ],
              ),
              if (!_serverConfigured) _buildServerConfigOverlay(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      color: _primary,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  DateFormat('dd MMM yyyy').format(DateTime.now()),
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          Column(
            children: [
              Text(
                'CAROL SOLUTIONS',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '1st Floor, Thapasya Building, Infopark Campus, Kakkanad, Kerala 682042',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white70,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StreamBuilder(
                    stream: Stream.periodic(const Duration(seconds: 1)),
                    builder: (_, __) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        DateFormat('hh:mm:ss a').format(DateTime.now()),
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Tooltip(
                    message: 'Admin Login',
                    child: InkWell(
                      onTap: () => context.go('/admin'),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.admin_panel_settings_outlined,
                            color: Colors.white, size: 22),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(PunchState state) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'PUNCHING PORTAL',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: _textPrimary,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 28),
            Container(
              width: 860,
              padding: const EdgeInsets.all(36),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _borderColor),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 20,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 6, child: _buildForm(state)),
                  const SizedBox(width: 36),
                  Expanded(flex: 4, child: _buildCameraPanel()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(PunchState state) {
    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          FocusTraversalOrder(
            order: const NumericFocusOrder(1),
            child: TextField(
              controller: _empCodeCtrl,
              focusNode: _empCodeFocus,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _passwordFocus.requestFocus(),
              style: GoogleFonts.plusJakartaSans(fontSize: 14, color: _textPrimary),
              decoration: _inputDecoration('Employee Code', Icons.badge_outlined),
            ),
          ),
          const SizedBox(height: 16),
          FocusTraversalOrder(
            order: const NumericFocusOrder(2),
            child: TextField(
              controller: _passwordCtrl,
              focusNode: _passwordFocus,
              obscureText: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) {
                _submitFocus.requestFocus();
                if (state is! PunchLoading) _submitPunch();
              },
              style: GoogleFonts.plusJakartaSans(fontSize: 14, color: _textPrimary),
              decoration: _inputDecoration('Password', Icons.lock_outline_rounded),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _primaryLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _primaryBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule_rounded, color: _primary, size: 18),
                const SizedBox(width: 10),
                Text(
                  'Shift: NORMAL-2  ·  09:30 – 18:30',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: FocusTraversalOrder(
                  order: const NumericFocusOrder(3),
                  child: FilledButton.icon(
                    focusNode: _submitFocus,
                    style: FilledButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: state is PunchLoading ? null : _submitPunch,
                    icon: state is PunchLoading
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                        : const Icon(Icons.fingerprint_rounded, size: 18),
                    label: Text(
                      'Submit Punch',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FocusTraversalOrder(
                  order: const NumericFocusOrder(4),
                  child: OutlinedButton.icon(
                    focusNode: _clearFocus,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: _borderColor, width: 1.5),
                      foregroundColor: _textSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      _empCodeCtrl.clear();
                      _passwordCtrl.clear();
                      _empCodeFocus.requestFocus();
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: Text(
                      'Clear / Reject',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: _textSecondary),
      prefixIcon: Icon(icon, color: _primary, size: 20),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _primary, width: 1.8),
      ),
    );
  }

  Widget _buildCameraPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 260,
            color: const Color(0xFF0F172A),
            child: _cameraReady
                ? CameraPreview(_camera!)
                : const Center(
              child: CircularProgressIndicator(color: _primary, strokeWidth: 2),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _cameraReady ? const Color(0xFF16A34A) : const Color(0xFFF59E0B),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              _cameraReady ? 'Camera ready' : 'Initialising camera…',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: _textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServerConfigOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.4),
      child: Center(
        child: Container(
          width: 440,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _borderColor),
            boxShadow: const [
              BoxShadow(
                color: Color(0x18000000),
                blurRadius: 32,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _primaryLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: _primaryBorder),
                ),
                child: const Icon(Icons.cloud_sync_outlined, color: _primary, size: 28),
              ),
              const SizedBox(height: 20),
              Text(
                'Server Configuration',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Enter your client code to connect to the server',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: _textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Client Code',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _clientCodeCtrl,
                focusNode: _clientCodeFocus,
                autofocus: true,
                onSubmitted: (_) => _connectToServer(),
                style: GoogleFonts.plusJakartaSans(fontSize: 14, color: _textPrimary),
                decoration: _inputDecoration('e.g. XYZ', Icons.dns_outlined),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _connectToServer,
                  child: Text(
                    'Connect to Server',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      color: _primary,
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Text(
        'Designed & Developed by Vineeth Venu',
        textAlign: TextAlign.center,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          color: Colors.white70,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}