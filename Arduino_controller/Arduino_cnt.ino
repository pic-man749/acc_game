//　参考https://sites.google.com/a/gclue.jp/fab-zang-docs/ni-yinkiiot/adxl345-i2c

#include <Wire.h>

#define RESET_BTN 2
#define YELLOW_BTN 3
#define BLUE_BTN 4

#define DEVICE_ADDR (0x53) // スレーブデバイスのアドレス
byte axis_buff[6];

void setup()
{
    Serial.begin(9600); // シリアルの開始デバック用
    Wire.begin();       // I2Cの開始

    // DATA_FORMAT
    writeI2c(0x31, 0x00);
    // POWER_TCL
    writeI2c(0x2d, 0x08);

    // タクトスイッチ入力ピンの設定
    pinMode(RESET_BTN, INPUT_PULLUP);
    pinMode(YELLOW_BTN, INPUT_PULLUP);
    pinMode(BLUE_BTN, INPUT_PULLUP);
}

void loop()
{

    // S が飛んできたら送る
    char c =Serial.read();
    uint8_t command = 0;
    static bool sw_state[3] = {1,1,1};

    if(c == 'S'){

        uint8_t length = 6;
        readI2c(0x32, length, axis_buff); //レジスターアドレス 0x32から6バイト読む
        int x = (((int)axis_buff[1]) << 8) | axis_buff[0];
        int y = (((int)axis_buff[3]) << 8) | axis_buff[2];
        int z = (((int)axis_buff[5]) << 8) | axis_buff[4];

        if(digitalRead(RESET_BTN) && !sw_state[0]){
            command = 1;
        } else if(digitalRead(YELLOW_BTN) && !sw_state[1]){
            command = 2;
        } else if(digitalRead(BLUE_BTN) && !sw_state[2]){
            command = 3;
        }

        // 送信
        char str[32];
        sprintf(str, "%d,%d,%d,%d,\n", x, y, z, command);
        Serial.print(str);

        sw_state[0] = digitalRead(RESET_BTN);
        sw_state[1] = digitalRead(YELLOW_BTN);
        sw_state[2] = digitalRead(BLUE_BTN);
    }

}

// I2Cへの書き込み
void writeI2c(byte register_addr, byte value) {
    Wire.beginTransmission(DEVICE_ADDR);
    Wire.write(register_addr);
    Wire.write(value);
    Wire.endTransmission();
}

// I2Cへの読み込み
void readI2c(byte register_addr, int num, byte buffer[]) {
    Wire.beginTransmission(DEVICE_ADDR);
    Wire.write(register_addr);
    Wire.endTransmission();

    Wire.beginTransmission(DEVICE_ADDR);
    Wire.requestFrom(DEVICE_ADDR, num);

    int i = 0;
    while(Wire.available())
    {
      buffer[i] = Wire.read();
      i++;
    }
    Wire.endTransmission();
}
