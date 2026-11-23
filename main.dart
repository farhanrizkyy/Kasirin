import 'package:flutter/material.dart';

void main() => runApp(const KasirApp());

const gold = Color(0xFFD4AF37);
const bg = Color(0xFF0E0E10);
const panel = Color(0xFF1A1A1E);

String rp(int v) {
  final s = v.toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return 'Rp $b';
}

class Product {
  final String name, emoji, unit;
  final int retail, wholesale;
  int stock;
  Product(this.name, this.emoji, this.unit, this.retail, this.wholesale, this.stock);
}

class KasirApp extends StatelessWidget {
  const KasirApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Kasirin',
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: bg,
          colorScheme: const ColorScheme.dark(primary: gold, surface: panel),
        ),
        home: const KasirPage(),
      );
}

class KasirPage extends StatefulWidget {
  const KasirPage({super.key});
  @override
  State<KasirPage> createState() => _KasirPageState();
}

class _KasirPageState extends State<KasirPage> {
  final products = [
    Product('Indomie Goreng', '🍜', 'pcs', 3500, 3200, 120),
    Product('Beras 5 kg', '🌾', 'sak', 68000, 64000, 30),
    Product('Minyak Goreng 1L', '🛢️', 'btl', 17000, 15800, 45),
    Product('Gula Pasir 1 kg', '🍚', 'kg', 17500, 16500, 60),
    Product('Kopi Sachet', '☕', 'pcs', 1500, 1300, 200),
    Product('Telur', '🥚', 'kg', 29000, 27500, 25),
    Product('Teh Kotak', '🍵', 'pcs', 4000, 3500, 80),
    Product('Sabun Mandi', '🧼', 'pcs', 4500, 4000, 70),
  ];
  final cart = <Product, int>{};
  bool wholesale = false;
  String query = '';

  int price(Product p) => wholesale ? p.wholesale : p.retail;
  int get total => cart.entries.fold(0, (s, e) => s + price(e.key) * e.value);
  int get count => cart.values.fold(0, (s, q) => s + q);

  void add(Product p) {
    if ((cart[p] ?? 0) < p.stock) setState(() => cart[p] = (cart[p] ?? 0) + 1);
  }

  void remove(Product p) {
    setState(() {
      final q = (cart[p] ?? 0) - 1;
      q <= 0 ? cart.remove(p) : cart[p] = q;
    });
  }

  @override
  Widget build(BuildContext context) {
    final list = products
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(children: [
              ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.asset('assets/logo.png', width: 36, height: 36)),
              const SizedBox(width: 10),
              const Text('KASIRIN',
                  style: TextStyle(
                      color: gold, fontSize: 19, fontWeight: FontWeight.w800, letterSpacing: 2)),
              const Spacer(),
              SegmentedButton<bool>(
                showSelectedIcon: false,
                style: const ButtonStyle(visualDensity: VisualDensity.compact),
                segments: const [
                  ButtonSegment(value: false, label: Text('Eceran')),
                  ButtonSegment(value: true, label: Text('Grosir')),
                ],
                selected: {wholesale},
                onSelectionChanged: (s) => setState(() => wholesale = s.first),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              onChanged: (v) => setState(() => query = v),
              decoration: InputDecoration(
                hintText: 'Cari barang...',
                prefixIcon: const Icon(Icons.search, color: gold),
                filled: true,
                fillColor: panel,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 0.88),
              itemCount: list.length,
              itemBuilder: (_, i) => productCard(list[i]),
            ),
          ),
          if (count > 0) checkoutBar(),
        ]),
      ),
    );
  }

  Widget productCard(Product p) {
    final q = cart[p] ?? 0;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => add(p),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: panel,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: q > 0 ? gold : Colors.white10, width: q > 0 ? 1.5 : 1),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(p.emoji, style: const TextStyle(fontSize: 34)),
            const Spacer(),
            if (q > 0)
              CircleAvatar(
                  radius: 12,
                  backgroundColor: gold,
                  child: Text('$q',
                      style: const TextStyle(
                          color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold))),
          ]),
          const Spacer(),
          Text(p.name, maxLines: 2, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('${rp(price(p))} / ${p.unit}',
              style: const TextStyle(color: gold, fontWeight: FontWeight.w700)),
          Text('Stok ${p.stock}',
              style: TextStyle(color: p.stock < 30 ? Colors.orangeAccent : Colors.white38, fontSize: 12)),
        ]),
      ),
    );
  }

  Widget checkoutBar() => Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
        decoration: const BoxDecoration(
            color: panel,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: gold, width: 1))),
        child: Row(children: [
          Expanded(
            child: InkWell(
              onTap: openCart,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('$count barang  •  lihat keranjang',
                    style: const TextStyle(color: Colors.white54, fontSize: 12)),
                Text(rp(total),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: gold)),
              ]),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: gold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            onPressed: pay,
            child: const Text('BAYAR', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ]),
      );

  void openCart() {
    showModalBottomSheet(
      context: context,
      backgroundColor: panel,
      builder: (_) => StatefulBuilder(builder: (ctx, setS) {
        return ListView(padding: const EdgeInsets.all(20), children: [
          const Text('Keranjang', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          for (final e in cart.entries.toList())
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(e.key.name),
              subtitle: Text(rp(price(e.key) * e.value), style: const TextStyle(color: gold)),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () {
                      remove(e.key);
                      setS(() {});
                      if (cart.isEmpty) Navigator.pop(ctx);
                    }),
                Text('${e.value}'),
                IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: gold),
                    onPressed: () {
                      add(e.key);
                      setS(() {});
                    }),
              ]),
            ),
        ]);
      }),
    );
  }

  void pay() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (ctx, setS) {
        final cash = int.tryParse(ctrl.text) ?? 0;
        final change = cash - total;
        return AlertDialog(
          backgroundColor: panel,
          title: Text('Total ${rp(total)}', style: const TextStyle(color: gold)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              onChanged: (_) => setS(() {}),
              decoration: const InputDecoration(labelText: 'Uang diterima'),
            ),
            const SizedBox(height: 10),
            Wrap(spacing: 8, children: [
              for (final v in [total, 50000, 100000])
                ActionChip(
                    label: Text(v == total ? 'Uang pas' : rp(v)),
                    onPressed: () {
                      ctrl.text = '$v';
                      setS(() {});
                    }),
            ]),
            const SizedBox(height: 14),
            Text(change >= 0 ? 'Kembalian ${rp(change)}' : 'Kurang ${rp(-change)}',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: change >= 0 ? Colors.greenAccent : Colors.redAccent)),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: gold, foregroundColor: Colors.black),
              onPressed: change < 0
                  ? null
                  : () {
                      setState(() {
                        cart.forEach((p, q) => p.stock -= q);
                        cart.clear();
                      });
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text('Transaksi berhasil ✔')));
                    },
              child: const Text('Selesaikan'),
            ),
          ],
        );
      }),
    );
  }
}
