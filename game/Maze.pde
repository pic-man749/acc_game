// ↓のサイトさんのコードを移植（乱数生成をprocessing用にしただけ）
// http://www.jp.migapro.com/anahori-hou/

import java.util.ArrayList;
import java.util.Collections;

/**
 * 穴掘り法を使って迷路を作ります。
 * @return 迷路を表現する２次元配列
*/
class Maze{
  
    int size_x, size_y;
    int[][] maze;
    
    Maze(int size_x_, int size_y_){
        size_x = size_x_;
        size_y = size_y_;
        maze = new int[size_y][size_x];
    }
    
    public int[][] generateMaze(){
       // 初期化
       for (int i = 0; i < size_y; i++)
           for (int j = 0; j < size_x; j++)
               maze[i][j] = 1;
    
        // rはrow、cはcolumn
        // rのランダム奇数
        int r = round(random(size_y-1));
        while (r % 2 == 0){
            r = round(random(size_y-1));
        }
        // cのランダム奇数
        int c = round(random(size_x-1));
        while (c % 2 == 0){
            c = round(random(size_x-1));
        }
        // 開始地点
        maze[r][c] = 0;
    
        //　再帰メソッド
        recursion(r, c);
    
        return maze;
    }
    
    /**
     * 穴掘り法を用いて迷路を生成。
     * @param r 現在のrow
     * @param c 現在のcolumn
     */
    public void recursion(int r, int c){
        // ４つの方向をランダムな順に配列へ
        Integer[] randDirs = generateRandomDirections();
        // 順番にその方向に進む
        for (int i = 0; i < randDirs.length; i++){
    
            switch(randDirs[i]){
            case 1: // 上
                //　上２マス先が迷路の外か
                if (r - 2 <= 0)
                    continue;
                if (maze[r - 2][c] != 0){
                    maze[r-2][c] = 0;
                    maze[r-1][c] = 0;
                    recursion(r - 2, c);
                }
                break;
            case 2: // 右
                // 右２マス先が迷路の外か
                if (c + 2 >= size_x - 1)
                    continue;
                if (maze[r][c + 2] != 0){
                    maze[r][c + 2] = 0;
                    maze[r][c + 1] = 0;
                    recursion(r, c + 2);
                }
                break;
            case 3: // 下
                // 下２マス先が迷路の外か
                if (r + 2 >= size_y - 1)
                    continue;
                if (maze[r + 2][c] != 0){
                    maze[r+2][c] = 0;
                    maze[r+1][c] = 0;
                    recursion(r + 2, c);
                }
                break;
            case 4: // 左
                // 左２マス先が迷路の外か
                if (c - 2 <= 0)
                    continue;
                if (maze[r][c - 2] != 0){
                    maze[r][c - 2] = 0;
                    maze[r][c - 1] = 0;
                    recursion(r, c - 2);
                }
                break;
            }
        }
    
    }
    
    /**
    * 左右上下の方向を表す４つの数字をランダムな順に配列として生成。
    * @return 方向を表す４つの数字をもった配列
    */
    public Integer[] generateRandomDirections() {
         ArrayList<Integer> randoms = new ArrayList<Integer>();
         for (int i = 0; i < 4; i++)
              randoms.add(i + 1);
         Collections.shuffle(randoms);
    
        return randoms.toArray(new Integer[4]);
    }
}