import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moto_taxi_digital_mobile/business/models/bike/bike.dart';
import 'package:moto_taxi_digital_mobile/business/services/user/owner/ownerService.dart';
import 'package:moto_taxi_digital_mobile/pages/user/owner/ownerCtrl.dart';
import 'package:moto_taxi_digital_mobile/pages/user/owner/ownerPage.dart';

class _OwnerServiceForTest implements OwnerService {
  bool fail = true;

  @override
  Future<List<Bike>> getByOwner() async {
    if (fail) throw Exception('Service indisponible');
    return [
      Bike(
        id: 1,
        model: 'Test',
        brand: 'Moto',
        matricule: 'KIN-123',
        ownerId: 1,
      ),
    ];
  }

  @override
  Future<Map<String, dynamic>> stat() async {
    if (fail) throw Exception('Service indisponible');
    return {'assigned_bikes': 0, 'available_bikes': 1};
  }

  @override
  Future<List<Bike>> getAssignatedBike() => getByOwner();

  @override
  Future<List<Bike>> getAvailableBike() => getByOwner();
}

void main() {
  testWidgets('le propriétaire peut réessayer après une erreur API', (
    tester,
  ) async {
    final service = _OwnerServiceForTest();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ownerProvider.overrideWith(
            (ref) => OwnerController(service: service),
          ),
        ],
        child: const MaterialApp(home: OwnerHomePage()),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Service indisponible'), findsOneWidget);
    expect(find.text('Réessayer'), findsOneWidget);

    service.fail = false;
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();

    expect(find.text('Moto Test'), findsOneWidget);
    expect(find.text('Matricule: KIN-123'), findsOneWidget);
  });
}
