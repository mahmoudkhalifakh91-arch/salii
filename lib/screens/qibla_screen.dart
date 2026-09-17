import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:adhan/adhan.dart';
import '../services/location_service.dart';
import '../theme/app_colors.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double? _latitude;
  double? _longitude;
  bool _isFallbackLocation = false;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    final location = await LocationService.instance.getCurrentLocation();
    if (!mounted) return;
    setState(() {
      _latitude = location.latitude;
      _longitude = location.longitude;
      _isFallbackLocation = location.isFallback;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('بوصلة القبلة', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _latitude == null || _longitude == null
          ? Center(child: CircularProgressIndicator(color: AppColors.brand(context)))
          : _buildCompass(_latitude!, _longitude!),
    );
  }

  Widget _buildCompass(double latitude, double longitude) {
    final qiblaDirection = Qibla(Coordinates(latitude, longitude)).direction;

    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('تعذر قراءة مستشعر البوصلة في جهازك'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: AppColors.brand(context)));
        }

        final heading = snapshot.data?.heading;
        if (heading == null) {
          return const Center(child: Text('جاري معايرة مستشعر الاتجاه...'));
        }

        // Calculate offset angle between device direction and Kaaba direction
        final angle = ((qiblaDirection - heading) * (math.pi / 180) * -1);
        final isAligned = (qiblaDirection - heading).abs() < 5;

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isFallbackLocation)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'تنبيه: الحساب مبني على موقع تقريبي — فعّل خدمة الموقع لدقة أعلى',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.isDark(context)
                          ? Colors.orange.shade300
                          : Colors.orange.shade800,
                      fontSize: 12,
                    ),
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: isAligned
                      ? AppColors.brand(context)
                      : AppColors.elevated(context),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isAligned ? 'أنت متجه نحو القبلة تماماً ✓' : 'وجّه هاتفك نحو الكعبة المشرفة',
                  style: TextStyle(
                    color: isAligned
                        ? (AppColors.isDark(context) ? const Color(0xFF07130D) : Colors.white)
                        : AppColors.text(context),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'زاوية القبلة لموقعك: ${qiblaDirection.toStringAsFixed(1)}°',
                style: TextStyle(color: AppColors.muted(context), fontSize: 13),
              ),
              const SizedBox(height: 36),

              // Compass Visual Dial
              Transform.rotate(
                angle: angle,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.isDark(context)
                        ? const Color(0xFF1B211F)
                        : Colors.white,
                    border: Border.all(
                      color: isAligned
                          ? AppColors.brand(context)
                          : AppColors.border(context),
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isAligned
                            ? AppColors.brand(context).withOpacity(0.25)
                            : Colors.black.withOpacity(0.25),
                        blurRadius: 24,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Dial Markings
                      Positioned(
                        top: 14,
                        child: Text(
                          'الكعبة',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.brand(context),
                          ),
                        ),
                      ),
                      // Qibla Arrow
                      Icon(
                        Icons.navigation,
                        size: 110,
                        color: isAligned
                            ? AppColors.brand(context)
                            : AppColors.accent(context),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'ضع الهاتف على سطح مستوٍ للحصول على أدق نتيجة',
                style: TextStyle(color: AppColors.muted(context), fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }
}
