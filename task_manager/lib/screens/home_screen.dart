// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/task_card.dart';
import 'task_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  bool _isSearching = false;
  late AnimationController _fabController;
  late Animation<double> _fabScale;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _fabScale = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _fabController, curve: Curves.elasticOut));
    _fabController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks();
    });

    _searchController.addListener(() {
      context.read<TaskProvider>().setSearchQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildFilterRow(),
            Expanded(child: _buildTaskList()),
          ],
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabScale,
        child: FloatingActionButton.extended(
          onPressed: () => _openForm(context),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          icon: const Icon(Icons.add_rounded, size: 22),
          label: const Text(
            'New Task',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Consumer<TaskProvider>(
      builder: (_, provider, __) {
        final total = provider.allTasks.length;
        final done =
            provider.allTasks.where((t) => t.status == TaskStatus.done).length;
        final pct = total == 0 ? 0.0 : done / total;

        return Container(
          color: AppColors.surface,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.task_alt_rounded,
                        color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Task Manager',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              if (total > 0) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatPill('$total', 'Total', AppColors.primary),
                    const SizedBox(width: 8),
                    _buildStatPill(
                        '${provider.allTasks.where((t) => t.status == TaskStatus.todo).length}',
                        'To-Do',
                        AppColors.todo),
                    const SizedBox(width: 8),
                    _buildStatPill(
                        '${provider.allTasks.where((t) => t.status == TaskStatus.inProgress).length}',
                        'Active',
                        AppColors.inProgress),
                    const SizedBox(width: 8),
                    _buildStatPill('$done', 'Done', AppColors.done),
                  ],
                ),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Overall Progress',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${(pct * 100).round()}%',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        backgroundColor: AppColors.primaryLight,
                        valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatPill(String count, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(count,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: color)),
            const SizedBox(height: 1),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    color: color.withOpacity(0.8),
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  // ── Search bar ───────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: TextField(
        controller: _searchController,
        onTap: () => setState(() => _isSearching = true),
        onSubmitted: (_) => setState(() => _isSearching = false),
        decoration: InputDecoration(
          hintText: 'Search tasks...',
          prefixIcon: const Icon(Icons.search_rounded,
              color: AppColors.textSecondary, size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.textSecondary, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    context.read<TaskProvider>().setSearchQuery('');
                  },
                )
              : null,
          fillColor: AppColors.background,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  // ── Filter chips ─────────────────────────────────────────────────────────
  Widget _buildFilterRow() {
    return Consumer<TaskProvider>(
      builder: (_, provider, __) {
        return Container(
          color: AppColors.surface,
          child: Column(
            children: [
              const Divider(height: 1),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    _filterChip(
                        label: 'All',
                        isSelected: provider.activeFilter == null,
                        color: AppColors.primary,
                        onTap: () => provider.clearFilter()),
                    const SizedBox(width: 8),
                    ...TaskStatus.values.map((s) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _filterChip(
                            label: s.label,
                            isSelected: provider.activeFilter == s,
                            color: s.value.statusColor,
                            onTap: () => provider.setFilter(s),
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _filterChip({
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ── Task List ────────────────────────────────────────────────────────────
  Widget _buildTaskList() {
    return Consumer<TaskProvider>(
      builder: (_, provider, __) {
        if (provider.tasks.isEmpty) {
          return _buildEmptyState(provider);
        }

        return RefreshIndicator(
          onRefresh: provider.loadTasks,
          color: AppColors.primary,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: provider.tasks.length,
            itemBuilder: (ctx, i) {
              final task = provider.tasks[i];
              return TaskCard(
                key: ValueKey(task.id),
                task: task,
                searchQuery: provider.searchQuery,
                onTap: () => _openForm(context, task: task),
                onDelete: () => _deleteTask(task),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(TaskProvider provider) {
    final isFiltered = provider.activeFilter != null ||
        provider.searchQuery.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFiltered
                    ? Icons.search_off_rounded
                    : Icons.checklist_rounded,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isFiltered ? 'No results found' : 'No tasks yet',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isFiltered
                  ? 'Try a different search or filter'
                  : 'Tap the button below to create your first task',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            if (!isFiltered) ...[
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: () => _openForm(context),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Create Task'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────
  void _openForm(BuildContext context, {Task? task}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaskFormScreen(task: task),
      ),
    ).then((_) => context.read<TaskProvider>().loadTasks());
  }

  Future<void> _deleteTask(Task task) async {
    final success =
        await context.read<TaskProvider>().deleteTask(task.id!);
    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${task.title} deleted'),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          action: SnackBarAction(
            label: 'Dismiss',
            onPressed: () {},
          ),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
        ),
      );
    }
  }
}
