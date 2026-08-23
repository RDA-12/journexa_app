import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/domain/entities/account.dart';
import 'package:journexa_app/domain/entities/income_category.dart';
import 'package:journexa_app/shared/app_exception.dart';

void main() {
  group('constructor', () {
    final revenueAccount = Account(
      code: '40.0101',
      name: 'revenue',
      type: AccountType.revenue,
      parent: SystemDefinedAccount.rootRevenue,
    );

    test(
      'throws AppException when connected Account is not a revenue type',
      () {
        expect(
          () => IncomeCategory(
            id: 'id',
            name: 'name',
            icon: 'icon',
            account: revenueAccount.copyWith(
              code: '10.0010',
              type: AccountType.asset,
            ),
          ),
          throwsA(
            isA<AppException>().having(
              (e) => e.message,
              'message',
              'IncomeCategory must have revenue typed Account. '
                  'Got: AccountType.asset',
            ),
          ),
        );
      },
    );

    test(
      'throws AppException when connected Account has no '
      'system revenue Account as its parent',
      () {
        expect(
          () => IncomeCategory(
            id: 'id',
            name: 'name',
            icon: 'icon',
            account: revenueAccount.copyWith(parent: null),
          ),
          throwsA(
            isA<AppException>().having(
              (e) => e.message,
              'message',
              'IncomeCategory must have Account with '
                  'parent to system revenue Account. '
                  'Got: null',
            ),
          ),
        );
      },
    );
  });

  group('update', () {
    test(
      'return new IncomeCategory and its Account '
      'when name is updated',
      () {
        final expected = IncomeCategory.test().copyWith(
          name: 'new name',
          account: IncomeCategory.test().account.copyWith(name: 'new name'),
        );

        final original = IncomeCategory.test();
        final updated = original.update(name: 'new name');

        expect(updated, expected);
      },
    );
  });
}
