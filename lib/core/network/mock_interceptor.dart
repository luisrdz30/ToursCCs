import 'package:dio/dio.dart';

class MockInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final path = options.path;
    final method = options.method;

    if (method == 'GET') {
      if (path == '/admin/dashboard') {
        return handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'totalTourists': 1500,
            'activeTours': 8,
            'associatedBusinesses': 42,
            'growthPercentage': 12.5,
          },
        ));
      } else if (path == '/admin/promotions') {
        return handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: [
            {
              'id': 'p1',
              'businessId': 'b1',
              'businessName': 'Restaurante Vista Hermosa',
              'title': 'Locro de Papa Especial',
              'description': '15% de descuento',
              'pointsCost': 250,
              'isActive': true,
              'isApproved': true,
            },
            {
              'id': 'p2',
              'businessId': 'b1',
              'businessName': 'Restaurante Vista Hermosa',
              'title': 'Descuento Fin de Año',
              'description': 'Propuesta de 20% descuento',
              'pointsCost': 300,
              'isActive': false,
              'isApproved': false,
            }
          ]
        ));
      } else if (path == '/admin/tours') {
        return handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: [
            {
              'id': 't1',
              'title': 'City Tour Histórico',
              'startTime': '09:00',
              'status': 'Active',
            },
            {
              'id': 't2',
              'title': 'Ruta de los Volcanes',
              'startTime': '14:30',
              'status': 'Scheduled',
            }
          ]
        ));
      } else if (path == '/driver/profile') {
        return handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'id': 'd1',
            'name': 'Carlos Mendoza',
            'email': 'driver@test.com',
            'phone': '+593 99 123 4567',
            'licenseNumber': '1701234567',
            'assignedVehicle': 'U-04 (Mercedes Benz)',
            'rating': 4.8,
            'totalTrips': 124,
          }
        ));
      } else if (path.startsWith('/driver/trips/') && path.endsWith('/passengers')) {
        return handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: [
            {
              'id': 'p1',
              'name': 'Ana García',
              'seatNumber': '1A',
              'hasBoarded': true,
            },
            {
              'id': 'p2',
              'name': 'Juan Pérez',
              'seatNumber': '1B',
              'hasBoarded': false,
            }
          ]
        ));
      } else if (path == '/business/profile') {
        return handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'id': 'b1',
            'name': 'Restaurante Vista Hermosa',
            'email': 'partner@test.com',
            'address': 'Centro Histórico',
            'phone': '0991234567',
            'category': 'Restaurante',
            'rating': 4.5,
          }
        ));
      } else if (path == '/business/menu') {
        return handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: [
            {
              'id': 'm1',
              'name': 'Locro de Papa',
              'price': 4.50,
            }
          ]
        ));
      } else if (path == '/tourist/explore/spots') {
        return handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: [
            {
              'id': 's1',
              'name': 'Basílica del Voto Nacional',
              'shortDescription': 'Catedral neogótica',
              'imageUrl': 'https://images.unsplash.com/photo-1547496502-affa22d38842?q=80&w=600&auto=format&fit=crop',
              'distance': '1.2 km',
              'category': 'Monumento',
              'pointsToEarn': 150,
            },
            {
              'id': 's2',
              'name': 'Mitad del Mundo',
              'shortDescription': 'Latitud 0-0-0',
              'imageUrl': 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?q=80&w=600&auto=format&fit=crop',
              'distance': '24 km',
              'category': 'Monumento',
              'pointsToEarn': 200,
            },
          ]
        ));
      }
    } else {
      // POST, PUT, DELETE
      return handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {'success': true}
      ));
    }
    
    // Default fallback
    return handler.resolve(Response(
      requestOptions: options,
      statusCode: 200,
      data: []
    ));
  }
}
