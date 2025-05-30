/*********************************************
 * OPL 22.1.1.0 Model
 * Author: hiralab-NUC
 * Creation Date: 2025/04/27 at 13:36:50
 *********************************************/

/*********************************************
*ナップサック問題 (0/1 Knapsack):**
*   **シナリオ:** あなたは容量15kgのナップサックを持っています。いくつかの品物があり、それぞれの重さと価値が決まっています。ナップサックに入れる品物の合計価値が最大になるように、どの品物を選ぶべきでしょうか？各品物は1つしかなく、入れるか入れないかのどちらかです。
*   **データ:**
    *   品物1: 重さ 12kg, 価値 4万円
    *   品物2: 重さ 2kg, 価値 2万円
    *   品物3: 重さ 1kg, 価値 1万円
    *   品物4: 重さ 1kg, 価値 2万円
    *   品物5: 重さ 4kg, 価値 10万円
*   **目的:** ナップサックに入れた品物の合計価値を最大化する。
*   **制約:**
    *   ナップサックに入れた品物の合計重量 <= 15kg。
    *   各品物は入れる(1)か入れない(0)かのどちらか (0/1変数)。
*   **解くソルバー:** CPLEX (分枝限定法 / 分枝カット法)
 *********************************************/

// --- データ宣言 ---

// 品物の集合 (例: {1, 2, 3, 4, 5})
{int} Items = ...;

// 各品物の価値
float value[Items] = ...;

// 各品物の重さ
float weight[Items] = ...;

// ナップサックの容量
float capacity = ...;


// --- 決定変数宣言 ---

// 各品物をナップサックに入れるかどうか (0:入れない, 1:入れる)
// dvar boolean take[Items]; // boolean型でも良い
dvar int take[Items] in 0..1; // 0か1の整数型


// --- 目的関数定義 ---

// ナップサックに入れる品物の合計価値を最大化する
maximize
  sum( i in Items ) value[i] * take[i];


// --- 制約条件定義 ---

subject to {
  // 容量制約: 入れる品物の合計重量はナップサックの容量以下
  ctCapacity: // 制約に名前を付ける (任意)
    sum( i in Items ) weight[i] * take[i] <= capacity;

  // 暗黙の制約: take[i] は 0 または 1 (dvar int[0..1] で定義済み)
}