import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsItem {
  final String title;
  final String excerpt;
  final String source;
  final String date; // Misal: 13 Nov 2025
  final String url; // Link berita asli
  final String? imageAsset; // Opsional: pakai aset lokal
  final String? imageUrl; // Opsional: gambar dari internet

  const NewsItem({
    required this.title,
    required this.excerpt,
    required this.source,
    required this.date,
    required this.url,
    this.imageAsset,
    this.imageUrl,
  });
}

class BeritaPage extends StatelessWidget {
  const BeritaPage({super.key});

  // ================== ISI BERITA (10 item terkini) ==================
  List<NewsItem> get _news => const [
    // 1) Persib Bandung
    NewsItem(
      title:
          'Persib Nyaris Tumbang Lawan Selangor, Marc Klok: Kami Terlalu Percaya Diri',
      excerpt:
          'Kapten Persib mengakui performa tim sempat lengah saat uji tanding kontra Selangor.',
      source: 'JPNN',
      date: '13 Nov 2025',
      imageAsset:
          'assets/news/kapten-persib-bandung-marc-klok-foto-persib-hagep-pkgt.jpg',
      url:
          'https://www.jpnn.com/news/persib-bandung-nyaris-tumbang-dari-selangor-marc-klok-kami-terlalu-percaya-diri',
    ),

    // 2) Timnas Indonesia (U-22)
    NewsItem(
      title:
          'Pelatih Thailand Sebut Timnas U-22 Indonesia Ancaman Serius di SEA Games 2025',
      excerpt:
          'Jelang uji coba vs Mali, media Thailand menyorot potensi skuad Garuda Muda.',
      source: 'Okezone',
      date: '13 Nov 2025',
      imageAsset: 'assets/news/timnas_indonesia_u_22-eVmU_large.jpg',
      url:
          'https://bola.okezone.com/read/2025/11/13/51/3183399/pelatih-thailand-ketar-ketir-sebut-timnas-indonesia-u-22-ancaman-serius-di-sea-games-2025',
    ),

    // 3) Mobile Legends
    NewsItem(
      title:
          'Kode Redeem Mobile Legends 13 November 2025: Klaim Hadiah Eksklusif',
      excerpt:
          'Moonton merilis kode redeem harian yang bisa ditukar menjadi skin, fragment, hingga diamond.',
      source: 'HiTekno',
      date: '13 Nov 2025',
      imageAsset: 'assets/news/mlbb.jpg',
      url:
          'https://www.hitekno.com/games/2025/11/13/091154/kode-redeem-mobile-legends-hari-ini-13-november-2025-raih-hadiah-eksklusif-hingga-skin-fragment',
    ),

    // 4) Ekonomi – redenominasi rupiah
    NewsItem(
      title: 'Indonesia Siapkan RUU Redenominasi Rupiah',
      excerpt:
          'Kemenkeu menyiapkan payung hukum penyederhanaan mata uang untuk efisiensi dan kredibilitas.',
      source: 'Reuters',
      date: '8 Nov 2025',
      imageUrl: 'https://example.com/market.jpg',
      url:
          'https://www.reuters.com/world/asia-pacific/indonesia-plans-bill-redenominate-rupiah-currency-2025-11-08/',
    ),

    // 5) Pasar modal
    NewsItem(
      title: 'IHSG Ditutup Melemah, Pasar Mencermati Isu Global',
      excerpt:
          'Indeks saham domestik tergelincir; pelaku pasar memantau sentimen eksternal.',
      source: 'Tempo',
      date: '13 Nov 2025',
      url:
          'https://bisnis.tempo.co/read/2065439/ihsg-ditutup-melemah-pasar-cermati-pembukaan-kembali-pemerintah-as',
    ),

    // 6) Ekonomi digital
    NewsItem(
      title:
          'Indonesia Pimpin Ekonomi Digital Asia Tenggara, Didukung Pertumbuhan AI',
      excerpt:
          'Nilai ekonomi digital diperkirakan mendekati USD100 miliar; tumbuh 14% yoy.',
      source: 'ANTARA',
      date: '13 Nov 2025',
      url:
          'https://www.antaranews.com/berita/5239813/indonesia-pimpin-ekonomi-digital-didukung-pertumbuhan-ai',
    ),

    // 7) Energi listrik
    NewsItem(
      title:
          'Pemerintah Proyeksikan Produksi Listrik RI Capai 354 TWh pada 2025',
      excerpt:
          'Proyeksi suplai listrik disampaikan seiring update cadangan migas terbaru.',
      source: 'Tempo (EN)',
      date: '13 Nov 2025',
      url:
          'https://en.tempo.co/read/2065453/government-projects-indonesias-electricity-output-to-reach-354-twh-in-2025',
    ),

    // 8) Rupiah
    NewsItem(
      title: 'Rupiah Dibuka di Rp16.732 per Dolar AS',
      excerpt:
          'Nilai tukar melemah di awal perdagangan; pasar menanti data eksternal.',
      source: 'CNN Indonesia',
      date: '13 Nov 2025',
      url:
          'https://www.cnnindonesia.com/ekonomi/20251113091710-78-1294989/rupiah-amblas-ke-rp16732-pagi-ini',
    ),

    // 9) Emas
    NewsItem(
      title: 'Emas Antam Naik Tiga Hari Beruntun',
      excerpt:
          'Harga logam mulia menyentuh Rp2,396 juta/gram, melanjutkan tren penguatan.',
      source: 'CNN Indonesia',
      date: '13 Nov 2025',
      url:
          'https://www.cnnindonesia.com/ekonomi/20251113094244-92-1294994/harga-emas-antam-naik-tiga-hari-beruntun-ke-rp2396-juta-per-gram',
    ),

    // 10) BBM Bali
    NewsItem(
      title: 'Kelangkaan BBM di Bali, Pertamina Buka Suara',
      excerpt:
          'Pertamina menanggapi laporan antrian dan keterbatasan pasokan di sejumlah SPBU.',
      source: 'CNN Indonesia',
      date: '13 Nov 2025',
      url:
          'https://www.cnnindonesia.com/ekonomi/20251113111614-85-1295040/masyarakat-mengeluh-bbm-langka-di-bali-pertamina-buka-suara',
    ),
  ];
  // =================================================================

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _openDetail(BuildContext context, NewsItem n) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // gambar (jika ada)
            if (n.imageAsset != null || n.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: n.imageAsset != null
                    ? Image.asset(n.imageAsset!, fit: BoxFit.cover)
                    : Image.network(
                        n.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
              ),
            const SizedBox(height: 12),
            Text(
              n.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.source, size: 16, color: cs.primary),
                const SizedBox(width: 6),
                Text(
                  n.source,
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Icon(Icons.calendar_month, size: 16, color: cs.primary),
                const SizedBox(width: 6),
                Text(n.date, style: TextStyle(color: cs.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: 10),
            Text(n.excerpt, style: TextStyle(color: cs.onSurface)),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Baca sumber'),
                    onPressed: () => _openUrl(n.url),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.share_outlined),
                    label: const Text('Salin tautan'),
                    onPressed: () {
                      // cukup tampilkan snackbar; implementasi salin bisa ditambah package clipboard bila perlu
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tautan disalin (simulasi).'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final items = _news;

    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  cs.primary.withValues(alpha: .18),
                  cs.tertiary.withValues(alpha: .16),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.newspaper, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Berita Terkini',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ),

        // List kartu
        SliverList.builder(
          itemCount: items.length,
          itemBuilder: (context, i) {
            final n = items[i];
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
              child: _NewsCard(item: n, onTap: () => _openDetail(context, n)),
            );
          },
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }
}

/* ----------------------- Widgets kecil ----------------------- */

class _NewsCard extends StatelessWidget {
  const _NewsCard({required this.item, required this.onTap});
  final NewsItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: cs.surfaceContainerHigh,
      elevation: 2,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _NewsImage(item: item, height: 190),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.excerpt,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: cs.onSurfaceVariant, height: 1.35),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.calendar_month, size: 18, color: cs.primary),
                      const SizedBox(width: 6),
                      Text(
                        item.date,
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        item.source,
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewsImage extends StatelessWidget {
  const _NewsImage({required this.item, required this.height});
  final NewsItem item;
  final double height;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget fallback = Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary, cs.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.image_outlined, size: 48, color: Colors.white),
      ),
    );

    if (item.imageAsset != null) {
      return Image.asset(
        item.imageAsset!,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      );
    }
    if (item.imageUrl != null) {
      return Image.network(
        item.imageUrl!,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      );
    }
    return fallback;
  }
}
