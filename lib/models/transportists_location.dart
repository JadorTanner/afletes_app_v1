import 'package:flutter/cupertino.dart';

class TransportistsLocProvider extends ChangeNotifier {
  final List<TransportistLocation> _transportists = [];
  List<TransportistLocation> get transportists => _transportists;

  addTransportist(TransportistLocation transportist) {
    _transportists.add(transportist);
    notifyListeners();
  }

  updateLocation(int transportistId, int vehicleId, double latitude,
      double longitude, double? heading,
      [String name = '']) {
    int index = _transportists.indexWhere((t) =>
        ((t.transportistId == transportistId) && (t.vehicleId == vehicleId)));
    print('DATOS DE UPDATE OR CREATE');
    print(index);
    print(heading);
    if (index != -1) {
      _transportists[index].latitude = latitude;
      _transportists[index].longitude = longitude;
      _transportists[index].heading = (heading ?? 0.0);
    } else {
      addTransportist(TransportistLocation(latitude, longitude,
          (heading ?? 0.0), transportistId, name, vehicleId));
    }
    notifyListeners();
  }

  removeTransportist(int transportistId, int vehicleId) {
    _transportists.removeWhere((t) =>
        ((t.transportistId == transportistId) && (t.vehicleId == vehicleId)));
    notifyListeners();
  }
}

class TransportistLocation {
  double latitude = 0, longitude = 0, heading = 0;
  int transportistId = 0, vehicleId = 0, negotiationId = 0;
  String name;

  TransportistLocation(
    this.latitude,
    this.longitude,
    this.heading,
    this.transportistId,
    this.name,
    this.vehicleId, [
    this.negotiationId = 0,
  ]);
}
