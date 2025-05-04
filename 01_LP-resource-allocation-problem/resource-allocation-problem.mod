/*********************************************
 * OPL 22.1.1.0 Model
 * Author: hiralab-NUC
 * Creation Date: 2025/04/26 at 19:16:44
 *********************************************/

 /*******************************************
 資源配分問題 (製品ミックス問題):
シナリオ: ある工場では、製品Aと製品Bを生産しています。生産には原材料Xと原材料Y、そして労働時間が必要です。利益を最大化するためには、各製品をどれだけ生産すべきでしょうか？
	データ:
		製品A: 1単位あたり利益5万円、原材料Xを2kg、原材料Yを1kg、労働時間を3時間必要とします。
		製品B: 1単位あたり利益4万円、原材料Xを1kg、原材料Yを2kg、労働時間を2時間必要とします。
		利用可能な資源: 原材料Xは最大100kg、原材料Yは最大80kg、労働時間は最大150時間。
	目的: 総利益 (5 * (製品Aの生産量) + 4 * (製品Bの生産量)) を最大化する。
	制約:
		原材料Xの使用量 <= 100 kg
		原材料Yの使用量 <= 80 kg
		総労働時間 <= 150 時間
		各製品の生産量は0以上。
	解くソルバー: CPLEX (単体法 or 内点法)
*******************************************/

// --- データ宣言 ---

// 製品の集合 {"A", "B"}
{string} Products = ...;

// 資源の集合 {"X", "Y", "Z"}
{string} Resources = ...;

// 各製品の単位あたり利益 (profit["A"] = 5)
float profit[Products] = ...;

// 各製品が1単位生産するのに必要な各資源の量 (例: consumption["X"]["A"] = 2)
float consumption[Resources][Products] = ...;

// 各資源の利用可能上限 (例: capacity["X"] = 100)
float capacity[Resources] = ...;

// --- 決定変数宣言 ---

// 各製品の生産量 (0以上の実数)
// 制約: production[p] >= 0 (dvar float+ で定義)
dvar float+ production[Products];


// --- 目的関数定義 ---

// 総利益を最大化する
maximize sum( p in Products ) profit[p] * production[p];


// --- 制約条件定義 ---

subject to {
  // 各資源の利用可能量に関する制約
  forall( r in Resources ) {
    ctCapacity: // 制約に名前を付ける (任意)
      sum( p in Products ) consumption[r][p] * production[p] <= capacity[r];
  }
}