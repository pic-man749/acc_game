# acc_game
ProcessingとArduinoを使った迷路を移動するゲーム．

<img src="https://raw.githubusercontent.com/pic-man749/acc_game/master/picture/main.png" style="width:400px;">

## ゲーム一覧

### ポイント集めゲーム
制限時間内で青い得点をいくつ集められるか競うゲーム．

<img src="https://raw.githubusercontent.com/pic-man749/acc_game/master/picture/point.png" style="width:400px;">

### タイムアタック
ボールを左上の赤い部分までいかに早く転がすかを競うゲーム．

<img src="https://raw.githubusercontent.com/pic-man749/acc_game/master/picture/time.png" style="width:400px;">

## ハードウェア

### 必要なもの

* Arduino UNO
* 加速度センサADXL345
* タクトスイッチ
* 基板，ブレットボード，配線材等

### 回路図
![](https://raw.githubusercontent.com/pic-man749/acc_game/master/picture/circuit%20diagram.png)

ArduinoはPCとシリアル通信をするのでPCとUSB接続してください．

## ソフトウェア
本リポジトリのソフトウェアについて説明します．

### Arduino用コード
~~~
acc_game/Arduino_controller
~~~

### Processingゲーム本体
~~~
acc_game/game
~~~

#### Processingを起動するのに必要なライブラリ

* Box2D for Processing
* ControlP5



