import 'package:afletes_app_v1/utils/api.dart';
import 'package:http/http.dart';

class Negotiation {
  int id, transportistId, vehicleId, generatorId, loadId;
  String state;
  Negotiation(
      {this.id = 0,
      this.transportistId = 0,
      this.vehicleId = 0,
      this.generatorId = 0,
      this.loadId = 0,
      this.state = ''});

  startNegotiation() async {
    Api api = Api();

    Response response = await api.postData('negotiation/start-negotiation', {
      'load_id': 4,
      'vehicle_id': 1,
      'initial_offer': 1200000,
    });
    print(response.body);
  }

  acceptNegotiation() {}

  rejectNegotiation() {}

  showNegotiation() {}
}
