import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/data/database.dart';
import 'package:journexa_app/data/repositories/account/account.dart';
import 'package:journexa_app/data/repositories/income_category/income_category.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/income_category.dart';
import 'package:journexa_app/domain/repositories/i_income_category_repository.dart';
import 'package:journexa_app/shared/app_exception.dart';
import 'package:journexa_app/shared/app_result.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

void main() {
  const userId = 'userId';
  const traceId = 'traceId';

  final parentAccount = SystemDefinedAccount.rootRevenue;
  final initialCategories = List.generate(5, (index) {
    return IncomeCategory(
      id: 'category_id_$index',
      name: 'Category $index',
      icon: 'category_$index',
      account: Account.user(
        parent: parentAccount,
        name: 'Category $index',
        currentChildrenCount: index,
      ),
    );
  });

  late AppLocalDatabase db;
  late IIncomeCategoryRepository repository;

  setUp(() async {
    db = AppLocalDatabase.test();
    await db.into(db.accountDB).insert(parentAccount.toDB());
    for (final category in initialCategories) {
      await db.into(db.incomeCategoryDB).insert(category.toDB());
      await db.into(db.accountDB).insert(category.account.toDB());
    }

    repository = DriftIncomeCategoryRepository(db: db);
  });

  tearDown(() async {
    await db.delete(db.incomeCategoryDB).go();
    await db.delete(db.accountDB).go();
    await db.close();
  });

  group('save', () {
    final newCategory = IncomeCategory(
      id: 'completely-new',
      name: 'completely new',
      icon: 'icon',
      account: Account.user(
        parent: parentAccount,
        name: 'completely new',
        currentChildrenCount: initialCategories.length,
      ),
    );

    test('returns success and save correct category and account', () async {
      final result = await repository.save(
        userId: userId,
        traceId: traceId,
        category: newCategory,
      );

      expect(result, const AppResult.success(null));

      final statement = db.select(db.incomeCategoryDB).join([
        leftOuterJoin(
          db.accountDB,
          db.accountDB.code.equalsExp(db.incomeCategoryDB.accountCode),
        ),
      ])..where(db.incomeCategoryDB.id.equals(newCategory.id));
      final row = await statement.getSingle();
      expect(
        row
            .readTable(db.incomeCategoryDB)
            .toDomain(
              account: row
                  .readTable(db.accountDB)
                  .toDomain(parent: SystemDefinedAccount.rootRevenue),
            ),
        newCategory,
      );
    });

    test(
      'returns failure with categoryNameAlreadyExists code '
      'when saving existing category name',
      () async {
        final existingName = initialCategories.first.name;

        final result = await repository.save(
          userId: userId,
          traceId: traceId,
          category: newCategory.copyWith(
            name: existingName,
            account: newCategory.account.copyWith(
              name: existingName,
            ),
          ),
        );

        expect(
          result,
          isA<AppResultFailure<Null>>().having(
            (e) => e.error.code,
            'error.code',
            AppExceptionCode.categoryNameAlreadyExists,
          ),
        );
      },
    );

    test(
      'returns failure with internalException code '
      'when db throws DriftWrapperException',
      () async {
        whenCalling(
          Invocation.method(#save, null),
        ).on(repository).thenThrow(DriftWrappedException(message: ''));

        final result = await repository.save(
          userId: userId,
          category: newCategory,
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
      'returns failure with internalException code '
      'when firestore throws Exception',
      () async {
        whenCalling(
          Invocation.method(#save, null),
        ).on(repository).thenThrow(Exception());

        final result = await repository.save(
          userId: userId,
          category: newCategory,
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

  group('watch', () {
    test(
      'emits success with correct categories',
      () async {
        final result = repository.watch(
          userId: userId,
          traceId: traceId,
        );

        expect(result, emits(AppResult.success(initialCategories)));
      },
    );

    test(
      'emits success with correct categories when query provided',
      () async {
        final expectedCategory = IncomeCategory(
          id: 'expected',
          name: 'expected name',
          icon: 'icon',
          account: Account(
            code: '40.1000',
            name: 'expected name',
            type: AccountType.revenue,
            parent: parentAccount,
          ),
        );
        await db.into(db.incomeCategoryDB).insert(expectedCategory.toDB());
        await db.into(db.accountDB).insert(expectedCategory.account.toDB());

        final result = repository.watch(
          userId: userId,
          query: 'expected',
          traceId: traceId,
        );

        expect(result, emits(AppResult.success([expectedCategory])));
      },
    );

    test(
      'emits success with correct categories when isDeleted provided',
      () async {
        final expectedCategory = IncomeCategory(
          id: 'expected',
          name: 'expected name',
          icon: 'icon',
          account: Account(
            code: '40.1000',
            name: 'expected name',
            type: AccountType.revenue,
            parent: parentAccount,
          ),
        );
        await db
            .into(db.incomeCategoryDB)
            .insert(
              expectedCategory.toDB().copyWith(
                isDeleted: const Value(true),
              ),
            );
        await db
            .into(db.accountDB)
            .insert(
              expectedCategory.account.toDB().copyWith(
                isDeleted: const Value(true),
              ),
            );

        final result = repository.watch(
          userId: userId,
          isDeleted: false,
          traceId: traceId,
        );

        expect(result, emits(AppResult.success(initialCategories)));

        final result2 = repository.watch(
          userId: userId,
          isDeleted: true,
          traceId: traceId,
        );

        expect(result2, emits(AppResult.success([expectedCategory])));
      },
    );

    test(
      'emits failure with internalException code '
      'when db emits DriftWrappedException',
      () async {
        whenCalling(
          Invocation.method(#watch, null),
        ).on(repository).thenThrow(DriftWrappedException(message: ''));

        final result = repository.watch(
          userId: userId,
          traceId: traceId,
        );

        expect(
          result,
          emits(
            isA<AppResultFailure<List<IncomeCategory>>>().having(
              (e) => e.error.code,
              'error.code',
              AppExceptionCode.internalException,
            ),
          ),
        );
      },
    );

    test(
      'emits failure with internalException code '
      'when db stream emits exception',
      () async {
        whenCalling(
          Invocation.method(#watch, null),
        ).on(repository).thenThrow(Exception());

        final result = repository.watch(
          userId: userId,
          traceId: traceId,
        );

        expect(
          result,
          emits(
            isA<AppResultFailure<List<IncomeCategory>>>().having(
              (e) => e.error.code,
              'error.code',
              AppExceptionCode.internalException,
            ),
          ),
        );
      },
    );
  });

  group('delete', () {
    test(
      'returns success and set isDeleted to true '
      'for correct Category and the Account',
      () async {
        final deletedCategory = initialCategories.first;

        final result = await repository.delete(
          userId: userId,
          category: deletedCategory,
          traceId: traceId,
        );

        expect(result, const AppResult.success(null));

        final statement = db.select(db.incomeCategoryDB).join([
          leftOuterJoin(
            db.accountDB,
            db.accountDB.code.equalsExp(db.incomeCategoryDB.accountCode),
          ),
        ])..where(db.incomeCategoryDB.id.equals(deletedCategory.id));
        final row = await statement.getSingle();

        expect(row.readTable(db.incomeCategoryDB).isDeleted, isTrue);
        expect(row.readTable(db.accountDB).isDeleted, isTrue);
      },
    );

    test(
      'do nothing when category does not exist',
      () async {
        final nonExistentCategory = IncomeCategory(
          id: 'non-existent',
          name: 'non-existent',
          icon: 'icon',
          account: Account(
            code: '40.0100',
            name: 'non-existent',
            type: AccountType.revenue,
            parent: parentAccount,
          ),
        );

        final result = await repository.delete(
          userId: userId,
          category: nonExistentCategory,
          traceId: traceId,
        );

        expect(result, const AppResult.success(null));

        final statement = db.select(db.incomeCategoryDB).join([
          leftOuterJoin(
            db.accountDB,
            db.accountDB.code.equalsExp(db.incomeCategoryDB.accountCode),
          ),
        ])..where(db.incomeCategoryDB.id.equals(nonExistentCategory.id));
        final row = await statement.getSingleOrNull();

        expect(row, null);
      },
    );

    test(
      'returns failure with internalException '
      'when db throws DriftWrappedException',
      () async {
        whenCalling(
          Invocation.method(#delete, null),
        ).on(repository).thenThrow(DriftWrappedException(message: ''));

        final result = await repository.delete(
          userId: userId,
          category: initialCategories.first,
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
      'when db throws Exception',
      () async {
        whenCalling(
          Invocation.method(#delete, null),
        ).on(repository).thenThrow(Exception());

        final result = await repository.delete(
          userId: userId,
          category: initialCategories.first,
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

  group('update', () {
    final updatedCategory = initialCategories.first.update(name: 'new name');
    test(
      'returns success when succeeded',
      () async {
        final result = await repository.update(
          userId: userId,
          updatedCategory: updatedCategory,
          traceId: traceId,
        );

        expect(result, const AppResult.success(null));
      },
    );

    test(
      'update both Category and Account',
      () async {
        await repository.update(
          userId: userId,
          updatedCategory: updatedCategory,
          traceId: traceId,
        );

        final statement = db.select(db.incomeCategoryDB).join([
          leftOuterJoin(
            db.accountDB,
            db.accountDB.code.equalsExp(db.incomeCategoryDB.accountCode),
          ),
        ])..where(db.incomeCategoryDB.id.equals(updatedCategory.id));
        final row = await statement.getSingle();
        final account = row
            .readTable(db.accountDB)
            .toDomain(parent: SystemDefinedAccount.rootRevenue);
        final category = row
            .readTable(db.incomeCategoryDB)
            .toDomain(account: account);
        expect(category, updatedCategory);
      },
    );

    test(
      'returns failure with internalException '
      'when db throws DriftWrappedException',
      () async {
        whenCalling(
          Invocation.method(#update, null),
        ).on(repository).thenThrow(DriftWrappedException(message: ''));

        final result = await repository.update(
          userId: userId,
          updatedCategory: updatedCategory,
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
      'when db throws Exception',
      () async {
        whenCalling(
          Invocation.method(#update, null),
        ).on(repository).thenThrow(Exception());

        final result = await repository.update(
          userId: userId,
          updatedCategory: updatedCategory,
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
}
