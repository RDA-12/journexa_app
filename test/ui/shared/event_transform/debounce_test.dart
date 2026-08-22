import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/ui/shared/event_transform/debounce.dart';

import 'helpers.dart';

void main() {
  test(
    'emits only last value if events are fired within duration',
    () async {
      const debounceDuration = Duration(milliseconds: 100);
      final states = <int>[];
      final bloc = CounterBloc(debounce(duration: debounceDuration))
        ..stream.listen(states.add);
      final events = [Increment(), Increment(), Increment()];

      /// Simulates multiple events occurred rapidly
      for (final event in events) {
        bloc.add(event);
        await wait(const Duration(milliseconds: 1));
      }

      /// Waits for last event debounce duration finished
      await wait(debounceDuration);

      /// Allowing dart to flush pending microtasks
      await tick();

      expect(bloc.onCalls, [Increment()]);
      expect(states, <int>[]);

      // Allowing the event to be processed
      await wait(kProcessingTime);
      expect(bloc.onEmitCalls, [Increment()]);
      expect(states, [1]);
    },
  );
}
