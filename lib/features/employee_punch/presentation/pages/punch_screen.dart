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

class PunchScreen extends StatelessWidget {
  const PunchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PunchBloc>(),
      child: const ModernPunchMainContent(),
    );
  }
}

class ModernPunchMainContent extends StatefulWidget {
  const ModernPunchMainContent({super.key});
  @override
  State<ModernPunchMainContent> createState() => _ModernPunchMainContentState();
}

class _ModernPunchMainContentState extends State<ModernPunchMainContent> {
  final _empCodeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _clientCodeController = TextEditingController();

  final FocusNode _empCodeFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _submitFocusNode = FocusNode();
  final FocusNode _clearFocusNode = FocusNode();
  final FocusNode _clientCodeFocusNode = FocusNode();

  CameraController? _cameraController;
  bool _isCameraReady = false;
  bool _isServerConfigured = false;

  static const _primaryThemeColor = Color(0xFF1C2955);
  static const _backgroundGrey = Color(0xFFF4F6F7);
  static const _buttonColor = Color(0xFF2563EB);

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    if (cameras.isEmpty) return;
    final camera = cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(camera, ResolutionPreset.medium, enableAudio: false);
    await _cameraController!.initialize();
    if (mounted) setState(() => _isCameraReady = true);
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _empCodeController.dispose();
    _passwordController.dispose();
    _clientCodeController.dispose();
    _empCodeFocusNode.dispose();
    _passwordFocusNode.dispose();
    _submitFocusNode.dispose();
    _clearFocusNode.dispose();
    _clientCodeFocusNode.dispose();
    super.dispose();
  }

  void _showModernResultDialog(String message, bool isError) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            isError ? 'Alert' : 'Success',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isError ? Colors.red.shade700 : _primaryThemeColor,
            ),
          ),
          content: Text(
            message,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 13),
          ),
          actions: [
            TextButton(
              autofocus: true,
              style: TextButton.styleFrom(
                foregroundColor: isError ? Colors.red.shade700 : _primaryThemeColor,
              ),
              onPressed: () {
                Navigator.pop(context);
                _empCodeFocusNode.requestFocus();
              },
              child: Text(
                'Ok',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            )
          ],
        );
      },
    );
  }

  void _submitPunch() async {
    if (!_isCameraReady || _cameraController == null) {
      _showModernResultDialog('Camera not initialized.', true);
      return;
    }

    if (_empCodeController.text.isEmpty || _passwordController.text.isEmpty) {
      _showModernResultDialog('Please enter credentials.', true);
      return;
    }

    try {
      final imageFile = await _cameraController!.takePicture();
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      if (mounted) {
        context.read<PunchBloc>().add(
            SubmitPunchEvent(
              empCode: _empCodeController.text,
              password: _passwordController.text,
              image: base64Image,
            )
        );
      }
    } catch (e) {
      _showModernResultDialog('Camera error: $e', true);
    }
  }

  void _connectToServer() {
    if (_clientCodeController.text.isNotEmpty) {
      setState(() {
        _isServerConfigured = true;
      });
      Future.delayed(const Duration(milliseconds: 100), () {
        _empCodeFocusNode.requestFocus();
      });
    }
  }

  void _goToAdminLogin() {
    context.go('/admin');
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PunchBloc, PunchState>(
      listener: (context, state) {
        if (state is PunchFailure) {
          _showModernResultDialog(state.message, true);
        } else if (state is PunchSuccess) {
          _showModernResultDialog(state.result.message, false);
          _empCodeController.clear();
          _passwordController.clear();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: _backgroundGrey,
          body: Stack(
            children: [
              Column(
                children: [
                  _buildModernHeader(),
                  Expanded(child: _buildModernBody(state)),
                  _buildModernFooter(),
                ],
              ),
              if (!_isServerConfigured)
                Container(
                  color: Colors.black.withOpacity(0.6),
                  child: Center(
                    child: Container(
                      width: 450,
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 30,
                            offset: Offset(0, 15),
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.blue.shade100, width: 2),
                            ),
                            child: const Icon(Icons.code, color: _buttonColor, size: 32),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Server Configuration',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Enter your client code to connect to the server',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Client Code',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _clientCodeController,
                                focusNode: _clientCodeFocusNode,
                                onSubmitted: (_) => _connectToServer(),
                                autofocus: true,
                                style: GoogleFonts.poppins(fontSize: 14),
                                decoration: InputDecoration(
                                  hintText: 'e.g. XYZ',
                                  hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
                                  prefixIcon: Icon(Icons.dns_outlined, color: Colors.grey.shade500),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: _buttonColor, width: 2),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _buttonColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                              onPressed: _connectToServer,
                              child: Text(
                                'Connect to Server',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModernHeader() {
    final now = DateTime.now();
    return Container(
      color: _primaryThemeColor,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            DateFormat('dd-MMM-yyyy').format(now),
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 12),
          ),
          Column(
            children: [
              Text(
                'CAROL SOLUTIONS',
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2),
              ),
              const SizedBox(height: 2),
              Text(
                '1st Floor, Thapasya Building, 1, Infopark Campus, Infopark Phase, Kakkanad, Kerala 682042',
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10),
              ),
            ],
          ),
          Row(
            children: [
              StreamBuilder(
                stream: Stream.periodic(const Duration(seconds: 1)),
                builder: (context, snapshot) => Text(
                  DateFormat('hh:mm:ss a').format(DateTime.now()),
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 12),
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.admin_panel_settings, color: Colors.white),
                tooltip: 'Admin Login',
                onPressed: _goToAdminLogin,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernFooter() {
    return Container(
      width: double.infinity,
      color: _primaryThemeColor,
      padding: const EdgeInsets.all(10),
      child: Text(
        'Designed & Developed by Vineeth Venu',
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w400, color: Colors.white70, fontSize: 10),
      ),
    );
  }

  Widget _buildModernBody(PunchState state) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'PUNCHING PORTAL',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800, color: _primaryThemeColor, letterSpacing: 0.5),
            ),
            const SizedBox(height: 20),
            Container(
              width: 800,
              padding: const EdgeInsets.all(50),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 5))],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 6,
                    child: FocusTraversalGroup(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputField(
                            _empCodeController,
                            'Employee Code',
                            Icons.badge,
                            focusNode: _empCodeFocusNode,
                            onSubmitted: () => _passwordFocusNode.requestFocus(),
                          ),
                          const SizedBox(height: 16),
                          _buildInputField(
                            _passwordController,
                            'Password',
                            Icons.lock_outline,
                            obscureText: true,
                            focusNode: _passwordFocusNode,
                            onSubmitted: () => _submitFocusNode.requestFocus(),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Shift: NORMAL-2 (09:30:00 - 18:30:00)',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: _primaryThemeColor, fontSize: 12),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildButtons(state),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 30),
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        Container(
                          height: 260,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade200, width: 2),
                          ),
                          child: _isCameraReady
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CameraPreview(_cameraController!),
                          )
                              : const Center(child: CircularProgressIndicator(color: _primaryThemeColor)),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Place your face within the camera frame',
                          style: GoogleFonts.poppins(color: Colors.black54, fontSize: 10),
                        )
                      ],
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

  Widget _buildInputField(
      TextEditingController controller,
      String label,
      IconData icon,
      {bool obscureText = false,
        required FocusNode focusNode,
        required VoidCallback onSubmitted}
      ) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      textInputAction: TextInputAction.next,
      onSubmitted: (_) => onSubmitted(),
      style: GoogleFonts.poppins(fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(fontSize: 12),
        prefixIcon: Icon(icon, color: _primaryThemeColor, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _primaryThemeColor, width: 1.5)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }

  Widget _buildButtons(PunchState state) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            focusNode: _submitFocusNode,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryThemeColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 2,
            ),
            onPressed: state is PunchLoading ? null : _submitPunch,
            child: state is PunchLoading
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text('SUBMIT PUNCH', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            focusNode: _clearFocusNode,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: _primaryThemeColor),
              foregroundColor: _primaryThemeColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              _empCodeController.clear();
              _passwordController.clear();
              _empCodeFocusNode.requestFocus();
            },
            child: Text('CLEAR / REJECT', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ),
      ],
    );
  }
}