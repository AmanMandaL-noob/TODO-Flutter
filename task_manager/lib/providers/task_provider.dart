// ...existing code...
// lib/providers/task_provider.dart

import 'package:flutter/foundation.dart';
// import '../database/database_helper.dart';
import '../models/task.dart';

class TaskProvider extends ChangeNotifier {
  // In-memory cache for tasks
  List<Task> _allTasks = [
    // Pre-Production
    Task(
      id: 1,
      title: 'Script Writing',
      description: 'Write the script for the video project.',
      dueDate: DateTime.now().add(const Duration(days: 2)),
      status: TaskStatus.done,
      blockedById: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Task(
      id: 2,
      title: 'Storyboarding',
      description: 'Create storyboards for each scene.',
      dueDate: DateTime.now().add(const Duration(days: 3)),
      status: TaskStatus.inProgress,
      blockedById: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Task(
      id: 3,
      title: 'Location Scouting',
      description: 'Scout and finalize filming locations.',
      dueDate: DateTime.now().add(const Duration(days: 4)),
      status: TaskStatus.todo,
      blockedById: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    // Equipment & Setup
    Task(
      id: 4,
      title: 'Camera Setup',
      description: 'Set up cameras and check settings.',
      dueDate: DateTime.now().add(const Duration(days: 5)),
      status: TaskStatus.done,
      blockedById: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Task(
      id: 5,
      title: 'Lighting Arrangement',
      description: 'Arrange lighting for all scenes.',
      dueDate: DateTime.now().add(const Duration(days: 6)),
      status: TaskStatus.todo,
      blockedById: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Task(
      id: 6,
      title: 'Audio Equipment Check',
      description: 'Test and set up all audio equipment.',
      dueDate: DateTime.now().add(const Duration(days: 7)),
      status: TaskStatus.done,
      blockedById: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    // Filming
    Task(
      id: 7,
      title: 'Shoot Interview Scenes',
      description: 'Film all interview segments.',
      dueDate: DateTime.now().add(const Duration(days: 8)),
      status: TaskStatus.inProgress,
      blockedById: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Task(
      id: 8,
      title: 'Capture B-Roll Footage',
      description: 'Record B-roll for transitions and context.',
      dueDate: DateTime.now().add(const Duration(days: 9)),
      status: TaskStatus.todo,
      blockedById: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Task(
      id: 9,
      title: 'Drone Shots',
      description: 'Capture aerial shots with drone.',
      dueDate: DateTime.now().add(const Duration(days: 10)),
      status: TaskStatus.todo,
      blockedById: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    // Post-Production
    Task(
      id: 10,
      title: 'Video Editing',
      description: 'Edit all video footage.',
      dueDate: DateTime.now().add(const Duration(days: 11)),
      status: TaskStatus.inProgress,
      blockedById: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Task(
      id: 11,
      title: 'Color Grading',
      description: 'Apply color grading to final video.',
      dueDate: DateTime.now().add(const Duration(days: 12)),
      status: TaskStatus.todo,
      blockedById: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Task(
      id: 12,
      title: 'Sound Mixing',
      description: 'Mix and master audio tracks.',
      dueDate: DateTime.now().add(const Duration(days: 13)),
      status: TaskStatus.todo,
      blockedById: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    // Delivery & Review
    Task(
      id: 13,
      title: 'Client Review',
      description: 'Send video to client for review.',
      dueDate: DateTime.now().add(const Duration(days: 14)),
      status: TaskStatus.todo,
      blockedById: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Task(
      id: 14,
      title: 'Final Export',
      description: 'Export the final video file.',
      dueDate: DateTime.now().add(const Duration(days: 15)),
      status: TaskStatus.todo,
      blockedById: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Task(
      id: 15,
      title: 'Upload to Platform',
      description: 'Upload the video to the chosen platform.',
      dueDate: DateTime.now().add(const Duration(days: 16)),
      status: TaskStatus.done,
      blockedById: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];
  List<Task> _filteredTasks = [];
  TaskStatus? _activeFilter;
  String _searchQuery = '';
  bool _isSaving = false;

  List<Task> get tasks => _filteredTasks;
  List<Task> get allTasks => _allTasks;
  TaskStatus? get activeFilter => _activeFilter;
  String get searchQuery => _searchQuery;
  bool get isSaving => _isSaving;

  // ── LOAD ──────────────────────────────────────────────
  Future<void> loadTasks() async {
    _applyFilters();
    notifyListeners();
  }

  // ── CREATE ────────────────────────────────────────────
  Future<bool> createTask(Task task) async {
    _isSaving = true;
    notifyListeners();
    try {
      await Future.delayed(const Duration(seconds: 2));
      final newTask = task.copyWith(
          id: _allTasks.isEmpty
              ? 1
              : (_allTasks
                      .map((t) => t.id ?? 0)
                      .reduce((a, b) => a > b ? a : b) +
                  1));
      _allTasks.insert(0, newTask);
      _applyFilters();
      return true;
    } catch (e) {
      debugPrint('Error creating task: $e');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // ── UPDATE ────────────────────────────────────────────
  Future<bool> updateTask(Task task) async {
    _isSaving = true;
    notifyListeners();
    try {
      await Future.delayed(const Duration(seconds: 2));
      final idx = _allTasks.indexWhere((t) => t.id == task.id);
      if (idx != -1) {
        _allTasks[idx] = task.copyWith(updatedAt: DateTime.now());
        _applyFilters();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating task: $e');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // ── DELETE ────────────────────────────────────────────
  Future<bool> deleteTask(int id) async {
    try {
      // Remove blocked_by_id references
      for (var i = 0; i < _allTasks.length; i++) {
        if (_allTasks[i].blockedById == id) {
          _allTasks[i] = _allTasks[i].copyWith(blockedById: null);
        }
      }
      _allTasks.removeWhere((t) => t.id == id);
      _applyFilters();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting task: $e');
      return false;
    }
  }

  // ── SEARCH ────────────────────────────────────────────
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // ── FILTER ────────────────────────────────────────────
  void setFilter(TaskStatus? status) {
    _activeFilter = status;
    _applyFilters();
    notifyListeners();
  }

  void clearFilter() {
    _activeFilter = null;
    _applyFilters();
    notifyListeners();
  }

  // ── HELPER: is a task actually blocked (blocker not done) ──
  bool isTaskEffectivelyBlocked(Task task) {
    if (task.blockedById == null) return false;
    final blocker = _allTasks.firstWhere(
      (t) => t.id == task.blockedById,
      orElse: () => task.copyWith(blockedById: null),
    );
    // Only blocked if the blocker task exists and is NOT done
    return blocker.id != null && blocker.status != TaskStatus.done;
  }

  Task? getTaskById(int id) {
    try {
      return _allTasks.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── INTERNAL FILTER LOGIC ─────────────────────────────
  void _applyFilters() {
    var result = _allTasks;

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((t) => t.title.toLowerCase().contains(q)).toList();
    }

    if (_activeFilter != null) {
      result = result.where((t) => t.status == _activeFilter).toList();
    }

    _filteredTasks = result;
  }
}
