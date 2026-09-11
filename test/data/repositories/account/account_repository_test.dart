import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/data/database.dart';
import 'package:journexa_app/data/repositories/account/account.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/repositories/i_account_repository.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

void main() {
  const traceId = 'trace';
  final parent = SystemDefinedAccount.walletParent;
  final initialAccounts = [
    parent,
    Account.sub(
      parent: parent,
      name: 'Dompet Hitam',
      currentChildrenCount: 0,
    ),
    Account.sub(
      parent: parent,
      name: 'Bank BRI',
      currentChildrenCount: 1,
    ),
  ];
  final accounts = [
    Account.sub(
      parent: parent,
      name: 'Bank Jago',
      currentChildrenCount: 2,
    ),
  ];

  late AppLocalDatabase db;
  late IAccountRepository repository;

  setUp(() async {
    db = AppLocalDatabase.test();
    for (final account in initialAccounts) {
      await db.into(db.accountDB).insert(account.toDB());
    }
    repository = DriftAccountRepository(db: db);
  });

  tearDown(() async {
    await db.accountDB.delete().go();
    await db.close();
  });

  group('ensureSaved', () {
    test(
      'returns success when all accounts saved',
      () async {
        final result = await repository.ensureSaved(
          accounts: accounts,
          traceId: traceId,
        );

        expect(result, const AppResult.success(null));

        final parentDB = db.alias(db.accountDB, 'parent');
        final data = await db.select(db.accountDB).join([
          leftOuterJoin(
            parentDB,
            db.accountDB.parentCode.equalsExp(parentDB.code),
          ),
        ]).get();
        final dbAccounts = <Account>[];
        for (final item in data) {
          final accountData = item.readTable(db.accountDB);
          final parentData = item.readTableOrNull(parentDB);
          dbAccounts.add(
            accountData.toDomain(parent: parentData?.toDomain()),
          );
        }

        expect(
          dbAccounts,
          [
            ...initialAccounts,
            ...accounts,
          ],
        );
      },
    );

    test(
      'returns failure with internalException code '
      'when drift throw DriftWrappedException',
      () async {
        whenCalling(
          Invocation.method(#ensureSaved, null),
        ).on(repository).thenThrow(DriftWrappedException(message: ''));

        final result = await repository.ensureSaved(
          accounts: accounts,
          traceId: traceId,
        );

        expect(
          result,
          isA<AppResultFailure<Null>>().having(
            (e) => e.error.code,
            'error.code',
            AppExceptionCode.internalException,
          ),
        );
      },
    );

    test(
      'returns failure with internalException '
      'when unexpected Exception thrown',
      () async {
        whenCalling(
          Invocation.method(#ensureSaved, null),
        ).on(repository).thenThrow(Exception('exeption'));

        final result = await repository.ensureSaved(
          accounts: accounts,
          traceId: traceId,
        );

        expect(
          result,
          isA<AppResultFailure<Null>>().having(
            (e) => e.error.code,
            'error.code',
            AppExceptionCode.internalException,
          ),
        );
      },
    );
  });

  group('getChildrenCountByParentCode', () {
    final parent = initialAccounts[0];

    test(
      'returns success with correct count '
      'when get children count by parent code',
      () async {
        const expectedChildrenCount = 5;
        for (var i = 1; i <= expectedChildrenCount; i++) {
          final child = Account.sub(
            name: 'child $i',
            parent: parent,
            currentChildrenCount: 3 + i,
          );
          await db.into(db.accountDB).insert(child.toDB());
        }

        final result = await repository.getChildrenCountByParentCode(
          parentCode: parent.code.value,
          traceId: traceId,
        );

        expect(
          result,
          AppResult.success(
            expectedChildrenCount + initialAccounts.length - 1,
          ),
        );
      },
    );

    test(
      'returns failure with internalException code '
      'when drift throws DriftWrappedException',
      () async {
        whenCalling(Invocation.method(#getChildrenCountByParentCode, null))
            .on(repository)
            .thenThrow(
              DriftWrappedException(message: ''),
            );

        final result = await repository.getChildrenCountByParentCode(
          parentCode: parent.code.value,
          traceId: traceId,
        );

        expect(
          result,
          isA<AppResultFailure<int>>().having(
            (e) => e.error.code,
            'error.code',
            AppExceptionCode.internalException,
          ),
        );
      },
    );

    test(
      'returns failure with internalException code '
      'when unexpected Exception thrown',
      () async {
        whenCalling(Invocation.method(#getChildrenCountByParentCode, null))
            .on(repository)
            .thenThrow(
              Exception(),
            );

        final result = await repository.getChildrenCountByParentCode(
          parentCode: parent.code.value,
          traceId: traceId,
        );

        expect(
          result,
          isA<AppResultFailure<int>>().having(
            (e) => e.error.code,
            'error.code',
            AppExceptionCode.internalException,
          ),
        );
      },
    );
  });
}
