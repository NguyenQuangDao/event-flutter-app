import 'package:event_app/event/event_model.dart';
import 'package:localstore/localstore.dart';

class EventService {
  final db = Localstore.getInstance(useSupportDir: true);
  final path = 'events';

  // get event in localstore
  Future<List<EventModel>> getAllEvents() async {
    final eventsMap = await db.collection(path).get();
    if (eventsMap != null) {
      return eventsMap.entries.map((entry) {
        final eventData = entry.value as Map<String, dynamic>;
        if (!eventData.containsKey('id')) {
          eventData['id'] = entry.key.split('/').last;
        }
        return EventModel.fromMap(eventData);
      }).toList();
    }
    return [];
  }

  // save event to localstore
  Future<void> saveEvents(EventModel item) async {
    item.id ??= db.collection(path).doc().id;
    await db.collection(path).doc(item.id).set(item.toMap());
  }

  // delete event in localstore
  Future<void> deleteEvents(EventModel item) async {
    await db.collection(path).doc(item.id).delete();
  }
}
