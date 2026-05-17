import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const RandomDeciderApp());
}

class RandomDeciderApp extends StatelessWidget {
  const RandomDeciderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '随机决策器',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final _diceKey = GlobalKey<DiceTabState>();
  final _spinnerKey = GlobalKey<SpinnerTabState>();
  final _drawLotsKey = GlobalKey<DrawLotsTabState>();
  final _coinFlipKey = GlobalKey<CoinFlipTabState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎲 随机决策器'),
        centerTitle: true,
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 2,
        bottom: TabBar(
          controller: _tabController,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorColor: colorScheme.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          tabs: const [
            Tab(icon: Icon(Icons.casino), text: '骰子'),
            Tab(icon: Icon(Icons.pie_chart), text: '转盘'),
            Tab(icon: Icon(Icons.content_paste), text: '抽签'),
            Tab(icon: Icon(Icons.all_inclusive), text: '抛硬币'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          DiceTab(key: _diceKey),
          SpinnerTab(key: _spinnerKey),
          DrawLotsTab(key: _drawLotsKey),
          CoinFlipTab(key: _coinFlipKey),
        ],
      ),
    );
  }
}

// =========================== DICE TAB ===========================

class DiceTab extends StatefulWidget {
  const DiceTab({super.key});

  @override
  State<DiceTab> createState() => DiceTabState();
}

class DiceTabState extends State<DiceTab> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _rotationAnimation;
  late final Animation<double> _scaleAnimation;

  int _diceCount = 1;
  List<int> _results = [1];
  bool _rolling = false;

  final Random _random = Random();

  static const List<List<Offset>> _dotPositions = [
    [Offset(0.5, 0.5)],
    [Offset(0.2, 0.2), Offset(0.8, 0.8)],
    [Offset(0.2, 0.2), Offset(0.5, 0.5), Offset(0.8, 0.8)],
    [Offset(0.2, 0.2), Offset(0.2, 0.8), Offset(0.8, 0.2), Offset(0.8, 0.8)],
    [Offset(0.2, 0.2), Offset(0.2, 0.8), Offset(0.5, 0.5), Offset(0.8, 0.2), Offset(0.8, 0.8)],
    [Offset(0.2, 0.2), Offset(0.2, 0.5), Offset(0.2, 0.8), Offset(0.8, 0.2), Offset(0.8, 0.5), Offset(0.8, 0.8)],
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 0.7), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.7, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void rollDice() {
    if (_rolling) return;
    setState(() {
      _rolling = true;
    });
    _controller.reset();
    _controller.forward().then((_) {
      setState(() {
        _results = List.generate(_diceCount, (_) => _random.nextInt(6) + 1);
        _rolling = false;
      });
    });

    final fastTimer = Stopwatch()..start();
    void changeFast() {
      if (fastTimer.elapsedMilliseconds < 400) {
        setState(() {
          _results = List.generate(_diceCount, (_) => _random.nextInt(6) + 1);
        });
        Future.delayed(const Duration(milliseconds: 50), changeFast);
      }
    }
    changeFast();
  }

  Color _diceColor(int value) {
    const colors = [
      Color(0xFFFF6B6B),
      Color(0xFFFFB347),
      Color(0xFF4ECDC4),
      Color(0xFF45B7D1),
      Color(0xFFA78BFA),
      Color(0xFFF472B6),
    ];
    return colors[value - 1];
  }

  Widget _buildDiceFace(int value, int index) {
    final color = _diceColor(value);
    final dots = _dotPositions[value - 1];

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 70,
              height: 70,
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: color.withAlpha(150),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: dots.map((dot) {
                  return Positioned(
                    left: dot.dx * 70 - 8,
                    top: dot.dy * 70 - 8,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.primaryContainer.withAlpha(80), colorScheme.surface],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('选择骰子数量', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (i) {
              final count = i + 1;
              final selected = _diceCount == count;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: _rolling ? null : () => setState(() => _diceCount = count),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: selected ? colorScheme.primary : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? colorScheme.primary : colorScheme.outline.withAlpha(80),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: selected ? colorScheme.onPrimary : colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 30),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_diceCount, (i) {
              return _buildDiceFace(i < _results.length ? _results[i] : 1, i);
            }),
          ),
          const SizedBox(height: 30),
          if (!_rolling && _results.length == _diceCount)
            Text(
              '结果: ${_results.join(" , ")}',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colorScheme.primary),
            ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _rolling ? null : rollDice,
            icon: const Icon(Icons.casino),
            label: const Text('掷骰子', style: TextStyle(fontSize: 18)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }
}

// =========================== SPINNER TAB ===========================

class SpinnerTab extends StatefulWidget {
  const SpinnerTab({super.key});

  @override
  State<SpinnerTab> createState() => SpinnerTabState();
}

class SpinnerTabState extends State<SpinnerTab> with SingleTickerProviderStateMixin {
  late final AnimationController _spinController;
  final TextEditingController _inputController = TextEditingController();
  final List<String> _options = ['选项A', '选项B', '选项C', '选项D'];
  String _result = '';
  double _rotation = 0;
  double _spinTarget = 0;
  bool _spinning = false;

  static const List<Color> _segmentColors = [
    Color(0xFFFF6B6B),
    Color(0xFFFFB347),
    Color(0xFF4ECDC4),
    Color(0xFF45B7D1),
    Color(0xFFA78BFA),
    Color(0xFFF472B6),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
  ];

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _spinController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  void addOption() {
    final text = _inputController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _options.add(text);
        _inputController.clear();
      });
    }
  }

  void removeOption(int index) {
    setState(() {
      _options.removeAt(index);
    });
  }

  void spinWheel() {
    if (_spinning || _options.isEmpty) return;
    setState(() {
      _spinning = true;
      _result = '';
    });

    final random = Random();
    final extraSpins = 4 + random.nextInt(4);
    final targetAngle = random.nextDouble() * 2 * pi;
    _spinTarget = _rotation + extraSpins * 2 * pi + targetAngle;

    _spinController.reset();
    _spinController.forward().then((_) {
      setState(() {
        _rotation = _spinTarget;

        final segmentAngle = 2 * pi / _options.length;
        final normalizedAngle = (_spinTarget % (2 * pi));
        final pointedIndex = _options.length - 1 - ((normalizedAngle / segmentAngle).floor() % _options.length);
        _result = _options[pointedIndex];
        _spinning = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.secondaryContainer.withAlpha(80), colorScheme.surface],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    controller: _inputController,
                    decoration: InputDecoration(
                      hintText: '输入选项...',
                      suffixIcon: IconButton(icon: const Icon(Icons.add_circle), onPressed: addOption),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      isDense: true,
                    ),
                    onSubmitted: (_) => addOption(),
                  ),
                ),
              ),
            ],
          ),
          if (_options.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: List.generate(_options.length, (i) {
                  return Chip(
                    label: Text(_options[i], style: const TextStyle(fontSize: 13)),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => removeOption(i),
                    backgroundColor: _segmentColors[i % _segmentColors.length].withAlpha(40),
                    side: BorderSide(color: _segmentColors[i % _segmentColors.length].withAlpha(100)),
                  );
                }),
              ),
            ),
          const SizedBox(height: 10),
          Expanded(
            child: Center(
              child: AnimatedBuilder(
                animation: _spinController,
                builder: (context, child) {
                  final currentRotation = _spinning
                      ? _rotation + (_spinTarget - _rotation) * Curves.easeInOutCubic.transform(_spinController.value)
                      : _rotation;
                  return Transform.rotate(
                    angle: currentRotation,
                    child: CustomPaint(
                      size: const Size(260, 260),
                      painter: _SpinnerPainter(
                        options: _options,
                        colors: _segmentColors,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (_result.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '🎯 结果: $_result',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colorScheme.primary),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ElevatedButton.icon(
              onPressed: _spinning ? null : spinWheel,
              icon: const Icon(Icons.refresh),
              label: const Text('转一转', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  final List<String> options;
  final List<Color> colors;

  _SpinnerPainter({required this.options, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 4;

    if (options.isEmpty) {
      final paint = Paint()
        ..color = Colors.grey.shade300
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius, paint);
      final textPainter = TextPainter(
        text: const TextSpan(text: '请添加选项', style: TextStyle(color: Colors.grey, fontSize: 16)),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, center - Offset(textPainter.width / 2, textPainter.height / 2));
      return;
    }

    final segmentAngle = 2 * pi / options.length;

    for (int i = 0; i < options.length; i++) {
      final startAngle = i * segmentAngle - pi / 2;
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        segmentAngle,
        true,
        paint,
      );

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        segmentAngle,
        true,
        Paint()
          ..color = Colors.white.withAlpha(60)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      final textAngle = startAngle + segmentAngle / 2;
      final textRadius = radius * 0.62;
      final textOffset = Offset(
        center.dx + textRadius * cos(textAngle),
        center.dy + textRadius * sin(textAngle),
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: options[i].length > 6 ? '${options[i].substring(0, 6)}...' : options[i],
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, textOffset - Offset(textPainter.width / 2, textPainter.height / 2));
    }

    canvas.drawCircle(center, radius * 0.2, Paint()..color = Colors.white);
    canvas.drawCircle(center, radius * 0.15, Paint()..color = Colors.deepPurple);

    final pointer = Paint()
      ..color = Colors.amber.shade700
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(center.dx, center.dy - radius - 8)
      ..lineTo(center.dx - 12, center.dy - radius + 14)
      ..lineTo(center.dx + 12, center.dy - radius + 14)
      ..close();
    canvas.drawPath(path, pointer);
  }

  @override
  bool shouldRepaint(covariant _SpinnerPainter oldDelegate) {
    return oldDelegate.options != options;
  }
}

// =========================== DRAW LOTS TAB ===========================

class DrawLotsTab extends StatefulWidget {
  const DrawLotsTab({super.key});

  @override
  State<DrawLotsTab> createState() => DrawLotsTabState();
}

class DrawLotsTabState extends State<DrawLotsTab> with SingleTickerProviderStateMixin {
  late final AnimationController _drawController;
  final TextEditingController _inputController = TextEditingController();
  final List<String> _options = [];
  String _result = '';
  bool _drawing = false;

  @override
  void initState() {
    super.initState();
    _drawController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _drawController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  void addOption() {
    final text = _inputController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _options.add(text);
        _inputController.clear();
      });
    }
  }

  void removeOption(int index) {
    setState(() {
      _options.removeAt(index);
      if (_result.isNotEmpty && _options.isEmpty) {
        _result = '';
      }
    });
  }

  void drawOne() {
    if (_drawing || _options.isEmpty) return;
    setState(() {
      _drawing = true;
      _result = '';
    });

    final random = Random();
    final stopwatch = Stopwatch()..start();

    void flash() {
      if (stopwatch.elapsedMilliseconds < 800) {
        setState(() {});
        Future.delayed(const Duration(milliseconds: 60), flash);
      } else {
        setState(() {
          _result = _options[random.nextInt(_options.length)];
          _drawing = false;
        });
      }
    }

    _drawController.reset();
    _drawController.forward();
    flash();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.tertiaryContainer.withAlpha(80), colorScheme.surface],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    controller: _inputController,
                    decoration: InputDecoration(
                      hintText: '输入选项，如：看电影、吃火锅...',
                      suffixIcon: IconButton(icon: const Icon(Icons.add_circle), onPressed: addOption),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      isDense: true,
                    ),
                    onSubmitted: (_) => addOption(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _options.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.content_paste, size: 64, color: colorScheme.outline.withAlpha(100)),
                        const SizedBox(height: 12),
                        Text('添加选项后开始抽签', style: TextStyle(color: colorScheme.outline, fontSize: 16)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _options.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 3),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _drawing
                                ? Colors.orange.shade200
                                : colorScheme.primaryContainer,
                            child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          title: Text(_options[index]),
                          trailing: IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => removeOption(index),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (_result.isNotEmpty)
            AnimatedBuilder(
              animation: _drawController,
              builder: (context, child) {
                final scale = 0.5 + 0.5 * _drawController.value;
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 40),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFA78BFA), Color(0xFFF472B6)]),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.purple.withAlpha(80), blurRadius: 16, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Text(
                      '🎉 $_result',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ElevatedButton.icon(
              onPressed: (_drawing || _options.isEmpty) ? null : drawOne,
              icon: const Icon(Icons.shuffle),
              label: const Text('抽一个', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =========================== COIN FLIP TAB ===========================

class CoinFlipTab extends StatefulWidget {
  const CoinFlipTab({super.key});

  @override
  State<CoinFlipTab> createState() => CoinFlipTabState();
}

class CoinFlipTabState extends State<CoinFlipTab> with SingleTickerProviderStateMixin {
  late final AnimationController _flipController;
  late final Animation<double> _flipAnimation;

  bool _isHeads = true;
  bool _flipping = false;
  int _headsCount = 0;
  int _tailsCount = 0;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void flipCoin() {
    if (_flipping) return;
    setState(() {
      _flipping = true;
    });

    final isHeadsResult = _random.nextBool();

    _flipController.reset();
    _flipController.forward().then((_) {
      setState(() {
        _isHeads = isHeadsResult;
        if (_isHeads) {
          _headsCount++;
        } else {
          _tailsCount++;
        }
        _flipping = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.amber.shade50, Colors.amber.shade100],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('点击硬币翻转', style: TextStyle(fontSize: 16, color: Colors.black54)),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: flipCoin,
            child: AnimatedBuilder(
              animation: _flipAnimation,
              builder: (context, child) {
                final value = _flipAnimation.value;
                final isFront = value < 0.5;
                final transformValue = (value * pi).clamp(0.0, pi);

                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(transformValue),
                  child: isFront ? _buildCoinFace(true) : _buildCoinFace(false),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _flipping ? '翻转中...' : (_isHeads ? '✨ 正面 (字)' : '🌙 反面 (花)'),
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colorScheme.primary),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCounter('正面', _headsCount, const Color(0xFFFFB347)),
              const SizedBox(width: 40),
              _buildCounter('反面', _tailsCount, const Color(0xFF45B7D1)),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _flipping ? null : flipCoin,
            icon: const Icon(Icons.all_inclusive),
            label: const Text('抛硬币', style: TextStyle(fontSize: 18)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoinFace(bool isFront) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Color(0xFFFFD700), Color(0xFFB8860B)],
          stops: [0.3, 1.0],
        ),
        boxShadow: [
          BoxShadow(color: Colors.amber.withAlpha(100), blurRadius: 20, spreadRadius: 4),
        ],
        border: Border.all(color: Colors.amber.shade700, width: 3),
      ),
      child: Center(
        child: isFront
            ? const Text('字', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFF5D3A00)))
            : const Text('花', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF5D3A00))),
      ),
    );
  }

  Widget _buildCounter(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withAlpha(50),
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Text('$count', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
