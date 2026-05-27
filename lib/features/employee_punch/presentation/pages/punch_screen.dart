import 'dart:convert';
import 'dart:ui';
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

const _bgDark = Color(0xFF030712);
const _accent1 = Color(0xFF06B6D4);
const _accent2 = Color(0xFF3B82F6);
const _accent3 = Color(0xFF8B5CF6);
const _neonIndicator = Color(0xFF22D3EE);
const _textWhite = Colors.white;
const _textMuted = Color(0x60FFFFFF);
const _glassBg = Color(0x12FFFFFF);
const _glassBorder = Color(0x1AFFFFFF);

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

class _PunchViewState extends State<_PunchView> with SingleTickerProviderStateMixin {
  final _empCodeCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _clientCodeCtrl = TextEditingController();
  final _empCodeFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _clientCodeFocus = FocusNode();

  CameraController? _camera;
  bool _cameraReady = false;
  bool _serverConfigured = false;

  late AnimationController _scanAnimController;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _scanAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0.1, end: 0.85).animate(
      CurvedAnimation(parent: _scanAnimController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initCamera() async {
    if (cameras.isEmpty) return;
    final cam = cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );
    _camera = CameraController(cam, ResolutionPreset.high, enableAudio: false);
    await _camera!.initialize();
    if (mounted) setState(() => _cameraReady = true);
  }

  @override
  void dispose() {
    _camera?.dispose();
    _scanAnimController.dispose();
    _empCodeCtrl.dispose();
    _passwordCtrl.dispose();
    _clientCodeCtrl.dispose();
    _empCodeFocus.dispose();
    _passwordFocus.dispose();
    _clientCodeFocus.dispose();
    super.dispose();
  }

  void _showResultDialog(String message, bool isError) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: _glassBorder, width: 0.5),
        ),
        title: Text(
          isError ? 'Alert' : 'Success',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: _textWhite,
          ),
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: Colors.white70,
            height: 1.5,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              _empCodeFocus.requestFocus();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              decoration: BoxDecoration(
                gradient: isError
                    ? null
                    : const LinearGradient(colors: [_accent1, _accent2]),
                color: isError ? Colors.redAccent.withOpacity(0.8) : null,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'OK',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
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
          backgroundColor: _bgDark,
          body: Stack(
            children: [
              _buildBackgroundLayer(),
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

  Widget _buildBackgroundLayer() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/tech_bg.jpg'),
              fit: BoxFit.cover,
              opacity: 0.35,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.3, 0.7, 1.0],
              colors: [
                Color(0xFF020617).withOpacity(0.85),
                Color(0xFF0F172A).withOpacity(0.75),
                Color(0xFF172554).withOpacity(0.65),
                Color(0xFF020617).withOpacity(0.9),
              ],
            ),
          ),
        ),
        Positioned(
          top: -120,
          left: -80,
          child: Container(
            width: 420,
            height: 420,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [_accent1.withOpacity(0.12), Colors.transparent],
                stops: const [0.0, 0.75],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -80,
          right: -60,
          child: Container(
            width: 380,
            height: 380,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [_accent3.withOpacity(0.11), Colors.transparent],
                stops: const [0.0, 0.75],
              ),
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.38,
          left: MediaQuery.of(context).size.width * 0.48,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [_accent2.withOpacity(0.10), Colors.transparent],
                stops: const [0.0, 0.75],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLiquidGlass({required Widget child, EdgeInsetsGeometry? padding, double borderRadius = 24}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: _glassBg,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: _glassBorder, width: 0.8),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0AFFFFFF),
                blurRadius: 20,
                spreadRadius: 1,
                blurStyle: BlurStyle.inner,
              ),
              BoxShadow(
                color: Color(0x08FFFFFF),
                offset: Offset(0, 2),
                blurRadius: 12,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return _buildLiquidGlass(
      borderRadius: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ZAC Tech Solutions',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _textWhite,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '1st Floor, Thapasya Building, Infopark Campus, Kakkanad, Kerala 682042',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: _textMuted,
                ),
              ),
            ],
          ),
          Row(
            children: [
              _buildHeaderPill(Icons.calendar_today_outlined, DateFormat('dd MMM yyyy').format(DateTime.now())),
              const SizedBox(width: 8),
              StreamBuilder(
                stream: Stream.periodic(const Duration(seconds: 1)),
                builder: (_, __) => _buildHeaderPill(Icons.access_time, DateFormat('hh:mm a').format(DateTime.now())),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => context.go('/admin'),
                child: _buildHeaderPill(Icons.admin_panel_settings_outlined, "Admin"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderPill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0x0AFFFFFF),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0x1AFFFFFF), width: 0.5),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(PunchState state) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.60,
          child: _buildLiquidGlass(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                SizedBox(
                  width: 300,
                  child: _buildForm(state),
                ),
                const SizedBox(width: 30),
                _buildCameraPanel(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(PunchState state) {
    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0x0AFFFFFF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _glassBorder, width: 0.5),
                ),
                child: const Icon(Icons.fingerprint, color: _accent1, size: 18),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Punching Portal', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600, color: _textWhite)),
                  Text('Attendance management', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: _textMuted)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildInputGroup('Employee code', Icons.badge_outlined, _empCodeCtrl, _empCodeFocus, false, TextInputAction.next),
          const SizedBox(height: 18),
          _buildInputGroup('Password', Icons.lock_outline, _passwordCtrl, _passwordFocus, true, TextInputAction.done),
          const SizedBox(height: 12),
          const Divider(color: Color(0x14FFFFFF), thickness: 0.5, height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            margin: const EdgeInsets.only(bottom: 28),
            decoration: BoxDecoration(
              color: _accent2.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _accent2.withOpacity(0.2), width: 0.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: _neonIndicator,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: _neonIndicator, blurRadius: 6)],
                  ),
                ),
                const SizedBox(width: 10),
                Text('Shift', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: _textMuted)),
                const SizedBox(width: 8),
                Text('NORMAL-2 · 09:30 – 18:30', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFFE0F2FE))),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                flex: 5,
                child: GestureDetector(
                  onTap: state is PunchLoading ? null : _submitPunch,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_accent1, _accent2, _accent3],
                        stops: [0.0, 0.5, 1.0],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [BoxShadow(color: Color(0x33FFFFFF), blurRadius: 12, spreadRadius: 1)],
                    ),
                    alignment: Alignment.center,
                    child: state is PunchLoading
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.fingerprint, color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text('Submit punch', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: GestureDetector(
                  onTap: () {
                    _empCodeCtrl.clear();
                    _passwordCtrl.clear();
                    _empCodeFocus.requestFocus();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0x0AFFFFFF),
                      border: Border.all(color: const Color(0x1AFFFFFF), width: 0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.refresh, color: Colors.white70, size: 16),
                        const SizedBox(width: 6),
                        Text('Clear', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white70)),
                      ],
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

  Widget _buildInputGroup(String label, IconData icon, TextEditingController controller, FocusNode focusNode, bool isPassword, TextInputAction action) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0x80FFFFFF), letterSpacing: 0.5, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          focusNode: focusNode,
          obscureText: isPassword,
          textInputAction: action,
          onSubmitted: (_) {
            if (action == TextInputAction.next) {
              _passwordFocus.requestFocus();
            } else {
              _submitPunch();
            }
          },
          style: GoogleFonts.plusJakartaSans(fontSize: 14, color: _textWhite),
          decoration: InputDecoration(
            hintText: isPassword ? '••••••••' : 'Enter your code',
            hintStyle: GoogleFonts.plusJakartaSans(fontSize: 14, color: const Color(0x40FFFFFF)),
            prefixIcon: Icon(icon, color: const Color(0x88FFFFFF), size: 20),
            filled: true,
            fillColor: Colors.white.withOpacity(0.08),        // White background for text field
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0x1AFFFFFF), width: 0.5)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0x1AFFFFFF), width: 0.5)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _accent1, width: 1.6)),
          ),
        ),
      ],
    );
  }

  Widget _buildCameraPanel() {
    return SizedBox(
      width: 380,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.camera_alt_outlined, size: 14, color: _textMuted),
                  const SizedBox(width: 6),
                  Text('Face scan', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: _textMuted, fontWeight: FontWeight.w500)),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: _cameraReady ? _neonIndicator : Colors.amber,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: _cameraReady ? _neonIndicator : Colors.amber, blurRadius: 4)],
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _cameraReady ? 'Live' : 'Starting...',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0x80FFFFFF)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 340,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x1AFFFFFF), width: 1),
              boxShadow: const [BoxShadow(color: Color(0x0AFFFFFF), blurRadius: 16, spreadRadius: 2)],
            ),
            child: Stack(
              children: [
                if (_cameraReady && _camera != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: SizedBox.expand(child: CameraPreview(_camera!)),
                  )
                else
                  const Center(child: Icon(Icons.face, size: 42, color: Color(0x1AFFFFFF))),

                _buildCorner(top: 16, left: 16, topBorder: true, leftBorder: true),
                _buildCorner(top: 16, right: 16, topBorder: true, rightBorder: true),
                _buildCorner(bottom: 16, left: 16, bottomBorder: true, leftBorder: true),
                _buildCorner(bottom: 16, right: 16, bottomBorder: true, rightBorder: true),

                AnimatedBuilder(
                  animation: _scanAnimation,
                  builder: (context, child) {
                    return Positioned(
                      top: 340 * _scanAnimation.value,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.transparent, _accent1.withOpacity(0.9), _accent3.withOpacity(0.9), Colors.transparent],
                          ),
                          boxShadow: [BoxShadow(color: _accent1.withOpacity(0.6), blurRadius: 12, spreadRadius: 2)],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner({double? top, double? bottom, double? left, double? right, bool topBorder = false, bool bottomBorder = false, bool leftBorder = false, bool rightBorder = false}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          border: Border(
            top: topBorder ? const BorderSide(color: _accent1, width: 2.5) : BorderSide.none,
            bottom: bottomBorder ? const BorderSide(color: _accent1, width: 2.5) : BorderSide.none,
            left: leftBorder ? const BorderSide(color: _accent1, width: 2.5) : BorderSide.none,
            right: rightBorder ? const BorderSide(color: _accent1, width: 2.5) : BorderSide.none,
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(topBorder && leftBorder ? 6 : 0),
            topRight: Radius.circular(topBorder && rightBorder ? 6 : 0),
            bottomLeft: Radius.circular(bottomBorder && leftBorder ? 6 : 0),
            bottomRight: Radius.circular(bottomBorder && rightBorder ? 6 : 0),
          ),
        ),
      ),
    );
  }

  Widget _buildServerConfigOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.75),
      child: Center(
        child: _buildLiquidGlass(
          padding: const EdgeInsets.all(40),
          child: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0x0AFFFFFF),
                    shape: BoxShape.circle,
                    border: Border.all(color: _glassBorder),
                  ),
                  child: const Icon(Icons.cloud_sync_outlined, color: _accent1, size: 28),
                ),
                const SizedBox(height: 20),
                Text('Server Configuration', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700, color: _textWhite)),
                const SizedBox(height: 6),
                Text('Enter your client code to connect', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: _textMuted)),
                const SizedBox(height: 28),
                _buildInputGroup('Client Code', Icons.dns_outlined, _clientCodeCtrl, _clientCodeFocus, false, TextInputAction.done),
                const SizedBox(height: 28),
                GestureDetector(
                  onTap: _connectToServer,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [_accent1, _accent2]),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text('Connect to Server', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return SizedBox(
      width: double.infinity,
      child: _buildLiquidGlass(
        borderRadius: 0,
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Text(
          'Designed & developed by Vineeth Venu',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0x40FFFFFF)),
        ),
      ),
    );
  }
}