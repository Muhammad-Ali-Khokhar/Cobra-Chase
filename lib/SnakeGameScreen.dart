


import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // Import ScreenUtil

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(320, 534), // Set the design size
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Cobra Chase',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: SnakeGameScreen(),
        );
      },
    );
  }
}

class SnakeGameScreen extends StatefulWidget {
  @override
  _SnakeGameScreenState createState() => _SnakeGameScreenState();
}

enum Direction { up, down, left, right }

class _SnakeGameScreenState extends State<SnakeGameScreen> {
  final int rows = 20;
  final int columns = 20;
  String direction = "r";
  List<int> snake = [];
  Direction _direction = Direction.right;
  Direction _nextDirection = Direction.right;
  Timer? _timer;
  Random _random = Random();
  int food = 0;
  bool isGameOver = false;
  int score = 0;
  bool gameStarted = false;
  double screenWidth = 0;
  double screenHeight = 0;
  bool showButtons = true; // Variable to determine whether to show buttons or not
  int speedx = 300;
  bool smallScreen = false;
  late BannerAd _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();

    _initBannerAd();

    startGame();
    // First get the FlutterView.
    FlutterView view = WidgetsBinding.instance!.platformDispatcher.views.first;

    // Dimensions in logical pixels (dp)
    Size size = view.physicalSize / view.devicePixelRatio;
    screenWidth = size.width;
    screenHeight = size.height;

    // Check if screen height is less than 700 dp
    if (screenHeight < 700) {
      setState(() {
        showButtons = false; // Hide the buttons
        smallScreen = true;
      });
    }
  }

  _initBannerAd(){
    _bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: 'admob id',
      listener: BannerAdListener(
        onAdLoaded: (ad){
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error){},
      ),
      request: AdRequest(),
    );
    _bannerAd.load();
  }

  void startGame() {
    snake = [(columns * rows / 2).round()];
    gameStarted = true;
    const Duration speed = Duration(milliseconds: 200);
    generateFood();
    _timer = Timer.periodic(speed, (timer) {
      setState(() {
        if (!isGameOver) {
          updateSnake();
          checkSnakeCollision();
          checkFoodCollision();
        }
      });
    });
  }

  void updateSnake() {
    _direction = _nextDirection;

    int nextCell = 0;
    switch (_direction) {
      case Direction.up:
        nextCell = snake.first - columns;
        if (nextCell < 0) {
          gameOver();
          return;
        }
        break;
      case Direction.down:
        nextCell = snake.first + columns;
        if (nextCell >= rows * columns) {
          gameOver();
          return;
        }
        break;
      case Direction.left:
        nextCell = snake.first - 1;
        if (nextCell % columns == columns - 1) {
          gameOver();
          return;
        }
        break;
      case Direction.right:
        nextCell = snake.first + 1;
        if (nextCell % columns == 0) {
          gameOver();
          return;
        }
        break;
    }

    if (snake.contains(nextCell)) {
      gameOver();
      return;
    }

    snake.insert(0, nextCell);
    if (nextCell != food) {
      snake.removeLast();
    } else {
      generateFood();
      score += 10;
    }
  }

  void generateFood() {
    food = _random.nextInt(rows * columns);
    if (snake.contains(food)) {
      generateFood();
    }
  }

  void checkSnakeCollision() {
    int head = snake.first;
    if (head < 0 || head >= rows * columns || snake.sublist(1).contains(head)) {
      gameOver();
    }
  }

  void checkFoodCollision() {
    if (snake.first == food) {
      generateFood();
    }
  }

  void gameOver() {
    _timer?.cancel();
    setState(() {
      isGameOver = true;
    });
  }

  void restartGame() {
    setState(() {
      snake = [(columns * rows / 2).round(), (columns * rows / 2).round() + 1, (columns * rows / 2).round() + 2];
      _direction = Direction.right;
      _nextDirection = Direction.right;
      score = 0;
      isGameOver = false;
      gameStarted = false;
    });
    startGame();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(320, 534));

    final screenWidth = ScreenUtil().screenWidth;
    final screenHeight = ScreenUtil().screenHeight;

    return SafeArea(
      child: GestureDetector(
        onTap: () {
          if (!gameStarted) {
            startGame();
          }
        },
        onVerticalDragUpdate: (details) {
          if (_direction != Direction.up && details.delta.dy > 0) {
            _nextDirection = Direction.down; // Set next direction
          } else if (_direction != Direction.down && details.delta.dy < 0) {
            _nextDirection = Direction.up; // Set next direction
          }
        },
        onHorizontalDragUpdate: (details) {
          if (_direction != Direction.left && details.delta.dx > 0) {
            _nextDirection = Direction.right; // Set next direction
          } else if (_direction != Direction.right && details.delta.dx < 0) {
            _nextDirection = Direction.left; // Set next direction
          }
        },

        child: Container(
          width: screenWidth,
          height: screenHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF00C49F), Color(0xFF5FFBF1)],
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,


            appBar: smallScreen ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                'Cobra Chase',
                style: TextStyle(fontSize: 25.sp),

              ),
              centerTitle: true,
              actions: const [
                // SizedBox(width: 100),
              ],
            ): null,
            body: Stack(
              children: [
                Positioned(
                  top: screenHeight * 0.02,
                  left: 0,
                  right: 0,

                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if(!smallScreen)
                        SizedBox(height: 50.sp,),

                      SizedBox(height: 20.sp),
                      Text(
                        'Score: $score',
                        style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      SizedBox(height: 10.sp),
                      Container(
                        width: screenWidth,
                        height: screenWidth,
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                          ),
                          itemCount: rows * columns,
                          itemBuilder: (context, index) {
                            if (snake.contains(index)) {
                              return Container(
                                margin: EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                  color: Color(0xFF00796B),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              );
                            } else if (food == index) {
                              return Container(
                                margin: EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                  color: Color(0xFFFF3D00),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              );
                            } else {
                              return Container(
                                margin: EdgeInsets.all(1),
                                color: Color(0xFF00C49F),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                if (showButtons) // Conditionally render the buttons
                  Positioned(
                    bottom: screenHeight * 0.02,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        // Your button widgets here... // Adding space between the rows
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (checkOldDirection("u")) {
                                    _nextDirection = Direction.up;
                                    direction = "u";
                                  }
                                });
                              },
                              child: Container(
                                width: screenHeight * 0.09,
                                height: screenHeight * 0.09,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                child: Icon(Icons.keyboard_arrow_up, size: 40.sp, color: Colors.white),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (checkOldDirection("l")) {
                                    _nextDirection = Direction.left;
                                    direction = "l";
                                  }
                                });
                              },
                              child: Container(
                                width: screenHeight * 0.09,
                                height: screenHeight * 0.09,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                child: Icon(Icons.keyboard_arrow_left, size: 40.sp, color: Colors.white),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (checkOldDirection("r")) {
                                    _nextDirection = Direction.right;
                                    direction = "r";
                                  }
                                });
                              },
                              child: Container(
                                width: screenHeight * 0.09,
                                height: screenHeight * 0.09,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                child: Icon(Icons.keyboard_arrow_right, size: 40.sp, color: Colors.white),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 1), // Adding space between the rows
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (checkOldDirection("d")) {
                                    _nextDirection = Direction.down;
                                    direction = "d";
                                  }
                                });
                              },
                              child: Container(
                                width: screenHeight * 0.09,
                                height: screenHeight * 0.09,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                child: Icon(Icons.keyboard_arrow_down, size: 40.sp, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                if (isGameOver)
                  Center(
                    child: Container(
                      width: screenWidth * 0.8,
                      height: screenHeight * 0.3,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Game Over',
                            style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold, color: Colors.red),
                          ),
                          SizedBox(height: 10.sp),
                          Text(
                            'Score: $score',
                            style: TextStyle(fontSize: 20.sp, color: Colors.black),
                          ),
                          SizedBox(height: 10.sp),
                          ElevatedButton(
                            onPressed: restartGame,
                            style: ElevatedButton.styleFrom(
                              primary: Color(0xFF00C49F),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                              child: Text(
                                'Restart',
                                style: TextStyle(fontSize: 18.sp),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                    if (!smallScreen)
                      Positioned(
                        top: 0,
                        left: (MediaQuery.of(context).size.width - _bannerAd.size.width.toDouble()) / 2,
                        child: _isAdLoaded ? Container(
                          height: _bannerAd.size.height.toDouble(),
                          width: _bannerAd.size.width.toDouble(),
                          child: AdWidget(ad: _bannerAd),
                        ):SizedBox(),
                      ),
                    if (smallScreen)
                      Positioned(
                        bottom: 0,
                        left: (MediaQuery.of(context).size.width - _bannerAd.size.width.toDouble()) / 2,
                        child: _isAdLoaded ? Container(
                          height: _bannerAd.size.height.toDouble(),
                          width: _bannerAd.size.width.toDouble(),
                          child: AdWidget(ad: _bannerAd),
                        ):SizedBox(),
                      ),// Add other widgets here as needed



              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool checkOldDirection(String newDirection) {
    if (direction == "r" && newDirection == "l") {
      return false;
    } else if (direction == "l" && newDirection == "r") {
      return false;
    } else if (direction == "u" && newDirection == "d") {
      return false;
    } else if (direction == "d" && newDirection == "u") {
      return false;
    } else {
      return true;
    }
  }
}
