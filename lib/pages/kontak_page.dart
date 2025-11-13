import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Contact {
  String name;
  String phone;
  Contact(this.name, this.phone);
}

class KontakPage extends StatefulWidget {
  const KontakPage({super.key});
  @override
  State<KontakPage> createState() => _KontakPageState();
}

class _KontakPageState extends State<KontakPage> {
  final _searchC = TextEditingController();

  // ≥ 15 data statis
  final List<Contact> _contacts = [
    Contact('Andi', '08120001'),
    Contact('Budi', '08120002'),
    Contact('Cici', '08120003'),
    Contact('Dodi', '08120004'),
    Contact('Eka', '08120005'),
    Contact('Fajar', '08120006'),
    Contact('Gina', '08120007'),
    Contact('Hani', '08120008'),
    Contact('Intan', '08120009'),
    Contact('Jaka', '08120010'),
    Contact('Kiki', '08120011'),
    Contact('Lia', '08120012'),
    Contact('Miko', '08120013'),
    Contact('Nina', '08120014'),
    Contact('Omar', '08120015'),
  ];

  late List<Contact> _filtered = List<Contact>.from(_contacts);

  @override
  void initState() {
    super.initState();
    _searchC.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchC.removeListener(_applyFilter);
    _searchC.dispose();
    super.dispose();
  }

  void _applyFilter() {
    final q = _searchC.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? List<Contact>.from(_contacts)
          : _contacts
                .where(
                  (c) =>
                      c.name.toLowerCase().contains(q) || c.phone.contains(q),
                )
                .toList();
    });
  }

  // ========= UI helpers =========
  List<MapEntry<String, List<Contact>>> _grouped(List<Contact> items) {
    final map = <String, List<Contact>>{};
    for (final c in items) {
      final k = (c.name.trim().isEmpty ? '#' : c.name[0].toUpperCase());
      map.putIfAbsent(k, () => []).add(c);
    }
    final keys = map.keys.toList()..sort();
    return keys.map((k) {
      final list = map[k]!..sort((a, b) => a.name.compareTo(b.name));
      return MapEntry(k, list);
    }).toList();
  }

  List<Color> _avatarGradient(String name, ColorScheme cs) {
    final options = <List<Color>>[
      [cs.primary, cs.tertiary],
      [Colors.blue, Colors.teal],
      [Colors.deepOrange, Colors.pinkAccent],
      [Colors.indigo, Colors.purple],
      [Colors.green, Colors.cyan],
    ];
    final idx = name.codeUnits.fold<int>(0, (a, b) => a + b) % options.length;
    return options[idx];
  }

  Widget _circleInitial(String name, ColorScheme cs) {
    final colors = _avatarGradient(name, cs);
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: colors),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: .15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _actionIcon(IconData icon, VoidCallback onTap, ColorScheme cs) {
    return Material(
      color: cs.primary.withValues(alpha: .10),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: cs.primary, size: 20),
        ),
      ),
    );
  }

  // ========= actions =========
  Future<void> _call(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _toast('Tidak bisa membuka dialer.');
    }
  }

  Future<void> _sms(String number) async {
    final uri = Uri(scheme: 'sms', path: number);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _toast('Tidak bisa membuka aplikasi pesan.');
    }
  }

  void _toast(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  void _showAddDialog() {
    final nameC = TextEditingController();
    final phoneC = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tambah Kontak'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameC,
              decoration: const InputDecoration(
                labelText: 'Nama',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: phoneC,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Nomor',
                prefixIcon: Icon(Icons.phone),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              final n = nameC.text.trim();
              final p = phoneC.text.trim();
              if (n.isEmpty || p.isEmpty) return;
              setState(() {
                _contacts.add(Contact(n, p));
                _applyFilter();
              });
              Navigator.pop(context);
              _toast('Kontak "$n" ditambahkan');
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _openSheet(Contact c) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _circleInitial(c.name, cs),
            const SizedBox(height: 12),
            Text(
              c.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(c.phone, style: TextStyle(color: cs.onSurfaceVariant)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.call),
                    label: const Text('Telepon'),
                    onPressed: () => _call(c.phone),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.sms),
                    label: const Text('Pesan'),
                    onPressed: () => _sms(c.phone),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final groups = _grouped(_filtered);

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            // Header gradasi
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      cs.primary.withValues(alpha: .16),
                      cs.tertiary.withValues(alpha: .14),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.contacts, color: cs.primary),
                        const SizedBox(width: 10),
                        const Text(
                          'Kontak',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Total: ${_filtered.length}',
                          style: TextStyle(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _searchC,
                      decoration: InputDecoration(
                        hintText: 'Cari nama atau nomor…',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: cs.surface.withValues(alpha: .7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: cs.outlineVariant),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: cs.outlineVariant),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Kelompok A, B, C, ...
            for (final entry in groups) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 6, 24, 6),
                  child: Row(
                    children: [
                      Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const Expanded(child: Divider(thickness: .6, indent: 12)),
                    ],
                  ),
                ),
              ),
              SliverList.builder(
                itemCount: entry.value.length,
                itemBuilder: (_, i) {
                  final c = entry.value[i];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: Material(
                      color: cs.surfaceContainerHigh,
                      elevation: 1,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _openSheet(c),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              _circleInitial(c.name, cs),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      c.phone,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: cs.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              _actionIcon(Icons.call, () => _call(c.phone), cs),
                              const SizedBox(width: 8),
                              _actionIcon(Icons.sms, () => _sms(c.phone), cs),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 96)),
          ],
        ),

        // FAB tambah kontak
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            onPressed: _showAddDialog,
            icon: const Icon(Icons.add),
            label: const Text(''),
          ),
        ),
      ],
    );
  }
}
