import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/user.dart';
import 'package:journexa_app/domain/repositories/i_auth_repository.dart';
import 'package:journexa_app/domain/use_cases/auth/watch_user.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository;

void main() {
  const traceId = 'traceId';
  const user = User(
    id: 'user-123',
    name: 'Test User',
    email: 'test@example.com',
    photoUrl: 'https://example.com/photo.png',
  );

  late IAuthRepository mockAuthRepository;
  late WatchUserUseCase useCase;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    when(
      () => mockAuthRepository.watchUser(traceId: traceId),
    ).thenAnswer((_) => Stream.value(const AppResult.success(user)));

    useCase = WatchUserUseCase(
      authRepository: mockAuthRepository,
    );
  });

  test(
    'calls AuthRepository.watchUser once with correct args',
    () async {
      final result = useCase.execute(traceId: traceId);
      await result.first;

      verify(
        () => mockAuthRepository.watchUser(traceId: traceId),
      ).called(1);
    },
  );

  test(
    'emits correct user when authenticated',
    () async {
      final result = useCase.execute(traceId: traceId);

      expect(result, emits(const AppResult<User?>.success(user)));
    },
  );

  test(
    'emits null user when unauthenticated',
    () async {
      when(
        () => mockAuthRepository.watchUser(traceId: traceId),
      ).thenAnswer((_) => Stream.value(const AppResult.success(null)));

      final result = useCase.execute(traceId: traceId);

      expect(result, emits(const AppResult<User?>.success(null)));
    },
  );

  test(
    'emits failure when AuthRepository.watchUser emits failure',
    () async {
      when(
        () => mockAuthRepository.watchUser(traceId: traceId),
      ).thenAnswer(
        (_) => Stream.value(
          AppResult<User?>.failure(
            AppException.test(),
          ),
        ),
      );

      final result = useCase.execute(traceId: traceId);

      expect(
        result,
        emits(
          AppResult<User?>.failure(
            AppException.test(),
          ),
        ),
      );
    },
  );
}
