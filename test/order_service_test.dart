import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quite_courier/models/order_data_req.dart';
import 'package:quite_courier/services/order_service.dart';
import 'package:quite_courier/interfaces/order_state.dart';
import 'package:latlong2/latlong.dart';

// Mock Firestore
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock implements CollectionReference {}

class MockDocumentReference extends Mock implements DocumentReference {}

void main() {
  group('OrderService', () {
    late MockFirebaseFirestore mockFirestore;
    late MockCollectionReference mockCollectionReference;
    late MockDocumentReference mockDocumentReference;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockCollectionReference = MockCollectionReference();
      mockDocumentReference = MockDocumentReference();

      // Set up the mock chain
      when(mockFirestore.collection('orders')).thenReturn(mockCollectionReference);
      when(mockCollectionReference.add(any)).thenAnswer((_) async => mockDocumentReference);
      when(mockDocumentReference.id).thenReturn('mocked-doc-id');
    });

    test('addOrder should add a new order to Firestore', () async {
      // Arrange
      final orderDataReq = OrderDataReq(
        riderName: 'John Doe',
        riderTelephone: '1234567890',
        senderName: 'Alice',
        senderTelephone: '0987654321',
        receiverName: 'Bob',
        receiverTelephone: '1122334455',
        nameOrder: 'Test Order',
        orderPhoto: 'https://example.com/photo.jpg',
        riderOrderPhoto1: 'https://example.com/rider_photo1.jpg',
        riderOrderPhoto2: 'https://example.com/rider_photo2.jpg',
        description: 'Test description',
        senderLocation: const LatLng(13.7563, 100.5018),
        receiverLocation: const LatLng(13.7563, 100.5018),
        senderAddress: '123 Sender St, Bangkok',
        receiverAddress: '456 Receiver St, Bangkok',
        state: OrderState.pending,
      );

      // Act
      final result = await OrderService.addOrder(orderDataReq);

      // Assert
      expect(result, isA<String>());
      expect(result, 'mocked-doc-id');

      // Verify that Firestore's add method was called with the correct data
      verify(mockCollectionReference.add(any)).called(1);
    });
  });
}
