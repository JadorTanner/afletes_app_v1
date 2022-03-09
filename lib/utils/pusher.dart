import 'package:afletes_app_v1/utils/globals.dart';
import 'package:http/http.dart';
import 'package:pusher_client/pusher_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PusherApi {
  PusherOptions? options;
  late PusherClient pusher;
  Channel? pusherChannel;
  Channel? privateChannel;

  init() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? user = sharedPreferences.getString('user');
    if (user != null) {
      options = PusherOptions(
        host: '192.168.1.152',
        wsPort: 8000,
        encrypted: false,
        cluster: 'us2',
        auth: PusherAuth(apiUrl + 'broadcasting/auth', headers: {
          'Authorization': 'Bearer ' + sharedPreferences.getString('token')!,
          'Accept': 'application/json',
        }),
      );
    } else {
      options = PusherOptions(
        encrypted: false,
        cluster: 'us2',
      );
    }

    pusher = PusherClient(pusherKey, options!,
        autoConnect: true, enableLogging: true);

    pusher.onConnectionStateChange((state) {
      print('\n\n\nESTADO DE CONECCION\n\n\n');
      print(
          "previousState: ${state!.previousState}, currentState: ${state.currentState}");
    });

    pusher.onConnectionError((error) {
      print('\n\n\nERROR EN PUSHER\n\n\n');
      print("error: ${error!.message}");
    });

    pusherChannel = pusher.subscribe("negotiation-chat");
    privateChannel = pusher.subscribe("private-location-share");

    privateChannel!.bind("pusher:subscription_succeeded",
        (PusherEvent? event) async {
      print('CONECCION A PRIVATE CHANNEL');
      print(event);
      // privateChannel!.trigger("client-istyping", {"name": "Bob"});
    });
    return this;
  }

  bindEvent(eventName, callback) async {
    pusherChannel!.bind(eventName, (PusherEvent? event) async {
      callback(event);
    });
  }

  triggerEvent(eventName, data) {
    pusherChannel!.trigger(eventName, data);
  }
}
