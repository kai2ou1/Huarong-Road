import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const HuarongRoadApp());
}

class HuarongRoadApp extends StatelessWidget {
  const HuarongRoadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // 去掉右上角那个"Debug"红条
      title: '数字华容道',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const GamePage(),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  List<int> numbers = [];
  int moveCount = 0;
  bool isWon = false;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    numbers = List.generate(16, (index) => (index + 1) % 16);
    moveCount = 0;
    isWon = false;
    Random rng = Random();
    int emptyIndex = 15;
    int lastMove = -1;

    // 增加打乱次数到800，确保更随机
    for (int i = 0; i < 800; i++) {
      List<int> neighbors = _getNeighbors(emptyIndex);
      neighbors.remove(lastMove);
      if (neighbors.isEmpty) { lastMove = -1; continue; }
      int target = neighbors[rng.nextInt(neighbors.length)];
      _swap(emptyIndex, target);
      lastMove = emptyIndex;
      emptyIndex = target;
    }
    setState(() {});
  }

  List<int> _getNeighbors(int index) {
    List<int> neighbors = [];
    int row = index ~/ 4;
    int col = index % 4;
    if (row > 0) neighbors.add(index - 4);
    if (row < 3) neighbors.add(index + 4);
    if (col > 0) neighbors.add(index - 1);
    if (col < 3) neighbors.add(index + 1);
    return neighbors;
  }

  void _swap(int index1, int index2) {
    int temp = numbers[index1];
    numbers[index1] = numbers[index2];
    numbers[index2] = temp;
  }

  void _onTileTap(int index) {
    if (isWon) return;
    int emptyIndex = numbers.indexOf(0);
    if (_isAdjacent(index, emptyIndex)) {
      setState(() {
        _swap(index, emptyIndex);
        moveCount++;
        _checkWin();
      });
    }
  }

  bool _isAdjacent(int index1, int index2) {
    int row1 = index1 ~/ 4;
    int col1 = index1 % 4;
    int row2 = index2 ~/ 4;
    int col2 = index2 % 4;
    return (row1 == row2 && (col1 - col2).abs() == 1) ||
           (col1 == col2 && (row1 - row2).abs() == 1);
  }

  void _checkWin() {
    for (int i = 0; i < 15; i++) {
      if (numbers[i] != i + 1) return;
    }
    setState(() {
      isWon = true;
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("🎉 挑战成功！"),
        content: Text("你用了 $moveCount 步完成了还原。"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _startNewGame();
            },
            child: const Text("再玩一次"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        centerTitle: true,
        title: const Text("数字华容道", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.indigo,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.foot_bones, color: Colors.white70),
                const SizedBox(width: 10),
                Text("当前步数: $moveCount", 
                  style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)
                  ],
                ),
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 6,
                    ),
                    itemCount: 16,
                    itemBuilder: (context, index) {
                      int number = numbers[index];
                      if (number == 0) return const SizedBox.shrink(); 
                      return GestureDetector(
                        onTap: () => _onTileTap(index),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isWon ? Colors.green : Colors.indigoAccent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                               BoxShadow(color: Colors.black26, offset: Offset(2, 2), blurRadius: 2)
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "$number",
                            style: const TextStyle(
                                fontSize: 30, 
                                color: Colors.white, 
                                fontWeight: FontWeight.bold,
                                shadows: [Shadow(color: Colors.black26, offset: Offset(1,1))]
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 50.0, top: 20),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text("重新洗牌"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.indigo,
                elevation: 2,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: _startNewGame,
            ),
          )
        ],
      ),
    );
  }
}
