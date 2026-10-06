import 'package:ecommerce/presentation/address/view_model/address_view_model.dart';
import 'package:ecommerce/presentation/wishlist/view_model/wishlist_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

void main() {
  group('WishlistViewModel', () {
    late FakeWishlistRepository repo;
    late WishlistViewModel vm;
    final catalog = sampleCatalog();

    setUp(() {
      repo = FakeWishlistRepository(catalog);
      vm = WishlistViewModel(wishlistRepository: repo);
    });

    test('toggle adds then removes a product', () async {
      expect(await vm.toggleWishlist(catalog[0]), isTrue);
      expect(vm.isInWishlist(catalog[0].id), isTrue);
      expect(vm.items, hasLength(1));

      await vm.toggleWishlist(catalog[0]);
      expect(vm.isInWishlist(catalog[0].id), isFalse);
      expect(vm.items, isEmpty);
    });

    test('fetch loads what is stored on the server', () async {
      repo.ids.addAll({'p2', 'p3'});

      await vm.fetchWishlist();

      expect(vm.items.map((p) => p.id), ['p2', 'p3']);
      expect(vm.isLoading, isFalse);
    });

    test('failures are reported, not swallowed', () async {
      repo.error = Exception('SocketException: offline');

      expect(await vm.toggleWishlist(catalog[0]), isFalse);
      await vm.fetchWishlist();

      expect(vm.items, isEmpty);
      expect(vm.errorMessage, 'error_network');
      expect(vm.isLoading, isFalse);
    });
  });

  group('AddressViewModel', () {
    late FakeAddressRepository repo;
    late AddressViewModel vm;

    setUp(() {
      repo = FakeAddressRepository();
      vm = AddressViewModel(addressRepository: repo);
    });

    test('add, update and delete keep the list in sync', () async {
      expect(
        await vm.addAddress(makeAddress(id: null, fullName: 'Home')),
        isTrue,
      );
      expect(vm.addresses.single.fullName, 'Home');

      final saved = vm.addresses.single;
      await vm.updateAddress(makeAddress(id: saved.id, fullName: 'Work'));
      expect(vm.addresses.single.fullName, 'Work');

      await vm.deleteAddress(saved.id!);
      expect(vm.addresses, isEmpty);
      expect(vm.isLoading, isFalse);
    });

    test('the first address becomes the default', () async {
      await vm.addAddress(makeAddress(id: null));

      expect(vm.addresses.single.isDefault, isTrue);
      expect(vm.defaultAddress, vm.addresses.single);
    });

    test('a new address marked default replaces the old default', () async {
      await vm.addAddress(makeAddress(id: null, fullName: 'First'));
      await vm.addAddress(
        makeAddress(id: null, fullName: 'Second', isDefault: true),
      );

      expect(vm.addresses.where((a) => a.isDefault).map((a) => a.fullName), [
        'Second',
      ]);
    });

    test('setDefaultAddress leaves exactly one default', () async {
      repo.addresses
        ..add(makeAddress(id: 'a1', isDefault: true))
        ..add(makeAddress(id: 'a2'));

      await vm.setDefaultAddress('a2');

      expect(vm.addresses.where((a) => a.isDefault).map((a) => a.id), ['a2']);
    });

    test('errors are reported and do not leave a spinner', () async {
      repo.error = Exception('SocketException: offline');

      await vm.fetchAddresses();
      expect(await vm.addAddress(makeAddress()), isFalse);

      expect(vm.isLoading, isFalse);
      expect(vm.errorMessage, 'error_network');
      expect(vm.addresses, isEmpty);
    });
  });
}
