import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: CrepeApp(),
      ),
    );

class CrepeApp extends StatefulWidget {
  const CrepeApp({super.key});

  @override
  State<CrepeApp> createState() => _CrepeAppState();
}

class _CrepeAppState extends State<CrepeApp> {
  final foods = {
    '🍌 チョコバナナクレープ': 550,
    '🍓 いちごホイップクレープ': 600,
    '🍯 キャラメルクレープ': 500,
  };

  final toppingPrices = {
    '🍦 アイス': 150,
    '🍓 いちご': 150,
    '🍌 バナナ': 100,
    '🍫 チョコチップ': 80,
    '🥜 ナッツ': 80,
  };

  late String food = foods.keys.first;

  String sauce = 'なし';

  final toppings = <String>{};

  int sauceCount = 1;
  int order = 0;

  bool spoon = false;
  bool oshibori = false;

  String receipt = '';

  Widget choices(
    Iterable<String> items,
    String value,
    void Function(String) change,
  ) =>
      Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (final s in items)
            ChoiceChip(
              label: Text(s),
              selected: value == s,
              onSelected: (_) => setState(() => change(s)),
            ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    int toppingTotal = 0;

    for (final topping in toppings) {
      toppingTotal += toppingPrices[topping]!;
    }

    final subtotal = foods[food]! +
        toppingTotal +
        (sauce == 'なし' ? 0 : sauceCount * 50);

    final tax = subtotal ~/ 10;
    final total = subtotal + tax;

    final photo = SizedBox(
      width: 200,
      height: 150,
      child: Stack(
        children: [
          Center(
            child: Text(
              '🌯',
              style: const TextStyle(fontSize: 90),
            ),
          ),

          Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                sauce == 'なし'
                    ? ''
                    : List.filled(sauceCount, sauce).join(),
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),

          Positioned(
            top: 50,
            right: 20,
            child: SizedBox(
              width: 90,
              child: Text(
                toppings
                    .map((s) => s.split(' ').first)
                    .join(),
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
        ],
      ),
    );

    final products = choices(
      foods.keys.map((s) => '$s  ${foods[s]}円'),
      '$food  ${foods[food]}円',
      (s) => food =
          s.substring(0, s.lastIndexOf('  ')),
    );

    final toppingWidgets = Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final s in toppingPrices.keys)
          FilterChip(
            label:
                Text('$s +${toppingPrices[s]}円'),
            selected: toppings.contains(s),
            onSelected: (v) => setState(() {
              if (v) {
                toppings.add(s);
              } else {
                toppings.remove(s);
              }
            }),
          ),
      ],
    );

    final sauces = Column(
      children: [
        choices(
          ['なし', '🍫', '🟤', '🍯'],
          sauce,
          (s) => sauce = s,
        ),

        if (sauce != 'なし')
          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              const Text('ソース追加'),

              IconButton(
                onPressed: sauceCount > 1
                    ? () =>
                        setState(() => sauceCount--)
                    : null,
                icon: const Icon(Icons.remove),
              ),

              Text(
                '$sauceCount',
                style:
                    const TextStyle(fontSize: 22),
              ),

              IconButton(
                onPressed: sauceCount < 3
                    ? () =>
                        setState(() => sauceCount++)
                    : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
      ],
    );

    Widget supply(
      String label,
      bool value,
      void Function(bool) change,
    ) =>
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: value,
              onChanged: (v) => setState(
                () => change(v ?? false),
              ),
            ),
            Text(label),
          ],
        );

    final supplies = Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        supply(
          '🍴 スプーン（無料）',
          spoon,
          (v) => spoon = v,
        ),
        supply(
          '🧻 おしぼり（無料）',
          oshibori,
          (v) => oshibori = v,
        ),
      ],
    );

    final bill = Column(
      children: [
        Text(
          '税抜 $subtotal 円 / 消費税 $tax 円',
        ),
        Text(
          '合計 $total 円',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );

    final submit = Center(
      child: FilledButton(
        onPressed: () => setState(() {
          order =
              Random().nextInt(999) + 1;

          receipt =
              '$food  ${foods[food]}円\n'
              'トッピング: ${toppings.isEmpty ? 'なし' : toppings.join(' / ')}\n'
              '追加ソース: ${sauce == 'なし' ? 'なし' : '$sauce × $sauceCount'}\n'
              '🍴 スプーン: ${spoon ? 'あり' : 'なし'}\n'
              '🧻 おしぼり: ${oshibori ? 'あり' : 'なし'}\n'
              '税抜: $subtotal 円 / 消費税（10%）: $tax 円\n'
              '合計: $total 円';
        }),
        child: const Text('注文する'),
      ),
    );

    final ticket = order == 0
        ? const SizedBox.shrink()
        : Card(
            child: Padding(
              padding:
                  const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    '注文番号 #$order',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  Text(receipt),
                ],
              ),
            ),
          );

    return Scaffold(
      backgroundColor:
          const Color(0xFFFFF8F2),

      appBar: AppBar(
        centerTitle: true,
        backgroundColor:
            const Color(0xFFF4C7B8),
        title: const Text(
          '🍓 Crepe Stand',
        ),
      ),

      body: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: 520),

          child: ListView(
            padding:
                const EdgeInsets.all(16),

            children: [
              Center(child: photo),

              const Text(
                'クレープを選ぶ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              products,

              const SizedBox(height: 20),

              const Text(
                '追加トッピング',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              toppingWidgets,

              const SizedBox(height: 20),

              const Text(
                '追加ソース（1回50円）',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              sauces,

              const SizedBox(height: 20),

              const Text(
                '無料サービス',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              supplies,

              const Divider(),

              bill,

              const SizedBox(height: 16),

              submit,

              ticket,
            ],
          ),
        ),
      ),
    );
  }
}