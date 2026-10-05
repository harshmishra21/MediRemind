import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IPhoneFrame extends StatelessWidget {
  final Widget child;

  const IPhoneFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 500) {
          return Scaffold(
            backgroundColor: const Color(0xFF0F1115),
            body: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // iPhone Label Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2026),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.phone_iphone, size: 16, color: Color(0xFFA1A1AA)),
                            const SizedBox(width: 6),
                            Text(
                              'iPhone 15 Pro Frame',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFE4E4E7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // iPhone Outer Chassis Body
                      Container(
                        width: 393,
                        height: 852,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(55),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.7),
                              blurRadius: 50,
                              spreadRadius: 8,
                              offset: const Offset(0, 20),
                            ),
                          ],
                          border: Border.all(
                            color: const Color(0xFF48484A), // Titanium Bezel
                            width: 6,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(49),
                          child: Stack(
                            children: [
                              // 1. Full Screen App Content (Fills entire screen edge-to-edge)
                              Positioned.fill(
                                child: MediaQuery(
                                  data: MediaQuery.of(context).copyWith(
                                    padding: const EdgeInsets.only(top: 48, bottom: 20),
                                  ),
                                  child: child,
                                ),
                              ),

                              // 2. iOS Top Status Bar Info (Time on Left, Icons on Right)
                              Positioned(
                                top: 16,
                                left: 24,
                                right: 24,
                                child: IgnorePointer(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '9:41',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF1C1B1A),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.signal_cellular_4_bar, size: 14, color: Color(0xFF1C1B1A)),
                                          const SizedBox(width: 5),
                                          const Icon(Icons.wifi, size: 14, color: Color(0xFF1C1B1A)),
                                          const SizedBox(width: 5),
                                          Container(
                                            width: 22,
                                            height: 11,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(3),
                                              border: Border.all(color: const Color(0xFF1C1B1A), width: 1.2),
                                            ),
                                            padding: const EdgeInsets.all(1),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF1C1B1A),
                                                borderRadius: BorderRadius.circular(1),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // 3. iPhone Dynamic Island Notch (Floating over screen content)
                              Positioned(
                                top: 11,
                                left: 0,
                                right: 0,
                                child: IgnorePointer(
                                  child: Center(
                                    child: Container(
                                      width: 124,
                                      height: 35,
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Camera Lens Dot
                                          Container(
                                            margin: const EdgeInsets.only(left: 14),
                                            width: 11,
                                            height: 11,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF0F172A),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          // Sensor Glass Glow
                                          Container(
                                            margin: const EdgeInsets.only(right: 14),
                                            width: 11,
                                            height: 11,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF1E293B),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white.withValues(alpha: 0.1),
                                                width: 0.5,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // 4. Home Indicator Bar
                              Positioned(
                                bottom: 8,
                                left: 0,
                                right: 0,
                                child: IgnorePointer(
                                  child: Center(
                                    child: Container(
                                      width: 134,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1C1B1A).withValues(alpha: 0.4),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return child;
      },
    );
  }
}
