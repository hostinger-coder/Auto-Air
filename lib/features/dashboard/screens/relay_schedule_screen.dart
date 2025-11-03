// ===== lib/features/dashboard/screens/relay_schedule_screen.dart =====

import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:AutoAir/features/dashboard/models/relay_model.dart';
import 'package:AutoAir/features/dashboard/models/schedule_model.dart';
import 'package:AutoAir/widgets/app_background.dart';

class RelayScheduleScreen extends StatefulWidget {
  const RelayScheduleScreen({Key? key}) : super(key: key);

  @override
  State<RelayScheduleScreen> createState() => _RelayScheduleScreenState();
}

class _RelayScheduleScreenState extends State<RelayScheduleScreen> {
  late List<RelaySchedule> _schedules;
  int _filterIndex = 0;

  @override
  void initState() {
    super.initState();
    _schedules = List.generate(
      10,
          (index) => RelaySchedule(
        id: index + 1,
        title: 'Schedule ${index + 1}',
        timeRange: '12:00 AM — 12:00 AM',
        days: 'Mon • Tue • Wed • Thu • Fri',
        isActive: index.isEven,
      ),
    );
  }

  List<RelaySchedule> get _visible {
    if (_filterIndex == 1) return _schedules.where((s) => s.isActive).toList();
    if (_filterIndex == 2) return _schedules.where((s) => !s.isActive).toList();
    return _schedules;
  }

  @override
  Widget build(BuildContext context) {
    final relay = ModalRoute.of(context)!.settings.arguments as Relay;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Schedules',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.help_outline, color: isDark ? Colors.white70 : Colors.black54),
              onPressed: () => _showHowItWorks(context),
            ),
            const SizedBox(width: 6),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openEditor(context),
          label: const Text('Add Schedule'),
          icon: const Icon(Icons.add),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          children: [
            _HeaderCard(relayName: relay.name, onAdd: () => _openEditor(context)),
            const SizedBox(height: 16),
            _FilterChips(
              index: _filterIndex,
              onChanged: (i) => setState(() => _filterIndex = i),
            ),
            const SizedBox(height: 8),
            if (_visible.isEmpty)
              _EmptyState(onAdd: () => _openEditor(context))
            else
              ..._visible.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ScheduleCard(
                  schedule: s,
                  onToggle: (v) => setState(() => s.isActive = v),
                  onEdit: () => _openEditor(context, s),
                  onMore: () => _showItemMenu(context, s),
                ),
              )),
          ],
        ),
      ),
    );
  }

  void _openEditor(BuildContext context, [RelaySchedule? schedule]) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return _ScheduleEditor(schedule: schedule);
      },
    );
  }

  void _showItemMenu(BuildContext context, RelaySchedule s) async {
    final selected = await showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(1000, 100, 16, 0),
      color: const Color(0xFF2A2A2C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: const [
        PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
        PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
    );
    if (selected == 'duplicate') {
      setState(() {
        _schedules.add(RelaySchedule(
          id: _schedules.length + 1,
          title: '${s.title} (copy)',
          timeRange: s.timeRange,
          days: s.days,
          isActive: s.isActive,
        ));
      });
    } else if (selected == 'delete') {
      setState(() => _schedules.removeWhere((x) => x.id == s.id));
    }
  }

  void _showHowItWorks(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('How schedules work'),
        content: const Text(
          'Create one or more time ranges and choose the days. '
              'Active schedules will toggle the relay automatically.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Got it')),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.relayName, required this.onAdd});
  final String relayName;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E).withOpacity(0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [theme.colorScheme.primary, theme.colorScheme.primary.withOpacity(0.2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(Icons.flash_on, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Relay', style: theme.textTheme.labelMedium?.copyWith(color: Colors.white70)),
                    Text(
                      relayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: onAdd,
                style: TextButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.14),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.index, required this.onChanged});
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = const ['All', 'Active', 'Inactive'];
    return Wrap(
      spacing: 8,
      children: List.generate(items.length, (i) {
        final selected = i == index;
        return ChoiceChip(
          label: Text(items[i]),
          selected: selected,
          onSelected: (_) => onChanged(i),
          labelStyle: TextStyle(
            color: selected ? Colors.black : Colors.white,
            fontWeight: FontWeight.w600,
          ),
          selectedColor: Colors.white,
          backgroundColor: const Color(0xFF2A2A2C),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        );
      }),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({
    required this.schedule,
    required this.onToggle,
    required this.onEdit,
    required this.onMore,
  });

  final RelaySchedule schedule;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = schedule.isActive;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E).withOpacity(0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: active ? theme.colorScheme.primary.withOpacity(0.45) : Colors.white.withOpacity(0.1),
              width: 1.2,
            ),
            boxShadow: active
                ? [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.25),
                blurRadius: 18,
                spreadRadius: 0.5,
                offset: const Offset(0, 6),
              )
            ]
                : [],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Bullet(active: active),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            schedule.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: onMore,
                          icon: const Icon(Icons.more_horiz, color: Colors.white70),
                          splashRadius: 18,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.schedule, size: 16, color: Colors.white70),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            schedule.timeRange,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 14, color: Colors.white54),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            schedule.days,
                            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: onEdit,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.white.withOpacity(0.12)),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Edit'),
                        ),
                        const Spacer(),
                        Switch(
                          value: active,
                          onChanged: onToggle,
                          activeColor: Colors.white,
                          activeTrackColor: Theme.of(context).colorScheme.primary,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? Theme.of(context).colorScheme.primary : Colors.white24;
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: active
            ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 10, spreadRadius: 1)]
            : [],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 24, 18, 24),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E).withOpacity(0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              const Icon(Icons.event_busy, size: 36, color: Colors.white54),
              const SizedBox(height: 10),
              const Text('No schedules yet', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              const Text(
                'Create your first automation to turn the relay on/off at specific times.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: const Text('Add Schedule'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScheduleEditor extends StatefulWidget {
  const _ScheduleEditor({this.schedule});
  final RelaySchedule? schedule;

  @override
  State<_ScheduleEditor> createState() => _ScheduleEditorState();
}

class _ScheduleEditorState extends State<_ScheduleEditor> {
  late TextEditingController _titleController;
  int _scheduleTypeIndex = 0; // 0 for Recurring, 1 for One-Time
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 18, minute: 0);
  final Set<String> _selectedDays = {'Mon', 'Wed', 'Fri'};

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.schedule?.title ?? 'New Schedule');
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickTime(BuildContext context, bool isStartTime) async {
    final initialTime = isStartTime ? _startTime : _endTime;
    final newTime = await showTimePicker(context: context, initialTime: initialTime);
    if (newTime != null) {
      setState(() {
        if (isStartTime) {
          _startTime = newTime;
        } else {
          _endTime = newTime;
        }
      });
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 16),
      child: Text(
        title,
        style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E).withOpacity(0.85),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  widget.schedule == null ? 'New Schedule' : 'Edit Schedule',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 12),
              _buildSectionHeader('Title'),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(hintText: 'e.g., Weekday Operation'),
              ),
              _buildSectionHeader('Type'),
              SizedBox(
                width: double.infinity,
                child: CupertinoSlidingSegmentedControl<int>(
                  groupValue: _scheduleTypeIndex,
                  backgroundColor: Colors.black26,
                  thumbColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.all(4),
                  children: const {
                    0: Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Recurring')),
                    1: Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('One-Time')),
                  },
                  onValueChanged: (value) => setState(() => _scheduleTypeIndex = value ?? 0),
                ),
              ),
              if (_scheduleTypeIndex == 0) ...[
                _buildSectionHeader('Days'),
                _DaySelector(
                  selectedDays: _selectedDays,
                  onDaySelected: (day) {
                    setState(() {
                      if (_selectedDays.contains(day)) {
                        _selectedDays.remove(day);
                      } else {
                        _selectedDays.add(day);
                      }
                    });
                  },
                ),
              ],
              _buildSectionHeader('Time Range'),
              Row(
                children: [
                  Expanded(child: _TimePickerField(time: _startTime, onTap: () => _pickTime(context, true))),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('to', style: TextStyle(color: Colors.white70)),
                  ),
                  Expanded(child: _TimePickerField(time: _endTime, onTap: () => _pickTime(context, false))),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Save Changes'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('Add Reminder'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimePickerField extends StatelessWidget {
  const _TimePickerField({required this.time, required this.onTap});
  final TimeOfDay time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white12),
        ),
        child: Center(
          child: Text(
            time.format(context),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class _DaySelector extends StatelessWidget {
  const _DaySelector({required this.selectedDays, required this.onDaySelected});
  final Set<String> selectedDays;
  final ValueChanged<String> onDaySelected;

  @override
  Widget build(BuildContext context) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((day) {
        final isSelected = selectedDays.contains(day);
        return GestureDetector(
          onTap: () => onDaySelected(day),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? Theme.of(context).colorScheme.primary : Colors.black26,
              border: Border.all(color: isSelected ? Colors.transparent : Colors.white12),
            ),
            child: Center(
              child: Text(
                day.substring(0, 1),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}