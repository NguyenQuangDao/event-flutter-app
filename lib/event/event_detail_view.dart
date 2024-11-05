import 'package:event_app/event/event_model.dart';
import 'package:event_app/event/event_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// ignore: must_be_immutable
class EvnetDetailView extends StatefulWidget {
  EventModel event;
  EvnetDetailView({super.key, required this.event});

  @override
  State<EvnetDetailView> createState() => _EvnetDetailViewState();
}

class _EvnetDetailViewState extends State<EvnetDetailView> {
  final subjectControler = TextEditingController();
  final notesControler = TextEditingController();
  final eventService = EventService();

  @override
  void initState() {
    super.initState();
    subjectControler.text = widget.event.subject;
    notesControler.text = widget.event.notes ?? "";
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: isStart ? widget.event.startTime : widget.event.endTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      if (!mounted) return;
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          isStart ? widget.event.startTime : widget.event.endTime,
        ),
      );
      if (pickedTime != null) {
        setState(() {
          final newDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedDate.hour,
            pickedDate.minute,
          );
          if (isStart) {
            widget.event.startTime = newDateTime;
            if (widget.event.startTime.isAfter(widget.event.endTime)) {
              widget.event.endTime.add(Duration(hours: 1));
            }
          } else {
            widget.event.endTime = newDateTime;
          }
        });
      }
    }
  }

  Future<void> _saveEvent() async {
    widget.event.subject = subjectControler.text;
    widget.event.notes = notesControler.text;
    await eventService.saveEvents(widget.event);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _deleteEvent() async {
    await eventService.deleteEvents(widget.event);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final al = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.id == null ? al!.addEvent : al!.eventDetail),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: subjectControler,
              decoration: const InputDecoration(labelText: 'Ten su kien'),
            ),
            SizedBox(height: 16),
            ListTile(
              title: const Text('Su kien ca ngay'),
              trailing: Switch(
                  value: widget.event.isAllDay,
                  onChanged: (value) {
                    setState(() {
                      widget.event.isAllDay = value;
                    });
                  }),
            ),
            if (!widget.event.isAllDay) ...[
              const SizedBox(height: 16),
              ListTile(
                title: Text('Bat dau: ${widget.event.fomatedStartTimeString}'),
                trailing: Icon(Icons.today_outlined),
                onTap: () => _pickDateTime(isStart: true),
              ),
              // const SizedBox(height: 16),
              ListTile(
                title: Text('Ket thuc: ${widget.event.fomatedEndTimeString}'),
                trailing: Icon(Icons.today_outlined),
                onTap: () => _pickDateTime(isStart: false),
              ),
              TextField(
                controller: notesControler,
                decoration: const InputDecoration(labelText: 'Ghi chu su kien'),
                maxLines: 3,
              ),
              SizedBox(
                height: 24,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (widget.event.id != null)
                    FilledButton.tonalIcon(
                        onPressed: _deleteEvent,
                        label: const Text('Xoa su kien')),
                  FilledButton.tonalIcon(
                      onPressed: _saveEvent, label: const Text('Luu su kien')),
                ],
              )
            ]
          ],
        ),
      ),
    );
  }
}
