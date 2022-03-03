import 'package:afletes_app_v1/utils/globals.dart';
import 'package:pusher_client/pusher_client.dart';

class PusherApi {
  final PusherOptions options = PusherOptions(
    encrypted: false,
    cluster: 'us2',
  );
  late PusherClient pusher;
  late Channel pusherChannel;

  init() {
    pusher = PusherClient(pusherKey, options,
        autoConnect: true, enableLogging: true);

    pusher.onConnectionStateChange((state) {
      print(
          "previousState: ${state!.previousState}, currentState: ${state.currentState}");
    });

    pusher.onConnectionError((error) {
      print("error: ${error!.message}");
    });

    pusherChannel = pusher.subscribe("negotiation-chat");
  }

  bindEvent(eventName, callback) async {
    pusherChannel.bind(eventName, (PusherEvent? event) async {
      callback(event);
    });
  }

  triggerEvent(eventName, data) {
    pusherChannel.trigger(eventName, data);
  }
}
