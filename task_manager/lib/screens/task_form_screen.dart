// lib/screens/task_form_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/status_chip.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task;

  const TaskFormScreen({super.key, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  late TaskStatus _selectedStatus;
  late DateTime _selectedDate;
  int? _selectedBlockedById;

  bool _isSaving = false;
  bool _draftLoaded = false;

  static const _draftPrefix = 'draft_task_';

  bool get _isEditing => widget.task != null;

  String get _draftKey =>
      _isEditing ? '${_draftPrefix}edit_${widget.task!.id}' : '${_draftPrefix}new';

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.task?.status ?? TaskStatus.todo;
    _selectedDate = widget.task?.dueDate ?? DateTime.now().add(const Duration(days: 1));
    _selectedBlockedById = widget.task?.blockedById;

    if (_isEditing) {
      _titleController.text = widget.task!.title;
      _descController.text = widget.task!.description;
    }

    // Load draft after frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDraft());

    // Save draft on changes
    _titleController.addListener(_saveDraft);
    _descController.addListener(_saveDraft);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // ── Draft persistence ────────────────────────────────────────────────────
  Future<void> _saveDraft() async {
    if (!_draftLoaded) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_draftKey}_title', _titleController.text);
    await prefs.setString('${_draftKey}_desc', _descController.text);
    await prefs.setString('${_draftKey}_status', _selectedStatus.value);
    await prefs.setString('${_draftKey}_date', _selectedDate.toIso8601String());
    if (_selectedBlockedById != null) {
      await prefs.setInt('${_draftKey}_blocked', _selectedBlockedById!);
    } else {
      await prefs.remove('${_draftKey}_blocked');
    }
  }

  Future<void> _loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final draftTitle = prefs.getString('${_draftKey}_title');

    // Only load draft for new tasks OR if draft title differs (edit draft)
    if (draftTitle != null && draftTitle.isNotEmpty) {
      final hasDraft = !_isEditing ||
          (draftTitle != widget.task!.title ||
              prefs.getString('${_draftKey}_desc') != widget.task!.description);

      if (hasDraft) {
        final confirm = await _showDraftDialog();
        if (confirm == true) {
          setState(() {
            _titleController.text = draftTitle;
            _descController.text =
                prefs.getString('${_draftKey}_desc') ?? _descController.text;
            final statusStr = prefs.getString('${_draftKey}_status');
            if (statusStr != null) {
              _selectedStatus = TaskStatus.fromString(statusStr);
            }
            final dateStr = prefs.getString('${_draftKey}_date');
            if (dateStr != null) {
              _selectedDate = DateTime.parse(dateStr);
            }
            _selectedBlockedById = prefs.getInt('${_draftKey}_blocked');
          });
        } else {
          await _clearDraft();
        }
      }
    }

    setState(() => _draftLoaded = true);
  }

  Future<bool?> _showDraftDialog() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.save_outlined, color: AppColors.primary, size: 22),
            SizedBox(width: 8),
            Text('Unsaved Draft',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
          ],
        ),
        content: const Text(
          'You have an unsaved draft. Would you like to restore it?',
          style: TextStyle(color: AppColors.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Discard'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${_draftKey}_title');
    await prefs.remove('${_draftKey}_desc');
    await prefs.remove('${_draftKey}_status');
    await prefs.remove('${_draftKey}_date');
    await prefs.remove('${_draftKey}_blocked');
  }

  // ── Save ─────────────────────────────────────────────────────────────────
  Future<void> _save() async {
    if (_isSaving) return; // Prevent double-click
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final provider = context.read<TaskProvider>();
    final now = DateTime.now();

    final task = Task(
      id: widget.task?.id,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      dueDate: _selectedDate,
      status: _selectedStatus,
      blockedById: _selectedBlockedById,
      createdAt: widget.task?.createdAt ?? now,
      updatedAt: now,
    );

    bool success;
    if (_isEditing) {
      success = await provider.updateTask(task);
    } else {
      success = await provider.createTask(task);
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      await _clearDraft();
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Task updated!' : 'Task created!'),
          backgroundColor: AppColors.done,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
          backgroundColor: AppColors.overdue,
        ),
      );
    }
  }

  // ── UI ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) {
        if (didPop) _saveDraft();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        _isEditing ? 'Edit Task' : 'New Task',
        style: const TextStyle(
            fontWeight: FontWeight.w700, letterSpacing: -0.3),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        onPressed: () {
          _saveDraft();
          Navigator.pop(context);
        },
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: AppColors.primary),
                )
              : TextButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: Text(_isEditing ? 'Update' : 'Save'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
        ),
      ],
      bottom: _isSaving
          ? PreferredSize(
              preferredSize: const Size.fromHeight(3),
              child: LinearProgressIndicator(
                backgroundColor: AppColors.primaryLight,
                valueColor:
                    const AlwaysStoppedAnimation(AppColors.primary),
              ),
            )
          : null,
    );
  }

  Widget _buildBody() {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title card
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('Task Title *'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      enabled: !_isSaving,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Design the landing page',
                        prefixIcon: Icon(Icons.title_rounded,
                            color: AppColors.textSecondary, size: 20),
                      ),
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w500),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Title is required';
                        }
                        if (val.trim().length < 3) {
                          return 'Title must be at least 3 characters';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    _sectionLabel('Description'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descController,
                      enabled: !_isSaving,
                      decoration: const InputDecoration(
                        hintText: 'Add a description...',
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(bottom: 50),
                          child: Icon(Icons.notes_rounded,
                              color: AppColors.textSecondary, size: 20),
                        ),
                      ),
                      style: const TextStyle(fontSize: 14, height: 1.5),
                      maxLines: 3,
                      minLines: 2,
                      textInputAction: TextInputAction.done,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Due Date
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('Due Date *'),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _isSaving ? null : _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(0xFFE2E8F0), width: 1.5),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month_rounded,
                                color: AppColors.primary, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              DateFormat('EEEE, MMMM d, yyyy')
                                  .format(_selectedDate),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.chevron_right_rounded,
                                color: AppColors.textSecondary, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Status
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('Status'),
                    const SizedBox(height: 10),
                    Row(
                      children: TaskStatus.values.map((s) {
                        final isSelected = _selectedStatus == s;
                        final color = s.value.statusColor;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                                right: s != TaskStatus.done ? 8 : 0),
                            child: GestureDetector(
                              onTap: _isSaving
                                  ? null
                                  : () => setState(() => _selectedStatus = s),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 6),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? color.withOpacity(0.1)
                                      : AppColors.background,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected
                                        ? color
                                        : const Color(0xFFE2E8F0),
                                    width: isSelected ? 2 : 1.5,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    StatusChip(status: s, small: true),
                                    if (isSelected) ...[
                                      const SizedBox(height: 4),
                                      Icon(Icons.check_circle_rounded,
                                          color: color, size: 14),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Blocked By
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _sectionLabel('Blocked By'),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.todoLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Optional',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.todo,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'This task cannot start until the selected task is done.',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.4),
                    ),
                    const SizedBox(height: 10),
                    _buildBlockedByPicker(),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isSaving ? AppColors.primaryLight : AppColors.primary,
                  ),
                  child: _isSaving
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.primary),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Saving...',
                              style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15),
                            ),
                          ],
                        )
                      : Text(
                          _isEditing ? 'Update Task' : 'Create Task',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildBlockedByPicker() {
    return Consumer<TaskProvider>(
      builder: (_, provider, __) {
        // Exclude current task and tasks that are already done
        final eligible = provider.allTasks.where((t) {
          if (t.id == widget.task?.id) return false;
          return true;
        }).toList();

        if (eligible.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Text(
              'No other tasks available to block this task.',
              style:
                  TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          );
        }

        return Column(
          children: [
            // Clear selection
            if (_selectedBlockedById != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedBlockedById = null),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.overdueLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.overdue.withOpacity(0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.close_rounded,
                            size: 14, color: AppColors.overdue),
                        SizedBox(width: 6),
                        Text('Clear dependency',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.overdue,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
            Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int?>(
                  value: _selectedBlockedById,
                  isExpanded: true,
                  hint: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('Select a blocking task',
                        style: TextStyle(
                            color: AppColors.textDisabled, fontSize: 14)),
                  ),
                  borderRadius: BorderRadius.circular(12),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  items: eligible.map((t) {
                    return DropdownMenuItem<int?>(
                      value: t.id,
                      child: Row(
                        children: [
                          StatusChip(status: t.status, small: true),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              t.title,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: _isSaving
                      ? null
                      : (val) =>
                          setState(() => _selectedBlockedById = val),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _saveDraft();
    }
  }
}
