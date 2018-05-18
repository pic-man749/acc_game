// 移動平均して返すクラス
class Acc{
  
  int MAX_BUFFER;
  int[][] values;
  int counter = 0;
  public int x = 0;
  public int y = 0;
  public int z = 0;
  
  Acc(int buffer_size){
    
    MAX_BUFFER = (buffer_size >= 1)? buffer_size : 1;
    values = new int[MAX_BUFFER][3];
  }
  
  int getx(){
    return x;
  }  
  int gety(){
    return y;
  }  
  int getz(){
    return z;
  }
  
  void setData(int data_x, int data_y, int data_z){
    
    // データセット
    values[counter][0] = data_x;
    values[counter][1] = data_y;
    values[counter][2] = data_z;
    
    // カウンタ更新
    if(counter+1 < MAX_BUFFER){
      counter += 1;
    }else {
      counter = 0;
    }
    
    // 移動平均取ってブレを無くすよ
    x = 0;
    y = 0;
    z = 0;
    for(int i = 0; i < MAX_BUFFER; i++){
      x += values[i][0];
      y += values[i][1];
      z += values[i][2];
    }
    x /= MAX_BUFFER;
    y /= MAX_BUFFER;
    z /= MAX_BUFFER;
    
  }
}