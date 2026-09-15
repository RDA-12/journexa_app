import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

sealed class CounterEvent;

@immutable
class Increment extends CounterEvent {
  @override
  bool operator ==(Object value) {
    if (identical(this, value)) return true;
    return value is Increment;
  }

  @override
  int get hashCode => 0;
}

/// [Duration] for dummy event handler finished
const kProcessingTime = Duration(milliseconds: 30);

/// Wait for [duration]
Future<void> wait(Duration duration) => Future.delayed(duration);

/// Allows pending microtask to run. Such as, flushing pending streams
Future<void> tick() => Future.delayed(Duration.zero);

/// Counter bloc for testing
class CounterBloc extends Bloc<CounterEvent, int> {
  /// Creates [CounterBloc] with [transformer]
  new(EventTransformer<Increment> transformer) : super(0) {
    on<Increment>(
      (event, emit) {
        onCalls.add(event);
        return Future<void>.delayed(kProcessingTime, () {
          if (emit.isDone) return;
          onEmitCalls.add(event);
          emit(state + 1);
        });
      },
      transformer: transformer,
    );
  }

  /// List of events processed by event handler
  final onCalls = <CounterEvent>[];

  /// List of state emitted to stream after processed by handler
  final onEmitCalls = <CounterEvent>[];
}
