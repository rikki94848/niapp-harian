import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Uint8List & FilteringTextInputFormatter
import 'package:image_picker/image_picker.dart';

enum Gender { male, female }

class BiodataPage extends StatefulWidget {
  const BiodataPage({super.key});

  @override
  State<BiodataPage> createState() => _BiodataPageState();
}

class _BiodataPageState extends State<BiodataPage> {
  final _formKey = GlobalKey<FormState>();

  // Prefill contoh
  final _namaC = TextEditingController(text: '');
  final _hpC = TextEditingController(); // No. HP
  final _emailC = TextEditingController();

  Gender _gender = Gender.male;
  String _prodi = 'Informatika';
  DateTime? _dob;

  Uint8List? _avatarBytes; // foto dari galeri (tanpa DB)

  @override
  void dispose() {
    _namaC.dispose();
    _hpC.dispose();
    _emailC.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 900,
        imageQuality: 85,
      );
      if (file != null) {
        final bytes = await file.readAsBytes();
        setState(() => _avatarBytes = bytes);
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal memilih foto.')));
    }
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 20, now.month, now.day),
      firstDate: DateTime(now.year - 60, 1, 1),
      lastDate: DateTime(now.year, now.month, now.day),
    );
    if (picked != null) {
      setState(() => _dob = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final dobStr = _dob == null
        ? '-'
        : '${_dob!.day.toString().padLeft(2, '0')}-'
              '${_dob!.month.toString().padLeft(2, '0')}-${_dob!.year}';
    final gStr = _gender == Gender.male ? 'Laki-laki' : 'Perempuan';

    final msg =
        '✅ Disimpan (sementara)\n'
        'Nama : ${_namaC.text}\n'
        'HP   : ${_hpC.text}\n'
        'Email: ${_emailC.text.isEmpty ? '-' : _emailC.text}\n'
        'Prodi: $_prodi\n'
        'Gender: $gStr\n'
        'Tanggal Lahir: $dobStr';

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _reset() {
    _formKey.currentState?.reset();
    setState(() {
      _namaC.text = 'Rikki Subagja';
      _hpC.clear();
      _emailC.clear();
      _gender = Gender.male;
      _prodi = 'Informatika';
      _dob = null;
      _avatarBytes = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ===== Header + Avatar =====
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  cs.primary.withValues(alpha: .18),
                  cs.tertiary.withValues(alpha: .16),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    _AvatarCircle(bytes: _avatarBytes),
                    Material(
                      color: cs.primary,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: _pickAvatar,
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Profil',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
                ),
                const SizedBox(height: 4),
                Text(
                  'Lengkapi data diri dengan benar',
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ===== Form =====
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _Labeled(
                      'Nama Lengkap',
                      TextFormField(
                        controller: _namaC,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          hintText: 'Nama lengkap',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Nama tidak boleh kosong'
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _Labeled(
                      'No. HP',
                      TextFormField(
                        controller: _hpC,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          hintText: 'Contoh: 081234567890',
                          prefixIcon: Icon(Icons.phone),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return 'No. HP wajib diisi';
                          if (v.length < 10) return 'No. HP terlalu pendek';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 12),

                    _Labeled(
                      'Email (opsional)',
                      TextFormField(
                        controller: _emailC,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'nama@email.com',
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return null;
                          final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v);
                          return ok ? null : 'Format email tidak valid';
                        },
                      ),
                    ),
                    const SizedBox(height: 12),

                    _Labeled(
                      'Program Studi',
                      DropdownButtonFormField<String>(
                        initialValue: _prodi, // (fix deprecated 'value')
                        items: const [
                          DropdownMenuItem(
                            value: 'Informatika',
                            child: Text('Informatika'),
                          ),
                          DropdownMenuItem(
                            value: 'Sistem Informasi',
                            child: Text('Sistem Informasi'),
                          ),
                          DropdownMenuItem(
                            value: 'Teknik Elektro',
                            child: Text('Teknik Elektro'),
                          ),
                          DropdownMenuItem(
                            value: 'Teknik Industri',
                            child: Text('Teknik Industri'),
                          ),
                        ],
                        onChanged: (v) => setState(() => _prodi = v!),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.school),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    _Labeled(
                      'Jenis Kelamin',
                      _GenderSelector(
                        value: _gender,
                        onChanged: (g) => setState(() => _gender = g),
                      ),
                    ),
                    const SizedBox(height: 12),

                    _Labeled(
                      'Tanggal Lahir',
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _pickDob,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.calendar_today),
                            hintText: 'Pilih tanggal lahir',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            _dob == null
                                ? '—'
                                : '${_dob!.day.toString().padLeft(2, '0')}-'
                                      '${_dob!.month.toString().padLeft(2, '0')}-${_dob!.year}',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _reset,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reset'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _submit,
                            icon: const Icon(Icons.save),
                            label: const Text('Simpan'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ---------------- Widgets kecil ---------------- */

class _Labeled extends StatelessWidget {
  const _Labeled(this.label, this.child);
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w700, color: cs.onSurface),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({required this.bytes});
  final Uint8List? bytes;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // SELALU terisi: dari galeri jika ada, kalau tidak pakai aset default
    final ImageProvider avatarProvider = (bytes != null && bytes!.isNotEmpty)
        ? MemoryImage(bytes!)
        : const AssetImage('assets/1546d15ce5dd2946573b3506df109d00.jpg');

    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [cs.primary, cs.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: cs.shadow.withValues(alpha: .12), blurRadius: 14),
        ],
        image: DecorationImage(image: avatarProvider, fit: BoxFit.cover),
      ),
    );
  }
}

/// Selector jenis kelamin dengan ikon yang lebih “wah”
class _GenderSelector extends StatelessWidget {
  const _GenderSelector({required this.value, required this.onChanged});
  final Gender value;
  final ValueChanged<Gender> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: _GenderTile(
            selected: value == Gender.male,
            label: 'Laki-laki',
            icon: Icons.male,
            gradient: [Colors.blue, cs.primary],
            onTap: () => onChanged(Gender.male),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _GenderTile(
            selected: value == Gender.female,
            label: 'Perempuan',
            icon: Icons.female,
            gradient: [Colors.purple, cs.tertiary],
            onTap: () => onChanged(Gender.female),
          ),
        ),
      ],
    );
  }
}

class _GenderTile extends StatelessWidget {
  const _GenderTile({
    required this.selected,
    required this.label,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  final bool selected;
  final String label;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: selected ? null : cs.surfaceContainerHigh,
        gradient: selected
            ? LinearGradient(
                colors: gradient.map((c) => c.withValues(alpha: .85)).toList(),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        boxShadow: selected
            ? [
                BoxShadow(
                  color: cs.shadow.withValues(alpha: .16),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ]
            : [],
        border: Border.all(
          color: selected ? Colors.transparent : cs.outlineVariant,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: selected
                    ? Colors.white.withValues(alpha: .85)
                    : cs.primary.withValues(alpha: .10),
                child: Icon(
                  icon,
                  size: 18,
                  color: selected ? Colors.black87 : cs.primary,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : cs.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
