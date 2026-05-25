import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:intl/intl.dart';
import '../../../../injection_container.dart';
import '../../../../main.dart'; 
import '../bloc/punch_bloc.dart';

class PunchScreen extends StatelessWidget {
  const PunchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PunchBloc>(),
      child: const Scaffold(
        backgroundColor: Color(0xFFECEFF1),
        body: Column(
          children: [
            _HeaderWidget(),
            Expanded(child: _PunchMainContent()),
            _FooterWidget(),
          ],
        ),
      ),
    );
  }
}

class _HeaderWidget extends StatelessWidget {
  const _HeaderWidget();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Container(
      color: const Color(0xFFD4A017),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(DateFormat('dd-MMM-yyyy').format(now), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Column(
            children: const [
              Text('MANAPPURAM FINANCE LIMITED', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              Text('TAMBARAM BRANCH', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          StreamBuilder(
            stream: Stream.periodic(const Duration(seconds: 1)),
            builder: (context, snapshot) => Text(
              DateFormat('hh:mm:ss a').format(DateTime.now()), 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterWidget extends StatelessWidget {
  const _FooterWidget();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFD4A017),
      padding: const EdgeInsets.all(12),
      child: const Text(
        'Designed & Developed by Modernization Wing, IT S/W Manappuram',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }
}

class _PunchMainContent extends StatefulWidget {
  const _PunchMainContent();
  @override
  State<_PunchMainContent> createState() => _PunchMainContentState();
}

class _PunchMainContentState extends State<_PunchMainContent> {
  final _empCodeController = TextEditingController();
  final _passwordController = TextEditingController();
  
  CameraController? _cameraController;
  bool _isCameraReady = false;

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
    super.dispose();
  }

  void _showResultDialog(String message, bool isError) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(isError ? 'Notice' : 'Success', style: TextStyle(color: isError ? Colors.red[800] : Colors.teal)),
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF906085), // The specific purple tone requested
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Ok'),
          )
        ],
      ),
    );
  }

  void _submitPunch() async {
    if (!_isCameraReady || _cameraController == null) {
      _showResultDialog('Camera not initialized.', true);
      return;
    }
    
    if (_empCodeController.text.isEmpty || _passwordController.text.isEmpty) {
       _showResultDialog('Please enter credentials.', true);
       return;
    }

    try {
      final image = await _cameraController!.takePicture();
      if (mounted) {
        context.read<PunchBloc>().add(
          SubmitPunchEvent(empCode: _empCodeController.text, password: _passwordController.text, image: image)
        );
      }
    } catch (e) {
      _showResultDialog('Camera error: $e', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PunchBloc, PunchState>(
      listener: (context, state) {
        if (state is PunchFailure) {
          _showResultDialog(state.message, true);
        } else if (state is PunchSuccess) {
          _showResultDialog(state.result.message, false);
          _empCodeController.clear();
          _passwordController.clear();
        }
      },
      builder: (context, state) {
        return Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('PUNCHING PORTAL', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF8B0000))),
                const SizedBox(height: 30),
                Container(
                  width: 900, // Wide layout for side-by-side design
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 10))],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Form Section
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: _empCodeController,
                              decoration: const InputDecoration(labelText: 'Employee Code', prefixIcon: Icon(Icons.badge)),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline)),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                border: Border.all(color: Colors.grey.shade400),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('Shift: NORMAL-2 (09:30:00 - 18:30:00)', style: TextStyle(fontWeight: FontWeight.w600)),
                            ),
                            const SizedBox(height: 32),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 20)),
                                    onPressed: state is PunchLoading ? null : _submitPunch,
                                    child: state is PunchLoading 
                                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                      : const Text('SUBMIT PUNCH', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B0000), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 20)),
                                    onPressed: () {
                                      _empCodeController.clear();
                                      _passwordController.clear();
                                    },
                                    child: const Text('CLEAR / REJECT', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      const SizedBox(width: 40),
                      // Camera Section
                      Expanded(
                        flex: 4,
                        child: Container(
                          height: 350,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300, width: 2),
                          ),
                          child: _isCameraReady
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CameraPreview(_cameraController!),
                                )
                              : const Center(child: CircularProgressIndicator(color: Colors.teal)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
