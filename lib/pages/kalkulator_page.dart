import 'package:flutter/material.dart';

class KalkulatorPage extends StatefulWidget {
  const KalkulatorPage({super.key});

  @override
  State<KalkulatorPage> createState() => _KalkulatorPageState();
}

class _KalkulatorPageState extends State<KalkulatorPage> {
  String _expr = '';
  String _result = '0';
  final List<_HistoryItem> _history = [];

  // ---------- Helpers UI ----------
  void _showHistorySheet() {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        if (_history.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('Belum ada riwayat')),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: _history.length,
          separatorBuilder: (_, __) => const Divider(height: 0),
          itemBuilder: (_, i) {
            final h = _history[_history.length - 1 - i];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 6),
              title: Text(h.expr, style: TextStyle(color: cs.onSurfaceVariant)),
              subtitle: Text(
                h.result,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _expr = h.expr;
                  _result = h.result;
                });
              },
            );
          },
        );
      },
    );
  }

  // ---------- Evaluator ----------
  void _onTap(String key) {
    setState(() {
      switch (key) {
        case 'AC':
          _expr = '';
          _result = '0';
          break;
        case 'C':
          if (_expr.isNotEmpty) _expr = '';
          _result = '0';
          break;
        case '⌫':
          if (_expr.isNotEmpty) {
            _expr = _expr.substring(0, _expr.length - 1);
          }
          break;
        case '=':
          if (_expr.isEmpty) return;
          final res = _safeEval(_expr);
          final formatted = _formatNumber(res);
          _result = formatted;
          _history.add(
            _HistoryItem(expr: _exprForDisplay(_expr), result: formatted),
          );
          // batasi 50 item
          if (_history.length > 50) _history.removeAt(0);
          break;
        case '±':
          // toggle sign angka terakhir
          _toggleSign();
          break;
        case '%':
          // tambahkan % setelah angka terakhir
          _appendPercent();
          break;
        default:
          _expr += key;
      }
    });
  }

  void _toggleSign() {
    // cari angka terakhir
    final i = _lastNumberRange(_expr);
    if (i == null) return;
    final start = i.$1, end = i.$2;
    final numStr = _expr.substring(start, end);
    if (numStr.startsWith('(-') && numStr.endsWith(')')) {
      _expr = _expr.replaceRange(
        start,
        end,
        numStr.substring(2, numStr.length - 1),
      );
    } else {
      _expr = _expr.replaceRange(start, end, '(-$numStr)');
    }
  }

  void _appendPercent() {
    final i = _lastNumberRange(_expr);
    if (i == null) return;
    final start = i.$1, end = i.$2;
    final numStr = _expr.substring(start, end);
    // ubah menjadi (num/100)
    _expr = _expr.replaceRange(start, end, '($numStr/100)');
  }

  /// Kembalikan (start, end) index angka terakhir dalam _expr; jika tidak ada -> null
  (int, int)? _lastNumberRange(String s) {
    if (s.isEmpty) return null;
    int end = s.length;
    int i = end - 1;
    while (i >= 0) {
      final ch = s[i];
      if ('0123456789.'.contains(ch) || ch == ')') {
        i--;
      } else {
        break;
      }
    }
    if (i == end - 1) return null; // tidak ada angka di akhir
    final start = i + 1;
    return (start, end);
  }

  // Evaluasi ekspresi (mendukung + - × ÷ * /, titik, kurung, dan hasil dari %/toggle)
  double _safeEval(String input) {
    try {
      final s = input
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('−', '-');
      final tokens = _tokenize(s);
      final rpn = _toRpn(tokens);
      return _evalRpn(rpn);
    } catch (_) {
      return double.nan;
    }
  }

  List<String> _tokenize(String s) {
    final tokens = <String>[];
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      final ch = s[i];
      if ('0123456789.'.contains(ch)) {
        buf.write(ch);
      } else if ('+-*/()'.contains(ch)) {
        if (buf.isNotEmpty) {
          tokens.add(buf.toString());
          buf.clear();
        }
        // tangani minus unary: ubah "-(" atau "-5" di awal/ setelah operator menjadi "0-"
        if (ch == '-' && (i == 0 || '()+-*/'.contains(s[i - 1]))) {
          tokens.add('0');
        }
        tokens.add(ch);
      } else {
        // abaikan spasi/karakter lain
      }
    }
    if (buf.isNotEmpty) tokens.add(buf.toString());
    return tokens;
  }

  List<String> _toRpn(List<String> tokens) {
    final out = <String>[];
    final ops = <String>[];
    int prec(String op) => (op == '+' || op == '-') ? 1 : 2;

    for (final t in tokens) {
      if (double.tryParse(t) != null) {
        out.add(t);
      } else if ('+-*/'.contains(t)) {
        while (ops.isNotEmpty &&
            '+-*/'.contains(ops.last) &&
            prec(ops.last) >= prec(t)) {
          out.add(ops.removeLast());
        }
        ops.add(t);
      } else if (t == '(') {
        ops.add(t);
      } else if (t == ')') {
        while (ops.isNotEmpty && ops.last != '(') {
          out.add(ops.removeLast());
        }
        if (ops.isNotEmpty && ops.last == '(') ops.removeLast();
      }
    }
    while (ops.isNotEmpty) {
      out.add(ops.removeLast());
    }
    return out;
  }

  double _evalRpn(List<String> rpn) {
    final st = <double>[];
    for (final t in rpn) {
      final v = double.tryParse(t);
      if (v != null) {
        st.add(v);
        continue;
      }
      if (st.length < 2) return double.nan;
      final b = st.removeLast();
      final a = st.removeLast();
      switch (t) {
        case '+':
          st.add(a + b);
          break;
        case '-':
          st.add(a - b);
          break;
        case '*':
          st.add(a * b);
          break;
        case '/':
          st.add(b == 0 ? double.nan : a / b);
          break;
        default:
          return double.nan;
      }
    }
    return st.isEmpty ? double.nan : st.last;
  }

  String _formatNumber(double v) {
    if (v.isNaN || v.isInfinite) return 'Error';
    final s = v.toStringAsFixed(10);
    final trimmed = s.replaceFirst(RegExp(r'\.?0+$'), '');
    return trimmed;
  }

  String _exprForDisplay(String s) =>
      s.replaceAll('*', '×').replaceAll('/', '÷');

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Header / Display
        Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 10),
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
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // ekspresi kecil di kanan atas
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: Text(
                  _exprForDisplay(_expr),
                  style: TextStyle(fontSize: 18, color: cs.onSurfaceVariant),
                ),
              ),
              const SizedBox(height: 8),
              // hasil besar
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: Text(
                  _result,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // action row
              Row(
                children: [
                  _ChipAction(
                    icon: Icons.history,
                    label: 'Riwayat',
                    onTap: _showHistorySheet,
                  ),
                  const SizedBox(width: 8),
                  _ChipAction(
                    icon: Icons.cleaning_services_outlined,
                    label: 'Clear',
                    onTap: () => _onTap('C'),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Keypad
        Expanded(
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 10),
            child: _Keypad(onTap: _onTap),
          ),
        ),
      ],
    );
  }
}

/* ----------------------- Widgets kecil ----------------------- */

class _ChipAction extends StatelessWidget {
  const _ChipAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: cs.primary),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(color: cs.onSurface)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({required this.onTap});
  final void Function(String) onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Definisi tombol: label dan style
    final keys = <_KeyDef>[
      _KeyDef('AC', type: KeyType.func),
      _KeyDef('±', type: KeyType.func),
      _KeyDef('%', type: KeyType.func),
      _KeyDef('⌫', type: KeyType.func),

      _KeyDef('7'),
      _KeyDef('8'),
      _KeyDef('9'),
      _KeyDef('÷', type: KeyType.op),

      _KeyDef('4'),
      _KeyDef('5'),
      _KeyDef('6'),
      _KeyDef('×', type: KeyType.op),

      _KeyDef('1'),
      _KeyDef('2'),
      _KeyDef('3'),
      _KeyDef('−', type: KeyType.op),

      _KeyDef('(', type: KeyType.func),
      _KeyDef('0'),
      _KeyDef(')', type: KeyType.func),
      _KeyDef('+', type: KeyType.op),

      _KeyDef('.', flex: 2),
      _KeyDef('=', type: KeyType.equals, flex: 2),
    ];

    return LayoutBuilder(
      builder: (context, c) {
        final cross = 4; // 4 kolom
        final gap = 10.0;
        final cellW = (c.maxWidth - gap * (cross - 1)) / cross;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: keys.map((k) {
            final w = (cellW * (k.flex ?? 1)) + gap * ((k.flex ?? 1) - 1);
            return SizedBox(
              width: w,
              height: 64,
              child: _KeyButton(
                label: k.label,
                type: k.type,
                onTap: () => onTap(k.label),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

enum KeyType { num, op, func, equals }

class _KeyDef {
  final String label;
  final KeyType type;
  final int? flex;
  _KeyDef(this.label, {KeyType? type, this.flex})
    : type =
          type ??
          (RegExp(r'^\d$').hasMatch(label) || label == '.'
              ? KeyType.num
              : KeyType.func);
}

class _KeyButton extends StatelessWidget {
  const _KeyButton({
    required this.label,
    required this.type,
    required this.onTap,
  });

  final String label;
  final KeyType type;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Color bg;
    Color fg;
    switch (type) {
      case KeyType.equals:
        bg = cs.primary;
        fg = Colors.white;
        break;
      case KeyType.op:
        bg = cs.primary.withValues(alpha: .12);
        fg = cs.primary;
        break;
      case KeyType.func:
        bg = cs.surfaceContainerHigh;
        fg = cs.onSurface;
        break;
      case KeyType.num:
        bg = cs.surfaceContainerHighest;
        fg = cs.onSurface;
        break;
    }

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ).copyWith(color: fg),
          ),
        ),
      ),
    );
  }
}

class _HistoryItem {
  final String expr;
  final String result;
  _HistoryItem({required this.expr, required this.result});
}
