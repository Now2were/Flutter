import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F5FA),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F5FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top),
            const ProfileFull(),
            Container(height: 14, color: const Color(0xFFF6F5FA)),
            const CatalogFull(),
            Container(height: 14, color: const Color(0xFFF6F5FA)),
            const FinanceFull(),
            Container(height: 14, color: const Color(0xFFF6F5FA)),
            const TravelFull(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class ProfileFull extends StatelessWidget {
  const ProfileFull({super.key});
  void _msg(BuildContext c, String t) {
    ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(t), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 1)));
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Stack(
            children: [
              SizedBox(
                height: 180,
                width: double.infinity,
                child: Image.network('https://images.unsplash.com/photo-1519681393784-d120267933ba?w=800', fit: BoxFit.cover),
              ),
              Container(
                height: 180,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.black.withOpacity(0.35), Colors.transparent], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                ),
              ),
              Positioned(
                top: 14, left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.92), borderRadius: BorderRadius.circular(20)),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.verified, size: 14, color: Color(0xFF6750A4)), SizedBox(width: 6), Text('PRO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF6750A4)))]),
                ),
              ),
              Positioned(
                top: 14, right: 16,
                child: Row(children: [
                  GestureDetector(onTap: () => _msg(context, 'Меню'), child: _iconBtn(Icons.more_horiz)),
                  const SizedBox(width: 8),
                  GestureDetector(onTap: () => _msg(context, 'Уведомления'), child: _iconBtn(Icons.notifications_none)),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _msg(context, 'Аватар Анны Морозовой'),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 16, offset: const Offset(0, 6))]),
              child: const CircleAvatar(radius: 48, backgroundImage: NetworkImage('https://i.pravatar.cc/300?img=32')),
            ),
          ),
          const SizedBox(height: 10),
          const Text('Анна Морозова', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.location_on, size: 14, color: Color(0xFF6750A4)), SizedBox(width: 4),
            Text('Москва • UI/UX Designer', style: TextStyle(fontSize: 13, color: Color(0xFF7A7289))),
            SizedBox(width: 8), Icon(Icons.circle, size: 6, color: Color(0xFF00C853)), SizedBox(width: 4),
            Text('Online', style: TextStyle(fontSize: 12, color: Color(0xFF00C853), fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(children: [
              _stat('342', 'Проекта'), Container(width: 1, height: 36, color: const Color(0xFFEDE8F7)),
              _stat('12.8k', 'Подписчиков'), Container(width: 1, height: 36, color: const Color(0xFFEDE8F7)),
              _stat('4.9', 'Рейтинг'),
            ]),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              Expanded(child: ElevatedButton(onPressed: () => _msg(context, 'Сообщение Анне'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6750A4), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0), child: const Text('Сообщение', style: TextStyle(fontWeight: FontWeight.w800)))),
              const SizedBox(width: 12),
              Expanded(child: OutlinedButton(onPressed: () => _msg(context, 'Открыт профиль Анны'), style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF6750A4), side: BorderSide(color: Color(0xFFE8DEF8)), padding: EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: const Text('Профиль', style: TextStyle(fontWeight: FontWeight.w700)))),
            ]),
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }
  static Widget _iconBtn(IconData i) => Container(width: 36, height: 36, decoration: BoxDecoration(color: Colors.black.withOpacity(0.28), shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.2))), child: Icon(i, size: 18, color: Colors.white));
  static Widget _stat(String v, String l) => Expanded(child: Column(children: [Text(v, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)), Text(l, style: const TextStyle(fontSize: 11, color: Color(0xFF8E8A9A)))]));
}

class CatalogFull extends StatelessWidget {
  const CatalogFull({super.key});
  void _msg(BuildContext c, String t) => ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(t), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 1)));
  @override
  Widget build(BuildContext context) {
    final products = [
      _P('Кроссовки Air', 'Nike • 4.8 ★', '9 990 ₽', '12 990 ₽', 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400'),
      _P('Наушники Max', 'Apple • 4.9 ★', '29 990 ₽', '32 990 ₽', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400'),
      _P('Часы Series 9', 'Apple • 4.7 ★', '39 990 ₽', '41 990 ₽', 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400'),
      _P('Рюкзак City', 'Xiaomi • 4.6 ★', '3 490 ₽', '4 990 ₽', 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400'),
    ];
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(children: [
              Expanded(child: GestureDetector(onTap: () => _msg(context, 'Поиск'), child: Container(height: 46, decoration: BoxDecoration(color: const Color(0xFFF3F0FF), borderRadius: BorderRadius.circular(14)), padding: const EdgeInsets.symmetric(horizontal: 14), child: const Row(children: [Icon(Icons.search, size: 20, color: Color(0xFF6750A4)), SizedBox(width: 8), Text('Поиск товаров...', style: TextStyle(color: Color(0xFF9A93AD))) ])))),
              const SizedBox(width: 10),
              GestureDetector(onTap: () => _msg(context, 'Фильтры'), child: Container(width: 46, height: 46, decoration: BoxDecoration(color: const Color(0xFF6750A4), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.tune, color: Colors.white))),
            ]),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              _catChip(context, 'Все', true), _catChip(context, 'Обувь', false), _catChip(context, 'Электроника', false), _catChip(context, 'Аксессуары', false), _catChip(context, 'Sale %', false),
            ]),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF0ECFA)),
          Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.82, crossAxisSpacing: 12, mainAxisSpacing: 12),
              itemCount: products.length,
              itemBuilder: (_, i) {
                final p = products[i];
                return Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFF0ECFA))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(children: [
                        ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(18)), child: Image.network(p.img, height: 110, width: double.infinity, fit: BoxFit.cover)),                        Positioned(top: 8, right: 8, child: GestureDetector(onTap: () => _msg(context, 'В избранное'), child: Container(width: 30, height: 30, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.favorite_border, size: 16, color: Color(0xFF6750A4))))),
                      ]),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text(p.sub, style: const TextStyle(fontSize: 11, color: Color(0xFF8E8A9A))),
                            const SizedBox(height: 6),
                            Row(children: [Text(p.price, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF6750A4))), const SizedBox(width: 6), Text(p.old, style: const TextStyle(fontSize: 11, color: Color(0xFFB0A9C6), decoration: TextDecoration.lineThrough))]),
                            const SizedBox(height: 8),
                            SizedBox(width: double.infinity, height: 32, child: ElevatedButton(onPressed: () => _msg(context, '${p.title} — добавлен в корзину'), style: ButtonStyle(backgroundColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.hovered) ? const Color(0xFF333333) : const Color(0xFF1A1A1A)), foregroundColor: WidgetStateProperty.all(Colors.white), shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), elevation: WidgetStateProperty.all(0)), child: const Text('В корзину', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)))),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  static Widget _catChip(BuildContext c, String t, bool s) => MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text('Категория: $t'), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 1))),
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(color: s ? const Color(0xFF6750A4) : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: s ? const Color(0xFF6750A4) : const Color(0xFFE8DEF8))),
            child: Text(t, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: s ? Colors.white : const Color(0xFF6750A4))),
          ),
        ),
      );
}

class _P {
  final String title, sub, price, old, img;
  _P(this.title, this.sub, this.price, this.old, this.img);
}

class FinanceFull extends StatelessWidget {
  const FinanceFull({super.key});
  void _msg(BuildContext c, String t) => ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(t), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 1)));
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            color: const Color(0xFF1A1A1A),
            child: Column(
              children: [
                Row(children: [
                  const CircleAvatar(radius: 18, backgroundImage: NetworkImage('https://i.pravatar.cc/300?img=15')),
                  const SizedBox(width: 10),
                  const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Доброе утро, Алексей 👋', style: TextStyle(color: Colors.white70, fontSize: 12)), Text('Мой кошелек', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800))])),
                  GestureDetector(onTap: () => _msg(context, 'Уведомления'), child: _top(Icons.notifications_none)),
                  const SizedBox(width: 8),
                  GestureDetector(onTap: () => _msg(context, 'Меню'), child: _top(Icons.more_horiz)),
                ]),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF6750A4), Color(0xFF7B6CF6), Color(0xFF9C8CFF)]), borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text('Общий баланс', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)), child: const Row(children: [Icon(Icons.trending_up, size: 14, color: Colors.white), SizedBox(width: 4), Text('+12.5%', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))])),
                      ]),
                      const SizedBox(height: 8),
                      const Text('₽ 284 950.00', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(child: GestureDetector(onTap: () => _msg(context, 'Пополнить'), child: const _BalanceBtn(Icons.add, 'Пополнить'))),
                        const SizedBox(width: 10),
                        Expanded(child: GestureDetector(onTap: () => _msg(context, 'Перевод'), child: const _BalanceBtn(Icons.swap_horiz, 'Перевод'))),
                        const SizedBox(width: 10),
                        Expanded(child: GestureDetector(onTap: () => _msg(context, 'QR код'), child: const _BalanceBtn(Icons.qr_code, 'QR'))),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 84,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              children: [
                GestureDetector(onTap: () => _msg(context, 'Tinkoff Black'), child: _mini('Tinkoff Black', '• 4589', '₽ 84 200', const Color(0xFFFFE082), Icons.credit_card)),
                GestureDetector(onTap: () => _msg(context, 'Sber Prime'), child: _mini('Sber Prime', '• 1023', '₽ 152 400', const Color(0xFFA5D6A7), Icons.account_balance)),
                GestureDetector(onTap: () => _msg(context, 'Альфа'), child: _mini('Альфа', '• 7734', '₽ 48 350', const Color(0xFFFFAB91), Icons.wallet)),
                GestureDetector(onTap: () => _msg(context, 'ВТБ'), child: _mini('ВТБ', '• 9912', '\$ 1 240', const Color(0xFF90CAF9), Icons.payments)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Расходы', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  GestureDetector(onTap: () => _msg(context, 'Выбор периода'), child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFF3F0FF), borderRadius: BorderRadius.circular(20)), child: const Row(children: [Text('Неделя', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF6750A4))), Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF6750A4))]))),
                ]),
                const SizedBox(height: 12),
                GestureDetector(onTap: () => _msg(context, 'График'), child: Container(height: 110, padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFF8F7FC), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFEFEBF9))), child: CustomPaint(size: const Size(double.infinity, 90), painter: _ChartPainter()))),
                const SizedBox(height: 6),
                const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Пн', style: TextStyle(fontSize: 11, color: Color(0xFF9A93AD))), Text('Вт', style: TextStyle(fontSize: 11, color: Color(0xFF9A93AD))), Text('Ср', style: TextStyle(fontSize: 11, color: Color(0xFF9A93AD))), Text('Чт', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF6750A4))), Text('Пт', style: TextStyle(fontSize: 11, color: Color(0xFF9A93AD))), Text('Сб', style: TextStyle(fontSize: 11, color: Color(0xFF9A93AD))), Text('Вс', style: TextStyle(fontSize: 11, color: Color(0xFF9A93AD)))]),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Последние операции', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)), GestureDetector(onTap: () => _msg(context, 'Все операции'), child: const Text('Все', style: TextStyle(color: Color(0xFF6750A4), fontWeight: FontWeight.w700)))]),
                const SizedBox(height: 12),
                GestureDetector(onTap: () => _msg(context, 'Wildberries'), child: _txn(Icons.shopping_bag, const Color(0xFFFFE0B2), 'Wildberries', 'Сегодня • 14:32', '- 2 450 ₽', false)),
                GestureDetector(onTap: () => _msg(context, 'Вкусно и точка'), child: _txn(Icons.restaurant, const Color(0xFFC8E6C9), 'Вкусно и точка', 'Вчера • 19:12', '- 890 ₽', false)),
                GestureDetector(onTap: () => _msg(context, 'Перевод от мамы'), child: _txn(Icons.arrow_downward, const Color(0xFFE1BEE7), 'Перевод от мамы', 'Вчера • 11:20', '+ 15 000 ₽', true)),
                GestureDetector(onTap: () => _msg(context, 'Яндекс Go'), child: _txn(Icons.directions_car, const Color(0xFFBBDEFB), 'Яндекс Go', '12 сен • 08:45', '- 560 ₽', false)),
              ],
            ),
          ),
        ],
      ),
    );
  }
  static Widget _top(IconData i) => Container(width: 36, height: 36, decoration: BoxDecoration(color: Colors.white.withOpacity(0.14), borderRadius: BorderRadius.circular(10)), child: Icon(i, color: Colors.white, size: 18));
  static Widget _mini(String n, String num, String sum, Color c, IconData ic) => Container(width: 150, margin: const EdgeInsets.only(right: 10), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF8F7FC), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFEFEBF9))), child: Row(children: [Container(width: 36, height: 36, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(10)), child: Icon(ic, size: 18)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(n, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis), Text(num, style: const TextStyle(fontSize: 10, color: Color(0xFF9A93AD))), Text(sum, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900))]))]));
  static Widget _txn(IconData ic, Color bg, String t, String s, String a, bool inc) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [Container(width: 42, height: 42, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)), child: Icon(ic, size: 20)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)), Text(s, style: const TextStyle(fontSize: 11, color: Color(0xFF9A93AD)))])), Text(a, style: TextStyle(fontWeight: FontWeight.w900, color: inc ? const Color(0xFF00C853) : const Color(0xFF1A1A1A)))]));
}

class _BalanceBtn extends StatelessWidget {
  final IconData icon; final String label; const _BalanceBtn(this.icon, this.label);
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(12)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 16, color: Colors.white), const SizedBox(width: 6), Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700))]));
}

class _ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gp = Paint()..color = const Color(0xFFEDE8F7)..strokeWidth = 1 ..style = PaintingStyle.stroke;
    for (int i = 1; i <= 3; i++) { final y = size.height * i / 4; canvas.drawLine(Offset(0, y), Offset(size.width, y), gp); }
    final pts = [0.7, 0.4, 0.65, 0.35, 0.5, 0.85, 0.6];
    final step = size.width / (pts.length - 1);
    final p = Path(); final f = Path();
    for (int i = 0; i < pts.length; i++) { final x = i * step; final y = size.height * pts[i]; if (i == 0) { p.moveTo(x, y); f.moveTo(x, y); } else { final px = (i - 1) * step; final py = size.height * pts[i - 1]; final cx = (px + x) / 2; p.cubicTo(cx, py, cx, y, x, y); f.cubicTo(cx, py, cx, y, x, y); } }
    f.lineTo(size.width, size.height); f.lineTo(0, size.height); f.close();
    final fp = Paint()..shader = const LinearGradient(colors: [Color(0x336750A4), Color(0x006750A4)], begin: Alignment.topCenter, end: Alignment.bottomCenter).createShader(Rect.fromLTWH(0, 0, size.width, size.height)) ..style = PaintingStyle.fill;
    canvas.drawPath(f, fp);
    final lp = Paint()..color = const Color(0xFF6750A4)..strokeWidth = 3 ..style = PaintingStyle.stroke ..strokeCap = StrokeCap.round ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(p, lp);
    for (int i = 0; i < pts.length; i++) { final x = i * step; final y = size.height * pts[i]; final sel = i == 3; canvas.drawCircle(Offset(x, y), sel ? 6 : 4, Paint()..color = Colors.white); canvas.drawCircle(Offset(x, y), sel ? 6 : 4, Paint()..color = const Color(0xFF6750A4)..style = PaintingStyle.stroke..strokeWidth = 2); if (sel) { const t = '₽ 4 250'; final tp = TextPainter(text: const TextSpan(text: t, style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)), textDirection: TextDirection.ltr)..layout(); final r = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(x, y - 20), width: tp.width + 16, height: 20), const Radius.circular(8)); canvas.drawRRect(r, Paint()..color = const Color(0xFF1A1A1A)); tp.paint(canvas, Offset(x - tp.width / 2, y - 28)); } }
  }
  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}

class TravelFull extends StatelessWidget {
  const TravelFull({super.key});
  void _msg(BuildContext c, String t) => ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(t), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 1)));
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Stack(children: [
            SizedBox(height: 280, width: double.infinity, child: Image.network('https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800', fit: BoxFit.cover)),
            Container(height: 280, decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, Colors.black.withOpacity(0.55)], begin: Alignment.topCenter, end: Alignment.bottomCenter))),
            Positioned(top: 14, left: 14, right: 14, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [GestureDetector(onTap: () => _msg(context, 'Назад'), child: _glass(Icons.arrow_back)), Row(children: [GestureDetector(onTap: () => _msg(context, 'В избранное'), child: _glass(Icons.favorite_border)), const SizedBox(width: 8), GestureDetector(onTap: () => _msg(context, 'Поделиться'), child: _glass(Icons.share_outlined))])])),
            Positioned(bottom: 14, left: 14, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.star, size: 14, color: Color(0xFFFFB300)), SizedBox(width: 4), Text('4.9', style: TextStyle(fontWeight: FontWeight.w800)), SizedBox(width: 4), Text('• 2.4k отзывов', style: TextStyle(fontSize: 11, color: Color(0xFF6B6B6B)))])), const SizedBox(height: 8), const Text('Озеро Брайес', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)), const Row(children: [Icon(Icons.location_on, size: 14, color: Colors.white70), SizedBox(width: 4), Text('Доломиты, Италия • 1 496 м', style: TextStyle(color: Colors.white70, fontSize: 12))])])),
            Positioned(bottom: 14, right: 14, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)), child: const Column(children: [Text('от', style: TextStyle(fontSize: 10, color: Color(0xFF8E8A9A))), Text('₽ 18 500', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1A73E8))), Text('/ ночь', style: TextStyle(fontSize: 10, color: Color(0xFF8E8A9A)))]))),
          ]),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('О месте', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                const SizedBox(height: 6),
                GestureDetector(onTap: () => _msg(context, 'Читать далее'), child: RichText(text: const TextSpan(style: TextStyle(fontSize: 13, color: Color(0xFF6B6B6B), height: 1.5), children: [TextSpan(text: 'Изумрудное озеро в окружении величественных Доломитовых Альп. Идеально для хайкинга, фотосессий и уединения с природой. '), TextSpan(text: 'Читать далее', style: TextStyle(color: Color(0xFF1A73E8), fontWeight: FontWeight.w700))]))),
                const SizedBox(height: 14),
                SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [GestureDetector(onTap: () => _msg(context, 'Хайкинг'), child: _feat(Icons.hiking, 'Хайкинг', '12 маршрутов')), GestureDetector(onTap: () => _msg(context, 'Лодки'), child: _feat(Icons.directions_boat, 'Лодки', 'Аренда')), GestureDetector(onTap: () => _msg(context, 'Кафе'), child: _feat(Icons.restaurant, 'Кафе', '3 рядом')), GestureDetector(onTap: () => _msg(context, 'Wi-Fi'), child: _feat(Icons.wifi, 'Wi-Fi', 'Есть'))])),
                const SizedBox(height: 16),
                const Text('Галерея', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                const SizedBox(height: 10),
                SizedBox(height: 84, child: ListView(scrollDirection: Axis.horizontal, children: [GestureDetector(onTap: () => _msg(context, 'Фото 1'), child: _g('https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=300')), GestureDetector(onTap: () => _msg(context, 'Фото 2'), child: _g('https://images.unsplash.com/photo-1439066615861-d1af74d74000?w=300')), GestureDetector(onTap: () => _msg(context, 'Фото 3'), child: _g('https://images.unsplash.com/photo-1470770841072-f978cf4d019e?w=300')), GestureDetector(onTap: () => _msg(context, 'Фото 4'), child: _g('https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=300'))])),
                const SizedBox(height: 16),
                const Text('Удобства', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                const SizedBox(height: 10),
                Wrap(spacing: 8, runSpacing: 8, children: [GestureDetector(onTap: () => _msg(context, 'Завтрак'), child: _am(Icons.free_breakfast, 'Завтрак')), GestureDetector(onTap: () => _msg(context, 'Бассейн'), child: _am(Icons.pool, 'Бассейн')), GestureDetector(onTap: () => _msg(context, 'Спа'), child: _am(Icons.spa, 'Спа')), GestureDetector(onTap: () => _msg(context, 'Pet-friendly'), child: _am(Icons.pets, 'Pet-friendly')), GestureDetector(onTap: () => _msg(context, 'Парковка'), child: _am(Icons.local_parking, 'Парковка')), GestureDetector(onTap: () => _msg(context, 'Кондиционер'), child: _am(Icons.ac_unit, 'Кондиционер'))]),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => _msg(context, 'Профиль Марко'),
                  child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF8F7FC), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFEFEBF9))), child: Row(children: [const CircleAvatar(radius: 20, backgroundImage: NetworkImage('https://i.pravatar.cc/300?img=11')), const SizedBox(width: 10), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Хозяин — Марко', style: TextStyle(fontWeight: FontWeight.w800)), Text('Суперхозяин • 5 лет на сервисе', style: TextStyle(fontSize: 11, color: Color(0xFF8E8A9A)))])), GestureDetector(onTap: () => _msg(context, 'Написать Марко'), child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE8DEF8))), child: const Row(children: [Icon(Icons.chat_bubble_outline, size: 14, color: Color(0xFF6750A4)), SizedBox(width: 6), Text('Написать', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF6750A4)))])))])),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          Container(padding: const EdgeInsets.fromLTRB(16, 12, 16, 16), decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFEFEBF9)))), child: Row(children: [const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Итого за 3 ночи', style: TextStyle(fontSize: 11, color: Color(0xFF9A93AD))), Row(children: [Text('₽ 55 500', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)), SizedBox(width: 6), Text('₽ 62 000', style: TextStyle(fontSize: 12, color: Color(0xFFB0A9C6), decoration: TextDecoration.lineThrough))])]), Spacer(), ElevatedButton(onPressed: () => _msg(context, 'Бронирование оформлено!'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A73E8), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0), child: const Text('Забронировать', style: TextStyle(fontWeight: FontWeight.w800)))])),
        ],
      ),
    );
  }
  static Widget _glass(IconData i) => Container(width: 36, height: 36, decoration: BoxDecoration(color: Colors.black.withOpacity(0.35), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white.withOpacity(0.2))), child: Icon(i, color: Colors.white, size: 18));
  static Widget _feat(IconData ic, String t, String s) => Container(width: 86, margin: const EdgeInsets.only(right: 10), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFF8F7FC), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFEFEBF9))), child: Column(children: [Container(width: 36, height: 36, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)), child: Icon(ic, size: 18, color: const Color(0xFF6750A4))), const SizedBox(height: 6), Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)), Text(s, style: const TextStyle(fontSize: 10, color: Color(0xFF9A93AD))) ]));
  static Widget _g(String u) => Container(width: 84, height: 84, margin: const EdgeInsets.only(right: 8), decoration: BoxDecoration(borderRadius: BorderRadius.circular(14)), clipBehavior: Clip.antiAlias, child: Image.network(u, fit: BoxFit.cover));
  static Widget _am(IconData ic, String t) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE8DEF8))), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(ic, size: 14, color: const Color(0xFF6750A4)), const SizedBox(width: 6), Text(t, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))]));
}
