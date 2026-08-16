<?php
// ECS_CONTAINER_METADATA_URI_V4はECSのタスク自身のメタデータ取得URL、'/task'でタスク全体
$url = getenv('ECS_CONTAINER_METADATA_URI_V4') . '/task';
// URLにHTTP GETリクエストを送り、JSON文字列を取得
$json = file_get_contents($url);
// 連想配列に変換
$data = json_decode($json, true);
// TaskARN キーの値を取り出す
$taskArn = $data['TaskARN'] ?? 'unknown';

// タスクARNの末尾がタスクID
// arn:aws:ecs:...:task/cluster/xxxxxxxx → xxxxxxxx
$taskId = basename($taskArn);

// マスク処理: 最初の4文字以外を*に
$masked = substr($taskId, 0, 4) . str_repeat('*', strlen($taskId) - 4);

echo "<h1>Hello PHP Docker!</h1>";
echo "<p>ECS Task ID: $masked</p>";
?>