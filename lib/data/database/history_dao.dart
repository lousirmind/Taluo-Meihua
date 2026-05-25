import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'database_helper.dart';
import '../../models/history_record.dart';

class HistoryDao {
  static const _table = 'history';
  static const _maxRecords = 200;

  /// 保存一条历史记录
  static Future<HistoryRecord> save({
    required DivinationType type,
    required String summary,
    required Map<String, dynamic> jsonData,
  }) async {
    final db = await DatabaseHelper.database;
    final id = const Uuid().v4();
    final now = DateTime.now();

    // 检查是否超出上限，删除最早记录
    final count = (await db.rawQuery('SELECT COUNT(*) as c FROM $_table')).first['c'] as int;
    if (count >= _maxRecords) {
      await db.rawDelete(
        'DELETE FROM $_table WHERE id IN (SELECT id FROM $_table ORDER BY create_time ASC LIMIT ?)',
        [count - _maxRecords + 1],
      );
    }

    final record = HistoryRecord(
      id: id,
      type: type,
      createTime: now,
      summary: summary,
      jsonData: jsonEncode(jsonData),
    );

    await db.insert(_table, {
      'id': record.id,
      'type': record.type.name,
      'create_time': record.createTime.millisecondsSinceEpoch,
      'summary': record.summary,
      'json_data': record.jsonData,
    });

    return record;
  }

  /// 获取历史记录列表
  static Future<List<HistoryRecord>> getAll({DivinationType? type}) async {
    final db = await DatabaseHelper.database;

    List<Map<String, dynamic>> rows;
    if (type != null) {
      rows = await db.query(
        _table,
        where: 'type = ?',
        whereArgs: [type.name],
        orderBy: 'create_time DESC',
      );
    } else {
      rows = await db.query(
        _table,
        orderBy: 'create_time DESC',
      );
    }

    return rows.map((row) => HistoryRecord(
      id: row['id'] as String,
      type: DivinationType.values.firstWhere((t) => t.name == row['type']),
      createTime: DateTime.fromMillisecondsSinceEpoch(row['create_time'] as int),
      summary: (row['summary'] as String?) ?? '',
      jsonData: row['json_data'] as String?,
    )).toList();
  }

  /// 获取单条记录
  static Future<HistoryRecord?> getById(String id) async {
    final db = await DatabaseHelper.database;
    final rows = await db.query(_table, where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    final row = rows.first;
    return HistoryRecord(
      id: row['id'] as String,
      type: DivinationType.values.firstWhere((t) => t.name == row['type']),
      createTime: DateTime.fromMillisecondsSinceEpoch(row['create_time'] as int),
      summary: (row['summary'] as String?) ?? '',
      jsonData: row['json_data'] as String?,
    );
  }

  /// 删除一条记录
  static Future<void> delete(String id) async {
    final db = await DatabaseHelper.database;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  /// 清除所有历史记录
  static Future<void> clearAll() async {
    final db = await DatabaseHelper.database;
    await db.delete(_table);
  }
}
