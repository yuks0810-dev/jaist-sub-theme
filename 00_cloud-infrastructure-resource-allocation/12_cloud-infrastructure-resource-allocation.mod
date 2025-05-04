/*********************************************
 * OPL 22.1.1.0 Model
 * Author: hiralab-NUC
 * Creation Date: 2025/04/28 at 8:14:52
 *********************************************/

// --- データ宣言 ---

// アプリケーションの集合 (例: {"App1", "App2", "App3"})
{string} Apps = ...;

// インスタンスタイプの集合 (例: {"TypeA", "TypeB", ...})
{string} Types = ...;

// 可用性ゾーンの集合 (例: {"AZ-A", "AZ-B"})
{string} AZs = ...;

// AZ分散が必要なアプリケーションの集合 (Appsのサブセット)
{string} DistApps = ...;
{string} FilteredApps = Apps inter DistApps;

// 各インスタンスタイプの月額コスト
float cost[Types] = ...;

// 各インスタンスタイプのスペック
float cpu[Types] = ...;
float mem[Types] = ...;
float disk[Types] = ...;

// 各アプリケーションの最低要求リソース
float req_cpu[Apps] = ...;
float req_mem[Apps] = ...;
float req_disk[Apps] = ...;

// 各アプリケーションに必要な最低インスタンス台数
int min_inst_per_app[Apps] = ...;

// 利用可能なTypeDインスタンスの最大合計台数
int max_typeD = ...;


// --- 決定変数宣言 ---

dvar int+ x[Apps][Types][AZs];


// --- 目的関数定義 ---

minimize
  sum( a in Apps, t in Types, z in AZs ) cost[t] * x[a][t][z];


// --- 制約条件定義 ---

subject to {
  // 1. CPU要求 (各アプリごと)
  forall( a in Apps ) {
    ctCPU:
      sum( t in Types, z in AZs ) cpu[t] * x[a][t][z] >= req_cpu[a];
  }

  // 2. メモリ要求 (各アプリごと)
  forall( a in Apps ) {
    ctMemory:
      sum( t in Types, z in AZs ) mem[t] * x[a][t][z] >= req_mem[a];
  }

  // 3. ディスク要求 (各アプリごと)
  forall( a in Apps ) {
    ctDisk:
      sum( t in Types, z in AZs ) disk[t] * x[a][t][z] >= req_disk[a];
  }

  // 4. 最低インスタンス数 (各アプリごと)
  forall( a in Apps )
	  sum( t in Types, z in AZs ) x[a][t][z] >= min_inst_per_app[a];

  // 5. AZ分散 (AZ分散が必要な各アプリごと、各AZごと)
  forall( a in FilteredApps, z in AZs ) {
    ctAZDistribution:
      sum( t in Types ) x[a][t][z] >= 1;
  }

  // 6. TypeD 利用上限 (全体での合計)
  ctMaxTypeD:
    sum( a in Apps, z in AZs ) x[a]["TypeD"][z] <= max_typeD;
}

execute {
  writeln("=== Optimal Instance Allocation ===");
  
  var totalCost = 0;

  for (var a in Apps) {
    writeln("Application: ", a);

    var usedCpu = 0;
    var usedMem = 0;
    var usedDisk = 0;

    for (var t in Types) {
      for (var z in AZs) {
        if (x[a][t][z] > 0) {
          writeln("  - Instance Type: ", t, " / AZ: ", z, " => Count: ", x[a][t][z]);
          usedCpu += cpu[t] * x[a][t][z];
          usedMem += mem[t] * x[a][t][z];
          usedDisk += disk[t] * x[a][t][z];
          totalCost += cost[t] * x[a][t][z];
        }
      }
    }

    writeln("  * Total CPU allocated: ", usedCpu, " (Required: ", req_cpu[a], ")");
    writeln("  * Total Memory allocated: ", usedMem, " (Required: ", req_mem[a], ")");
    writeln("  * Total Disk allocated: ", usedDisk, " (Required: ", req_disk[a], ")");
    writeln("  * CPU Requirement Met: ", (usedCpu >= req_cpu[a] ? "Yes" : "No"));
    writeln("  * Memory Requirement Met: ", (usedMem >= req_mem[a] ? "Yes" : "No"));
    writeln("  * Disk Requirement Met: ", (usedDisk >= req_disk[a] ? "Yes" : "No"));
    writeln();
  }

  writeln("=== Total Monthly Cost ===");
  writeln("Total Cost: ", totalCost);
}


