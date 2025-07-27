import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

String ACCESS_TOKEN =
    'pk.eyJ1IjoiZXJpY2ttZW4iLCJhIjoiY21kbHkxZWltMDA5bDJpcTB5anV5Mm81ZSJ9.zBUEoWLSy73KkI96EehDpQ';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MapboxOptions.setAccessToken(ACCESS_TOKEN);

  runApp(MaterialApp(home: MapWithPin()));
}

class MapWithPin extends StatefulWidget {
  @override
  State<MapWithPin> createState() => _MapWithPinState();
}

class _MapWithPinState extends State<MapWithPin> {
  late MapboxMap mapboxMap;
  PointAnnotationManager? pointAnnotationManager;
  PolygonAnnotationManager? polygonAnnotationManager;

  final Point parqueMadero = Point(
    coordinates: Position(-110.94693211397411, 29.078429200831412),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 100),
          SizedBox(
            height: 250,
            child: MapWidget(
              styleUri: MapboxStyles.MAPBOX_STREETS,
              cameraOptions: CameraOptions(center: parqueMadero, zoom: 15),
              onMapCreated: _onMapCreated,
            ),
          ),
        ],
      ),
    );
  }

  void _onMapCreated(MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;

    // Crear el pin marker
    await _createPinMarker();
    
    // Crear el polígono circular
    await _createCircularArea();
  }

  Future<void> _createPinMarker() async {
    final annotationManager =
        await mapboxMap.annotations.createPointAnnotationManager();
    pointAnnotationManager = annotationManager;

    final annotationOptions = PointAnnotationOptions(
      geometry: parqueMadero,
      iconSize: 1.5,
      // ignore: deprecated_member_use
      iconColor: Colors.red.value,
      // Opcional: usar un icono personalizado
      // iconImage: "custom-marker",
    );

    annotationManager.create(annotationOptions);
  }

  Future<void> _createCircularArea() async {
    final polygonManager =
        await mapboxMap.annotations.createPolygonAnnotationManager();
    polygonAnnotationManager = polygonManager;

    // Crear puntos para formar un círculo (aproximado con polígono)
    List<Position> circlePoints = _generateCirclePoints(
      center: parqueMadero.coordinates,
      radiusInMeters: 200, // Radio de 200 metros
      numberOfPoints: 64, // Más puntos = círculo más suave
    );

    final polygonOptions = PolygonAnnotationOptions(
      geometry: Polygon(coordinates: [circlePoints]),
      fillColor: Colors.blue.withOpacity(0.9).value,
      fillOutlineColor: Colors.blue.value,
      fillOpacity: 0.3,
    );

    polygonManager.create(polygonOptions);
  }

  List<Position> _generateCirclePoints({
    required Position center,
    required double radiusInMeters,
    int numberOfPoints = 64,
  }) {
    List<Position> points = [];
    
    // Radio de la Tierra en metros
    const double earthRadius = 6378137.0;
    
    // Convertir radio a grados
    double radiusInDegrees = radiusInMeters / earthRadius * (180 / pi);
    
    for (int i = 0; i <= numberOfPoints; i++) {
      double angle = (i * 2 * pi) / numberOfPoints;
      
      // Calcular las coordenadas del punto en el círculo
      double deltaLat = radiusInDegrees * cos(angle);
      double deltaLng = radiusInDegrees * sin(angle) / cos(center.lat * pi / 180);
      
      double pointLat = center.lat + deltaLat;
      double pointLng = center.lng + deltaLng;
      
      points.add(Position(pointLng, pointLat));
    }
    
    return points;
  }

  @override
  void dispose() {
    pointAnnotationManager?.deleteAll();
    polygonAnnotationManager?.deleteAll();
    super.dispose();
  }
}