import shiffman.box2d.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.collision.shapes.Shape;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;
import processing.serial.*;

// A reference to our box2d world
Box2DProcessing box2d;

// A list we'll use to track fixed objects
ArrayList boundaries;

// Just a single ball this time
Particle particle;

// Serial
Serial myPort;

// Acc
Acc acc = new Acc(3);

// Maze
Maze maze;

// second window
SecondApplet second;

// Pointer
ArrayList<Pointer> pointer;

final float BALL_SIZE = 0.7;   // ボールのサイズ（最小幅比で）
final int MAZE_WIDTH = 600;    // 迷路幅
final int MAZE_HEIGHT = 600;   // 迷路高
final int RATIO = 5;           // 道幅の比率
int[][] data;                  // 迷路データ用二次元配列
int[][] ban_pos;               // おいちゃだめなところの二次元配列
int[] maze_pos;                // mazeの座標（x1, y1, x2, y2）
int W, H;                      // 横サイズ, 縦サイズ
int small;                     // 最小幅
int command_flag = 0;          // mbedからのコマンドフラグ
int point = 0;                 // 得点
int start_time;                // タイマー
int stop_time;                 // タイマー
int status;                    // 今の遷移状態
int game2_limit = 60000;       // 期限

/*
  status : 0 = init
           1 = 選択画面
           2 = 得点ゲーム
           3 = 得点ゲームリザルト
           4 = タイムアタック
           5 = タイムアタックリザルト
*/

void settings(){
  size(800, 800);
  //size(800, 800);
  //fullScreen();
}

void setup() {
  
  // 座標計算
  maze_pos = new int[4];
  maze_pos[0] = int(width/2.0 - MAZE_WIDTH/2.0);   // x1
  maze_pos[1] = height - MAZE_HEIGHT;  // y1
  maze_pos[2] = int(width/2.0 + MAZE_WIDTH/2.0);   // x2
  maze_pos[3] = height;  // y2
  
  status = 0;
  second = new SecondApplet(this);
  String mbed_port = "";
  while(mbed_port == ""){
    mbed_port = second.getSerialPort();
  }
  myPort = new Serial(this, mbed_port, 9600);
  myPort.bufferUntil('\n');
  
  smooth();
  
  // Initialize box2d physics and create the world
  box2d = new Box2DProcessing(this);
  box2d.createWorld();  
  // 無重力
  box2d.setGravity(0, 0);
  // collision
  // イベントリスナ
  box2d.listenForCollisions();
  
  // ダミー
  init(true, false);
  
  // 次のstatus
  status = 1;
  
}

void draw() {
  
  background(255);
  
  if(status == 1){
    myPort.write("S");
    if(command_flag == 2 || second.getYellowState()){
      status = 2;
      game2Init(false);
    }else if(command_flag == 3 || second.getBlueState()){
      status = 4;
      game3Init(false);
    }
    
    // menu
    fill(0);
    textSize(75);
    textAlign(CENTER);
    text("Maze Game", width/2, 100);
    textSize(40);
    fill(255,212,0);
    text("Yellow button : Point corrector Game", width/2, 150);
    fill(0,0,255);
    text("Blue button : Time attack Game", width/2, 200);
    
  } else if(status == 2)  game2();        // 得点ゲーム
    else if(status == 3)  game2Result();  // 得点ゲーム結果画面
    else if(status == 4)  game3();        // タイムアタック
    else if(status == 5)  game3Result();  // タイムアタック結果画面
 
}

// 共通の初期化
void init(boolean first_flag, boolean color_flag){
  // maze
  W = second.getMazeSizeW();
  H = second.getMazeSizeH();
  maze = new Maze(W, H);  // ヨコ×タテ
  ban_pos = new int[H][W];// HW逆なので注意
  data = maze.generateMaze();
  ban_pos = data;         // Cだとdata配列のポインタが入るので等価になりそうだけどこれいいのか？
  
  // 初回じゃないなら一回全部消す
  if(!first_flag){
    particle.delete();
    for (int i = 0; i < boundaries.size(); i++) {
      Boundary b = (Boundary)boundaries.get(i);
      b.delete();
    } 
  }

  float w_single = MAZE_WIDTH/float( floor(W/2.0)*RATIO+ceil(W/2.0) );
  float h_single = MAZE_HEIGHT/float( floor(H/2.0)*RATIO+ceil(H/2.0) );
  // Make the ball
  small = RATIO * int((w_single < h_single)? w_single : h_single);
  particle = new Particle(maze_pos[2] - w_single * (1 + RATIO/2.0 ) , maze_pos[3] - h_single * (1 + RATIO/2.0 ), BALL_SIZE*0.5*small);

  // Add a bunch of fixed boundaries
  boundaries = new ArrayList();
  for(int i = 0; i<H; i++){
    for(int j = 0; j<W; j++){
      if(data[i][j] == 1){
        boolean is_goal_block = (i < 2 && j < 2 ) && color_flag;
        //boundaries.add(new Boundary(j*MAZE_WIDTH/W+maze_pos[0], i*MAZE_HEIGHT/H+maze_pos[1], MAZE_WIDTH/W, MAZE_HEIGHT/H, is_goal_block));
        float posx = w_single * ( RATIO * ceil((j-1)/2.0) + ceil(j/2.0) ) + maze_pos[0];
        float posy = h_single * ( RATIO * ceil((i-1)/2.0) + ceil(i/2.0) ) + maze_pos[1];
        float ww = w_single * ((j%2 == 0)? 1:RATIO );
        float hh = h_single * ((i%2 == 0)? 1:RATIO );
        boundaries.add(new Boundary(int(posx), int(posy), int(ww), int(hh), is_goal_block));
      }
    }
  }
  
  // タイマー
  start_time = millis();
}
void commonPhysicsEngine(){

  box2d.setGravity(-1*acc.getx()/5, -1*acc.gety()/5);

  // We must always step through time!
  box2d.step();

  // Draw the boundaries
  for (int i = 0; i < boundaries.size(); i++) {
    Boundary wall = (Boundary) boundaries.get(i);
    wall.display();
  }
  
  // Draw
  particle.display();
}

// 得点源置くやつ
void setPointer(){
  int[] pp = {1, 1};
  int temp = 1;
  int counter = 0;
  while(temp == 1){
    pp[0] = int(random(H));
    pp[1] = int(random(W));
    temp = ban_pos[pp[0]][pp[1]];
    // おけなくて無限ループ防止
    if(counter >= H*W) return;
    counter++;
  }
  int pointer_x = int( (2*pp[1]+1)*MAZE_WIDTH/float(W*2)+maze_pos[0] );
  int pointer_y = int( (2*pp[0]+1)*MAZE_HEIGHT/float(H*2)+maze_pos[1] );
  pointer.add(new Pointer(BALL_SIZE*0.5*small, pointer_x, pointer_y, pp[0], pp[1]));
  ban_pos[pp[0]][pp[1]] = 1;
}
// init
void game2Init(boolean first_flag){
  
  init(first_flag, false);
  
  pointer = new ArrayList<Pointer>();
  // ポインタ設置
  for(int i = 0; i < second.getGame2Point(); i++) setPointer();
  point = 0;
  
  game2_limit = second.getGame2Limit();
}


// 得点集めゲーム
void game2(){

  // リセット処理
  if(command_flag == 1 || second.getResetState()){
    status = 1;
    
    if(pointer.size() != 0){
      for(int i = pointer.size() -1; i >= 0; i--){
        Pointer p = pointer.get(i);
        p.delete();
      }
    }
  }
  
  commonPhysicsEngine();

  // timer
  float time = (game2_limit - (millis() - start_time))/1000.0;
  if(time < 0.0){
    status = 3;
  }
  
  // ポインタの設置と削除
  boolean make_pointer_flag = false;
  for(int i = pointer.size()-1; i>=0; i--){
    Pointer p = pointer.get(i);
    if(!p.is_alive()){
      make_pointer_flag = true;
      int[] pp = p.getPP();
      ban_pos[pp[0]][pp[1]] = 0;
      p.delete();
      pointer.remove(i);
    }else{
      p.display();
    }
  }
  if(make_pointer_flag) setPointer();
  
  // テキスト関係
  fill(0);
  textSize(50);
  textAlign(CENTER);
  text("Point : "+ point , width/2, 50);
  if(time < 10) fill(255,0,0);
  text("timer " + nf(time, 2, 3) , width/2, 100);
}

void game2Result(){
  
  if(command_flag == 1 || second.getResetState()){
    status = 1;
    
    if(pointer.size() != 0){
      for(int i = pointer.size() -1; i >= 0; i--){
        Pointer p = pointer.get(i);
        p.delete();
      }
    }
  }
  
  fill(0);
  textSize(50);
  textAlign(CENTER);
  text("Your score : " + point , width/2, 70);
  textSize(30);
  text("Press reset button to return main menu", width/2, 150);  
  
}

void game3Init(boolean first_flag){
  
  init(first_flag, true);
  
}
// タイムアタック
void game3(){

  // リセット処理
  if(second.getResetState() || command_flag == 1) status = 1;
  
  commonPhysicsEngine();

  // timer
  float time = (millis() - start_time)/1000.0;
  
  Vec2 pos = particle.getCoord();
  if(pos.x < maze_pos[0]+(MAZE_WIDTH/W*2) && pos.y < maze_pos[1]+(MAZE_HEIGHT/H*2)){
    status = 5;
    stop_time = millis();
  }
  
  // テキスト関係
  fill(0);
  textSize(50);
  textAlign(CENTER);
  text("time : " + nf(time, 3, 3) , width/2, 100);
}
void game3Result(){
  
  if(command_flag == 1 || second.getResetState()) status = 1;
  
  fill(0);
  textSize(50);
  textAlign(CENTER);
  text("Your time : " + nf((stop_time - start_time)/1000.0, 3, 3) , width/2, 70);
  textSize(30);
  text("Press reset button to return main menu", width/2, 150);  
}

// Collision event functions!
void beginContact(Contact cp) {
  // Get both fixtures
  Fixture f1 = cp.getFixtureA();
  Fixture f2 = cp.getFixtureB();
  // Get both bodies
  Body b1 = f1.getBody();
  Body b2 = f2.getBody();

  // Get our objects that reference these bodies
  Object o1 = b1.getUserData();
  Object o2 = b2.getUserData();

  if(o1.getClass() == Particle.class && o2.getClass() == Pointer.class){
    Pointer p = (Pointer) o2;
    point += 10;
    p.change();
  }else if(o2.getClass() == Particle.class && o1.getClass() == Pointer.class){
    Pointer p = (Pointer) o1;
    point += 10;
    p.change();
  } 
}

// シリアルでなんか飛んで来ると発火するやつ
void serialEvent(Serial p){
  
  //変数xにシリアル通信で読み込んだ値を代入
  String dataline = p.readStringUntil('\n');
  String[] str = dataline.split("," , -1);
  command_flag = int(str[3]);
  // データセット
  acc.setData(int(str[0]), int(str[1]), int(str[2]));
  second.setData(int(str[0]), int(str[1]), int(str[2]), command_flag);
  // 次のデータ送ってねの合図
  if(status != 1) p.write("S");
}