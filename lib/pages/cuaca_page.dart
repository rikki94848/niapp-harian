import 'dart:math' as math;
import 'package:flutter/material.dart';

enum WeatherType { sunny, cloudy, rain, thunder /*, fog, night*/ }

class CuacaPage extends StatefulWidget {
  const CuacaPage({super.key});
  @override
  State<CuacaPage> createState() => _CuacaPageState();
}

class _CuacaPageState extends State<CuacaPage> with TickerProviderStateMixin {
  // ====== UBAH INI UNTUK MENGGANTI KONDISI ======
  final WeatherType _type =
      WeatherType.cloudy; // sunny / cloudy / rain / thunder

  // ====== DATA STATIS (silakan ganti) ======
  static const _city = 'Bandung';
  static const _dateText = 'Senin, 10:08';
  static const _nowTemp = 22;
  static const _nowCond = 'Berawan'; // sinkronkan dengan _type
  static const _precip = 30; // %
  static const _humid = 70; // %
  static const _wind = 12.0; // km/h

  static const _hourly = <Map<String, dynamic>>[
    {'t': '09.00', 'temp': 22, 'icon': Icons.wb_sunny_outlined},
    {'t': '12.00', 'temp': 24, 'icon': Icons.cloud_outlined},
    {'t': '15.00', 'temp': 23, 'icon': Icons.cloud_queue},
    {'t': '18.00', 'temp': 21, 'icon': Icons.cloudy_snowing},
    {'t': '21.00', 'temp': 20, 'icon': Icons.nights_stay},
  ];

  static const _weekly = <Map<String, dynamic>>[
    {'d': 'Sel', 'hi': 21, 'lo': 17, 'icon': Icons.thunderstorm_outlined},
    {'d': 'Rab', 'hi': 20, 'lo': 16, 'icon': Icons.cloudy_snowing},
    {'d': 'Kam', 'hi': 20, 'lo': 16, 'icon': Icons.cloud_queue},
    {'d': 'Jum', 'hi': 21, 'lo': 17, 'icon': Icons.wb_sunny_outlined},
    {'d': 'Sab', 'hi': 23, 'lo': 18, 'icon': Icons.cloudy_snowing},
    {'d': 'Min', 'hi': 24, 'lo': 19, 'icon': Icons.cloud_outlined},
    {'d': 'Sen', 'hi': 25, 'lo': 19, 'icon': Icons.wb_sunny_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Stack(
      children: [
        // ====== BACKDROP ANIMASI SESUAI KONDISI ======
        Positioned.fill(child: _SkyBackdrop(type: _type)),

        // ====== KONTEN ======
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // kartu hero (semi “glass” agar latar kelihatan)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                decoration: BoxDecoration(
                  color: cs.surface.withValues(alpha: .65),
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: cs.shadow.withValues(alpha: .12),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on, color: cs.onSurface),
                        const SizedBox(width: 6),
                        Text(
                          _city,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.more_horiz),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _dateText,
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // suhu besar
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ConditionBadge(type: _type), // ikon/emoji kecil
                        const SizedBox(width: 10),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: cs.onSurface,
                                  fontSize: 88,
                                  height: 0.9,
                                  fontWeight: FontWeight.w800,
                                ),
                                children: [
                                  TextSpan(text: '$_nowTemp'),
                                  TextSpan(
                                    text: '°',
                                    style: TextStyle(
                                      fontSize: 50,
                                      color: cs.onSurfaceVariant,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _nowCond,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // info ringkas
              _InfoRow(
                items: [
                  _InfoItem(
                    icon: Icons.grain,
                    label: 'Presipitasi',
                    value: '$_precip%',
                  ),
                  _InfoItem(
                    icon: Icons.water_drop,
                    label: 'Kelembapan',
                    value: '$_humid%',
                  ),
                  _InfoItem(
                    icon: Icons.air,
                    label: 'Angin',
                    value: '${_wind.toStringAsFixed(0)} km/h',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // hourly
              const _SectionTitle(title: 'Hari Ini'),
              const SizedBox(height: 8),
              _HourlyChips(items: _hourly),
              const SizedBox(height: 16),

              // weekly
              const _SectionTitle(title: '7-Hari Prakiraan'),
              const SizedBox(height: 8),
              _WeeklyForecast(items: _weekly),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }
}

/* ============= BACKDROP ANIMASI ============= */

class _SkyBackdrop extends StatelessWidget {
  const _SkyBackdrop({required this.type});
  final WeatherType type;

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case WeatherType.sunny:
        return const _SunnyBackdrop();
      case WeatherType.cloudy:
        return const _CloudyBackdrop();
      case WeatherType.rain:
        return const _RainBackdrop();
      case WeatherType.thunder:
        return const _ThunderBackdrop();
      // case WeatherType.fog: return const _FogBackdrop();
      // case WeatherType.night: return const _NightBackdrop();
    }
  }
}

// CERAH: matahari berdenyut pelan
class _SunnyBackdrop extends StatefulWidget {
  const _SunnyBackdrop();
  @override
  State<_SunnyBackdrop> createState() => _SunnyBackdropState();
}

class _SunnyBackdropState extends State<_SunnyBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat(reverse: true);
  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: c,
      builder: (_, __) {
        final pulse = 0.85 + c.value * 0.3; // 0.85..1.15
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.lightBlue.withValues(alpha: .65), Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Align(
            alignment: const Alignment(-0.8, -0.9),
            child: Container(
              width: 120 * pulse,
              height: 120 * pulse,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.amber,
                boxShadow: [
                  BoxShadow(
                    color: cs.shadow.withValues(alpha: .25),
                    blurRadius: 40,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// BERAWAN: awan bergerak melintas
class _CloudyBackdrop extends StatefulWidget {
  const _CloudyBackdrop();
  @override
  State<_CloudyBackdrop> createState() => _CloudyBackdropState();
}

class _CloudyBackdropState extends State<_CloudyBackdrop>
    with TickerProviderStateMixin {
  late final AnimationController c1 = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 40),
  )..repeat();
  late final AnimationController c2 = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 55),
  )..repeat();
  late final AnimationController c3 = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 70),
  )..repeat();

  @override
  void dispose() {
    c1.dispose();
    c2.dispose();
    c3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        // latar langit
        final bg = Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF94A9FF), Color(0xFFE9F0FF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        );

        // fungsi posisi X dari controller (0..1)
        double x(AnimationController c, double w, double width) =>
            c.value * (w + width) - width;

        // satu cloud “gelembung” putih
        Widget cloud(double w, double h, double opacity) => Opacity(
          opacity: opacity,
          child: _CloudShape(width: w, height: h),
        );

        return Stack(
          fit: StackFit.expand,
          children: [
            bg,
            // layer 1 (paling atas)
            AnimatedBuilder(
              animation: c1,
              builder: (_, __) => Transform.translate(
                offset: Offset(x(c1, box.maxWidth, 240), box.maxHeight * .20),
                child: cloud(240, 90, .85),
              ),
            ),
            // layer 2
            AnimatedBuilder(
              animation: c2,
              builder: (_, __) => Transform.translate(
                offset: Offset(
                  x(c2, box.maxWidth, 300) - 100,
                  box.maxHeight * .40,
                ),
                child: cloud(300, 110, .75),
              ),
            ),
            // layer 3 (paling bawah)
            AnimatedBuilder(
              animation: c3,
              builder: (_, __) => Transform.translate(
                offset: Offset(
                  x(c3, box.maxWidth, 200) - 50,
                  box.maxHeight * .55,
                ),
                child: cloud(200, 80, .65),
              ),
            ),
          ],
        );
      },
    );
  }
}

// HUJAN: garis-garis jatuh
class _RainBackdrop extends StatefulWidget {
  const _RainBackdrop();
  @override
  State<_RainBackdrop> createState() => _RainBackdropState();
}

class _RainBackdropState extends State<_RainBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();
  final rnd = math.Random(42);
  late final List<double> xs = List.generate(
    90,
    (_) => rnd.nextDouble(),
  ); // posisi X relatif (0..1)
  late final List<double> len = List.generate(
    90,
    (_) => rnd.nextDouble() * 20 + 10,
  ); // panjang garis

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: c,
      builder: (_, __) => CustomPaint(
        painter: _RainPainter(progress: c.value, xs: xs, lengths: len),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF5E6A8A), Color(0xFFBBC4D6)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
    );
  }
}

class _RainPainter extends CustomPainter {
  _RainPainter({
    required this.progress,
    required this.xs,
    required this.lengths,
  });
  final double progress;
  final List<double> xs;
  final List<double> lengths;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withValues(alpha: .35)
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < xs.length; i++) {
      final x = xs[i] * size.width;
      final y =
          (progress * (size.height + 100) + i * 20) % (size.height + 100) - 100;
      final l = lengths[i];
      canvas.drawLine(Offset(x, y), Offset(x, y + l), p);
    }
  }

  @override
  bool shouldRepaint(covariant _RainPainter old) => old.progress != progress;
}

// BADAI: hujan + flash kilat
class _ThunderBackdrop extends StatefulWidget {
  const _ThunderBackdrop();
  @override
  State<_ThunderBackdrop> createState() => _ThunderBackdropState();
}

class _ThunderBackdropState extends State<_ThunderBackdrop>
    with TickerProviderStateMixin {
  late final AnimationController rain = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();
  late final AnimationController flash = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat();
  final rnd = math.Random(21);
  late final List<double> xs = List.generate(100, (_) => rnd.nextDouble());
  late final List<double> len = List.generate(
    100,
    (_) => rnd.nextDouble() * 22 + 12,
  );

  @override
  void dispose() {
    rain.dispose();
    flash.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedBuilder(
          animation: rain,
          builder: (_, __) => CustomPaint(
            painter: _RainPainter(progress: rain.value, xs: xs, lengths: len),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF424B6D), Color(0xFF8A93AC)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ),
        // flash kilat singkat (opacity naik-turun cepat)
        AnimatedBuilder(
          animation: flash,
          builder: (_, __) {
            final t = flash.value;
            // dua kilatan: di t~0.2 dan t~0.85
            double op = 0;
            if ((t > .18 && t < .24) || (t > .84 && t < .88)) op = .35;
            return Container(color: Colors.white.withValues(alpha: op));
          },
        ),
      ],
    );
  }
}

/* ============= KOMPONEN UI KECIL ============= */

class _ConditionBadge extends StatelessWidget {
  const _ConditionBadge({required this.type});
  final WeatherType type;

  @override
  Widget build(BuildContext context) {
    final map = {
      WeatherType.sunny: Icons.wb_sunny,
      WeatherType.cloudy: Icons.cloud,
      WeatherType.rain: Icons.grain,
      WeatherType.thunder: Icons.thunderstorm,
    };
    return Container(
      width: 64,
      height: 64,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.amber,
      ),
      alignment: Alignment.center,
      child: Icon(map[type], color: Colors.white),
    );
  }
}

class _CloudShape extends StatelessWidget {
  const _CloudShape({required this.width, required this.height});
  final double width, height;

  @override
  Widget build(BuildContext context) {
    // komposisi beberapa lingkaran + kapsul agar terlihat seperti awan
    final base = Colors.white.withValues(alpha: .92);
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          _bubble(
            width * .40,
            height * .80,
            Offset(width * .18, height * .10),
            base,
          ),
          _bubble(
            width * .36,
            height * .70,
            Offset(width * .42, height * .04),
            base,
          ),
          _bubble(
            width * .28,
            height * .55,
            Offset(width * .62, height * .20),
            base,
          ),
          _capsule(
            width * .85,
            height * .50,
            Offset(width * .10, height * .40),
            base,
          ),
        ],
      ),
    );
  }

  Widget _bubble(double w, double h, Offset pos, Color color) {
    return Positioned(
      left: pos.dx,
      top: pos.dy,
      child: Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .06),
              blurRadius: 12,
            ),
          ],
        ),
      ),
    );
  }

  Widget _capsule(double w, double h, Offset pos, Color color) {
    return Positioned(
      left: pos.dx,
      top: pos.dy,
      child: Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(h / 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .06),
              blurRadius: 12,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;
  _InfoItem({required this.icon, required this.label, required this.value});
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.items});
  final List<_InfoItem> items;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: items
          .map(
            (e) => Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: cs.shadow.withValues(alpha: .06),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(e.icon, color: cs.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.label,
                            style: TextStyle(
                              color: cs.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            e.value,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        const SizedBox(width: 8),
        Expanded(child: Divider(color: cs.outlineVariant)),
      ],
    );
  }
}

class _HourlyChips extends StatelessWidget {
  const _HourlyChips({required this.items});
  final List<Map<String, dynamic>> items;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final it = items[i];
          return Container(
            width: 88,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  it['t'] as String,
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                ),
                Icon(it['icon'] as IconData, color: cs.primary),
                Text(
                  '${it['temp']}°',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _WeeklyForecast extends StatelessWidget {
  const _WeeklyForecast({required this.items});
  final List<Map<String, dynamic>> items;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(22),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 0),
        itemBuilder: (context, i) {
          final it = items[i];
          return ListTile(
            dense: true,
            leading: Icon(it['icon'] as IconData, color: cs.primary),
            title: Text(
              it['d'] as String,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            trailing: Text(
              '${it['hi']}/${it['lo']}°',
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
          );
        },
      ),
    );
  }
}
