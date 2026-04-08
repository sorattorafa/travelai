import 'package:flutter_test/flutter_test.dart';
import 'package:travelai/domain/entities/location_entity.dart';

void main() {
  test('hasAddress retorna true quando tem cidade e país', () {
    const location = LocationEntity(
      latitude: -23.55,
      longitude: -46.63,
      city: 'São Paulo',
      country: 'Brasil',
    );
    expect(location.hasAddress, true);
  });

  test('hasAddress retorna false quando falta cidade', () {
    const location = LocationEntity(
      latitude: -23.55,
      longitude: -46.63,
      country: 'Brasil',
    );
    expect(location.hasAddress, false);
  });

  test('hasAddress retorna false quando falta país', () {
    const location = LocationEntity(
      latitude: -23.55,
      longitude: -46.63,
      city: 'São Paulo',
    );
    expect(location.hasAddress, false);
  });

  test('displayName mostra cidade e país', () {
    const location = LocationEntity(
      latitude: -23.55,
      longitude: -46.63,
      city: 'São Paulo',
      country: 'Brasil',
    );
    expect(location.displayName, 'São Paulo, Brasil');
  });

  test('displayName mostra coordenadas quando sem endereço', () {
    const location = LocationEntity(
      latitude: -23.55,
      longitude: -46.63,
    );
    expect(location.displayName, '-23.55, -46.63');
  });

  test('copyWith preserva valores originais', () {
    const original = LocationEntity(
      latitude: -23.55,
      longitude: -46.63,
      city: 'São Paulo',
      country: 'Brasil',
    );

    final copy = original.copyWith(city: 'Rio');

    expect(copy.city, 'Rio');
    expect(copy.country, 'Brasil');
    expect(copy.latitude, -23.55);
  });

  test('igualdade funciona corretamente', () {
    const a = LocationEntity(
      latitude: -23.55,
      longitude: -46.63,
      city: 'São Paulo',
    );
    const b = LocationEntity(
      latitude: -23.55,
      longitude: -46.63,
      city: 'São Paulo',
    );
    expect(a, equals(b));
  });
}
