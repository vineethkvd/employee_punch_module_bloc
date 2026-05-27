import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

const _bgDark = Color(0xFF030712);
const _accent1 = Color(0xFF06B6D4);
const _accent2 = Color(0xFF3B82F6);
const _accent3 = Color(0xFF8B5CF6);
const _glassBg = Color(0x12FFFFFF);
const _glassBorder = Color(0x1AFFFFFF);
const _textWhite = Colors.white;
const _textMuted = Color(0x60FFFFFF);

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: Stack(
        children: [
          _buildBackgroundLayer(),
          Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Dashboard',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: _textWhite,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Welcome back, Administrator',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          color: _textMuted,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Stats Cards
                      Row(
                        children: [
                          _buildStatCard('Total Employees', '248', Icons.people, _accent1),
                          const SizedBox(width: 12),
                          _buildStatCard('Present Today', '214', Icons.check_circle, Colors.greenAccent),
                          const SizedBox(width: 12),
                          _buildStatCard('On Leave', '18', Icons.event_busy, Colors.orangeAccent),
                          const SizedBox(width: 12),
                          _buildStatCard('Late Arrivals', '7', Icons.access_time, Colors.redAccent),
                        ],
                      ),

                      const SizedBox(height: 28),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildGlassCard(
                              title: 'Recent Activity',
                              child: _buildRecentActivity(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildGlassCard(
                              title: 'Quick Actions',
                              child: _buildQuickActions(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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
              stops: const [0.0, 0.4, 0.7, 1.0],
              colors: [
                Color(0xFF020617).withOpacity(0.9),
                Color(0xFF0F172A).withOpacity(0.8),
                Color(0xFF172554).withOpacity(0.7),
                Color(0xFF020617).withOpacity(0.95),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: const BoxDecoration(
            color: Color(0x08FFFFFF),
            border: Border(bottom: BorderSide(color: Color(0x1AFFFFFF), width: 0.5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.shield_outlined, color: _accent1, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'ZAC Tech Admin',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: _textWhite,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildHeaderPill(Icons.calendar_today, DateFormat('dd MMM yyyy').format(DateTime.now())),
                  const SizedBox(width: 12),
                  _buildHeaderPill(Icons.access_time, DateFormat('hh:mm a').format(DateTime.now())),
                  const SizedBox(width: 20),
                  CircleAvatar(
                    backgroundColor: _accent1.withOpacity(0.2),
                    child: const Icon(Icons.person, color: _accent1),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderPill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0x0AFFFFFF),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0x1AFFFFFF), width: 0.5),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white70),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: _buildGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: _textWhite,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: _textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child, String? title}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(
          padding: const EdgeInsets.all(20),        // Reduced padding
          decoration: BoxDecoration(
            color: _glassBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _glassBorder, width: 0.8),
          ),
          child: title != null
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _textWhite,
                ),
              ),
              const SizedBox(height: 16),
              child,
            ],
          )
              : child,
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      children: [
        _activityTile('Vineeth Venu', 'Checked In', '09:32 AM', Colors.green),
        _activityTile('Anjali Menon', 'Checked Out', '06:15 PM', Colors.blue),
        _activityTile('Ramesh Kumar', 'Late Arrival', '10:05 AM', Colors.orange),
        _activityTile('Priya Nair', 'Checked In', '08:58 AM', Colors.green),
      ],
    );
  }

  Widget _activityTile(String name, String action, String time, Color color) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        child: Icon(Icons.person, color: color, size: 20),
      ),
      title: Text(name, style: GoogleFonts.plusJakartaSans(color: _textWhite, fontSize: 14)),
      subtitle: Text(action, style: GoogleFonts.plusJakartaSans(color: _textMuted, fontSize: 12)),
      trailing: Text(time, style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 13)),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        _quickActionButton('Mark Attendance', Icons.fingerprint, _accent1),
        const SizedBox(height: 10),
        _quickActionButton('View Reports', Icons.analytics_outlined, _accent2),
        const SizedBox(height: 10),
        _quickActionButton('Employee Directory', Icons.people_outline, _accent3),
        const SizedBox(height: 10),
        _quickActionButton('Settings', Icons.settings_outlined, Colors.white70),
      ],
    );
  }

  Widget _quickActionButton(String label, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0x08FFFFFF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _glassBorder, width: 0.6),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 14),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _textWhite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}