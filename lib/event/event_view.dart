import 'package:event_app/event/event_data_souce.dart';
import 'package:event_app/event/event_detail_view.dart';
import 'package:event_app/event/event_model.dart';
import 'package:event_app/event/event_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class EventView extends StatefulWidget {
  const EventView({super.key});

  @override
  State<EventView> createState() => _EventViewState();
}

class _EventViewState extends State<EventView> {
  final eventService = EventService();
  List<EventModel> listItems = [];
  final calendarController = CalendarController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    calendarController.view = CalendarView.day;
  }

  Future<void> loadEvent() async {
    final events = await eventService.getAllEvents();
    setState(() {
      listItems = events;
    });
  }

  @override
  Widget build(BuildContext context) {
    final al = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(al!.appTitle),
        actions: [
          PopupMenuButton(
            onSelected: (value) {
              setState(() {
                calendarController.view = value;
              });
            },
            itemBuilder: (context) => CalendarView.values.map((view) {
              return PopupMenuItem<CalendarView>(
                  value: view,
                  child: ListTile(
                    title: Text(view.name),
                  ));
            }).toList(),
            icon: getCalendarViewIcon(calendarController.view!),
          ),
          IconButton(
            onPressed: () {
              calendarController.displayDate = DateTime.now();
            },
            icon: Icon(Icons.today_outlined),
          ),
          IconButton(
            onPressed: loadEvent,
            icon: Icon(Icons.refresh),
          )
        ],
      ),
      body: SfCalendar(
        controller: calendarController,
        view: CalendarView.month,
        dataSource: EventDataSouce(listItems),
        monthViewSettings: MonthViewSettings(
          appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
        ),
        onLongPress: (details) {
          if (details.targetElement == CalendarElement.calendarCell) {
            final newEvent = EventModel(
              startTime: details.date!,
              endTime: details.date!.add(Duration(hours: 1)),
              subject: 'Su kien moi',
            );
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) {
                return EvnetDetailView(event: newEvent);
              },
            )).then((value) async {
              if (value) {
                await loadEvent();
              }
            });
          }
        },
        onTap: (details) {
          if (details.targetElement == CalendarElement.calendarCell) {
            final EventModel event = details.appointments!.first;
            print(event);
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) {
                return EvnetDetailView(event: event);
              },
            )).then((value) async {
              if (value) {
                await loadEvent();
              }
            });
          }
        },
      ),
    );
  }

  Icon getCalendarViewIcon(CalendarView view) {
    switch (view) {
      case CalendarView.day:
        return const Icon(Icons.calendar_view_day_outlined);
      case CalendarView.week:
        return const Icon(Icons.view_week_outlined);
      case CalendarView.workWeek:
        return const Icon(Icons.work_outline);
      case CalendarView.month:
        return const Icon(Icons.calendar_month_outlined);
      case CalendarView.timelineDay:
        return const Icon(Icons.timeline);
      case CalendarView.timelineWeek:
        return const Icon(Icons.view_timeline_outlined);
      case CalendarView.timelineWorkWeek:
        return const Icon(Icons.work_history_outlined);
      case CalendarView.timelineMonth:
        return const Icon(Icons.date_range_outlined);
      case CalendarView.schedule:
        return const Icon(Icons.schedule_outlined);
    }
  }
}
