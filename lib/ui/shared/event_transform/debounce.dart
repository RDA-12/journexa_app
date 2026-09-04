import 'package:bloc/bloc.dart';
import 'package:stream_transform/stream_transform.dart';

/// Default debounce duration
const kDefaultDebounceDuration = Duration(milliseconds: 300);

/// Debounces events by emitting the latest event after a specified [duration]
EventTransformer<Event> debounce<Event>({
  Duration duration = kDefaultDebounceDuration,
}) {
  return (events, mapper) => events.debounce(duration).switchMap(mapper);
}
