// コントロール画面
import controlP5.*;
import processing.serial.*;

class SecondApplet extends PApplet {
  PApplet parent;
  ControlP5 cp5;
  DropdownList dl_ports;
  Serial port;
  int port_index;
  int maze_size_w = 25;
  int maze_size_h = 25;
  int game2_limit = 60;
  int game2_point = 5;
  int command_flag = 0;
  boolean is_reset = false;
  boolean is_yellow = false;
  boolean is_blue = false;
  String port_name = "";
  PVector pv = new PVector(0,0,0);

  SecondApplet(PApplet _parent) {
    super();
    // set parent
    this.parent = _parent;
    //// init window
    try {
      java.lang.reflect.Method handleSettingsMethod =
        this.getClass().getSuperclass().getDeclaredMethod("handleSettings", null);
      handleSettingsMethod.setAccessible(true);
      handleSettingsMethod.invoke(this, null);
    } catch (Exception ex) {
      ex.printStackTrace();
    }
    
    PSurface surface = super.initSurface();
    surface.placeWindow(new int[]{0, 0}, new int[]{0, 0});
    
    this.showSurface();
    this.startSurface();
    
  }
  
  void settings() {
    size(512, 512);
  }
  
  void setup() {
    cp5 = new ControlP5(this);
    
    // Serial port ddl
    String[] ports = Serial.list();
    dl_ports = cp5.addDropdownList("serial-ports");
    dl_ports.setPosition(15, 30);
    dl_ports.setWidth(150);  
    dl_ports.setHeight(200);
    dl_ports.setBarHeight(21);
    dl_ports.setItemHeight(22);
    for (int i=0; i<ports.length; i++) {
      dl_ports.addItem(ports[i], i);
    }
    dl_ports.close();
    
    // reset
    cp5.addButton("reset")
      .setPosition(250, 30)
      .setSize(70, 20);
    // reset
    cp5.addButton("yellow")
      .setPosition(330, 30)
      .setSize(70, 20);
    // reset
    cp5.addButton("blue")
      .setPosition(410, 30)
      .setSize(70, 20);
    
    // maze size slider
    cp5.addSlider("maze_size_w")
      .setRange(5, 100)
      .setValue(maze_size_w)//初期値
      .setPosition(15, 150)//位置
      .setSize(200, 20)//大きさ
      .setNumberOfTickMarks(96)
      ;
    cp5.addSlider("maze_size_h")
      .setRange(5, 100)//0~100の間
      .setValue(maze_size_h)//初期値
      .setPosition(15, 200)//位置
      .setSize(200, 20)//大きさ
      .setNumberOfTickMarks(96)
      ;
      
    // game 2 limit
    cp5.addSlider("game2_limit")
      .setRange(30, 120)
      .setValue(game2_limit)
      .setPosition(15, 300)
      .setSize(200, 20)
      .setNumberOfTickMarks(91)
      ;
    // game 2 point
    cp5.addSlider("game2_point")
      .setRange(1, 500)
      .setValue(game2_point)
      .setPosition(15, 350)
      .setSize(200, 20)
      .setNumberOfTickMarks(100)
      ;
  }
  
  void draw() {
    background(255, 255, 255);
    fill(0);
    text("Serial port", 15, 20);
    text("Maze size W", 15, 140);
    text("Maze size H", 15, 190);
    text("Game 2 limit", 15, 290);
    text("Game 2 point", 15, 340);
    
    text("Acc data:" + nf(pv.x, 3, 0) + ", " + nf(pv.y, 3, 0) + ", " + nf(pv.z, 3, 0) , 15, 400);
    text("command_flag:" + command_flag, 15, 420);
  }
  
  String getSerialPort(){
    return port_name;
  }
  
  boolean getResetState(){
    if(is_reset){
      is_reset = false;
      return true;
    } else {
      return false;
    }
  }
  boolean getYellowState(){
    if(is_yellow){
      is_yellow = false;
      return true;
    } else {
      return false;
    }
  }
  boolean getBlueState(){
    if(is_blue){
      is_blue = false;
      return true;
    } else {
      return false;
    }
  }
  
  int getMazeSizeW(){
    // 奇数にしたい
    if(maze_size_w % 2 ==0){
      maze_size_w += 1;
    }
    return maze_size_w;
  }
  int getMazeSizeH(){
    if(maze_size_h % 2 ==0){
      maze_size_h += 1;
    }
    return maze_size_h;
  }
  
  int getGame2Limit(){
    return game2_limit*1000;
  }
  int getGame2Point(){
    return game2_point ;
  }
  
  void setData(int x,int y,int z,int cf){
    pv = new PVector(x,y,z);
    command_flag = cf;
  }
  
  void controlEvent(ControlEvent event) {
    if (event.isFrom("serial-ports")){
      port_index = (int)(dl_ports.getValue());
      port_name = Serial.list()[port_index];
    }
    if (event.isFrom("reset")){
      is_reset = true;
    }
    if (event.isFrom("yellow")){
      is_yellow = true;
    }
    if (event.isFrom("blue")){
      is_blue = true;
    }
  }
}