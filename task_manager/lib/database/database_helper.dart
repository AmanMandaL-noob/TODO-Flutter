// lib/database/database_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'task_manager.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        due_date TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'todo',
        blocked_by_id INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (blocked_by_id) REFERENCES tasks(id) ON DELETE SET NULL
      )
    ''');

    // Seed initial videography project tasks
    final now = DateTime.now();
    final tasks = [
      // Pre-Production
      {
        'title': 'Script Writing',
        'description': 'Write the script for the video project.',
        'due_date': now.add(const Duration(days: 2)).toIso8601String(),
        'status': 'done',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
      {
        'title': 'Storyboarding',
        'description': 'Create storyboards for each scene.',
        'due_date': now.add(const Duration(days: 3)).toIso8601String(),
        'status': 'in_progress',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
      {
        'title': 'Location Scouting',
        'description': 'Scout and finalize filming locations.',
        'due_date': now.add(const Duration(days: 4)).toIso8601String(),
        'status': 'todo',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
      // Equipment & Setup
      {
        'title': 'Camera Setup',
        'description': 'Set up cameras and check settings.',
        'due_date': now.add(const Duration(days: 5)).toIso8601String(),
        'status': 'done',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
      {
        'title': 'Lighting Arrangement',
        'description': 'Arrange lighting for all scenes.',
        'due_date': now.add(const Duration(days: 6)).toIso8601String(),
        'status': 'todo',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
      {
        'title': 'Audio Equipment Check',
        'description': 'Test and set up all audio equipment.',
        'due_date': now.add(const Duration(days: 7)).toIso8601String(),
        'status': 'done',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
      // Filming
      {
        'title': 'Shoot Interview Scenes',
        'description': 'Film all interview segments.',
        'due_date': now.add(const Duration(days: 8)).toIso8601String(),
        'status': 'in_progress',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
      {
        'title': 'Capture B-Roll Footage',
        'description': 'Record B-roll for transitions and context.',
        'due_date': now.add(const Duration(days: 9)).toIso8601String(),
        'status': 'todo',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
      {
        'title': 'Drone Shots',
        'description': 'Capture aerial shots with drone.',
        'due_date': now.add(const Duration(days: 10)).toIso8601String(),
        'status': 'todo',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
      // Post-Production
      {
        'title': 'Video Editing',
        'description': 'Edit all video footage.',
        'due_date': now.add(const Duration(days: 11)).toIso8601String(),
        'status': 'in_progress',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
      {
        'title': 'Color Grading',
        'description': 'Apply color grading to final video.',
        'due_date': now.add(const Duration(days: 12)).toIso8601String(),
        'status': 'todo',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
      {
        'title': 'Sound Mixing',
        'description': 'Mix and master audio tracks.',
        'due_date': now.add(const Duration(days: 13)).toIso8601String(),
        'status': 'todo',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
      // Delivery & Review
      {
        'title': 'Client Review',
        'description': 'Send video to client for review.',
        'due_date': now.add(const Duration(days: 14)).toIso8601String(),
        'status': 'todo',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
      {
        'title': 'Final Export',
        'description': 'Export the final video file.',
        'due_date': now.add(const Duration(days: 15)).toIso8601String(),
        'status': 'todo',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
      {
        'title': 'Upload to Platform',
        'description': 'Upload the video to the chosen platform.',
        'due_date': now.add(const Duration(days: 16)).toIso8601String(),
        'status': 'done',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
    ];
    for (final t in tasks) {
      await db.insert('tasks', t);
    }
  }

  // ── CREATE ─────────────────────────────────────────
  Future<Task> insertTask(Task task) async {
    final db = await database;
    final id = await db.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return task.copyWith(id: id);
  }

  // ── READ ALL ────────────────────────────────────────
  Future<List<Task>> getAllTasks() async {
    final db = await database;
    final maps = await db.query('tasks', orderBy: 'created_at DESC');
    return maps.map(Task.fromMap).toList();
  }

  // ── READ ONE ────────────────────────────────────────
  Future<Task?> getTaskById(int id) async {
    final db = await database;
    final maps = await db.query('tasks', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Task.fromMap(maps.first);
  }

  // ── UPDATE ──────────────────────────────────────────
  Future<Task> updateTask(Task task) async {
    final db = await database;
    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
    return task;
  }

  // ── DELETE ──────────────────────────────────────────
  Future<void> deleteTask(int id) async {
    final db = await database;
    // Clear any tasks blocked by this task
    await db.update(
      'tasks',
      {'blocked_by_id': null},
      where: 'blocked_by_id = ?',
      whereArgs: [id],
    );
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  // ── SEARCH ──────────────────────────────────────────
  Future<List<Task>> searchTasks(String query) async {
    final db = await database;
    final maps = await db.query(
      'tasks',
      where: 'title LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'created_at DESC',
    );
    return maps.map(Task.fromMap).toList();
  }

  // ── FILTER ──────────────────────────────────────────
  Future<List<Task>> getTasksByStatus(TaskStatus status) async {
    final db = await database;
    final maps = await db.query(
      'tasks',
      where: 'status = ?',
      whereArgs: [status.value],
      orderBy: 'created_at DESC',
    );
    return maps.map(Task.fromMap).toList();
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
