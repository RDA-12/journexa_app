import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/expense_category.dart';
import 'package:journexa_app/shared/app_exception.dart';

void main() {
  group('constructor', () {
    final expenseAccount = Account.sub(
      name: 'expense',
      parent: SystemDefinedAccount.expenseParent,
      currentChildrenCount: 0,
    );

    test(
      'throws AppException when connected Account is not a expense type',
      () {
        expect(
          () => ExpenseCategory(
            id: 'id',
            name: 'name',
            icon: 'icon',
            account: Account.sub(
              name: 'expense',
              parent: SystemDefinedAccount.walletParent,
              currentChildrenCount: 0,
            ),
          ),
          throwsA(
            isA<AppException>().having(
              (e) => e.message,
              'message',
              'ExpenseCategory must have expense typed Account. '
                  'Got: AccountType.asset',
            ),
          ),
        );
      },
    );

    test(
      'throws AppException when connected Account has no '
      'system expense Account as its parent',
      () {
        expect(
          () => ExpenseCategory(
            id: 'id',
            name: 'name',
            icon: 'icon',
            account: expenseAccount.copyWith(parent: null),
          ),
          throwsA(
            isA<AppException>().having(
              (e) => e.message,
              'message',
              'ExpenseCategory must have Account with '
                  'parent to system expense Account. '
                  'Got: null',
            ),
          ),
        );
      },
    );
  });

  group('update', () {
    test(
      'return new ExpenseCategory and its Account '
      'when name is updated',
      () {
        final expected = ExpenseCategory.test().copyWith(
          name: 'new name',
          account: ExpenseCategory.test().account.copyWith(name: 'new name'),
        );

        final original = ExpenseCategory.test();
        final updated = original.update(name: 'new name');

        expect(updated, expected);
      },
    );
  });
}
