// ignore_for_file: must_be_immutable

import 'dart:convert';
import 'dart:developer';

import 'package:afletes_app_v1/models/chat.dart';
import 'package:afletes_app_v1/models/common.dart';
import 'package:afletes_app_v1/models/user.dart';
import 'package:afletes_app_v1/ui/components/base_app.dart';
import 'package:afletes_app_v1/ui/components/chat_bubble.dart';
import 'package:afletes_app_v1/ui/pages/negotiations/payment.dart';
import 'package:afletes_app_v1/utils/api.dart';
import 'package:afletes_app_v1/utils/globals.dart';
import 'package:afletes_app_v1/utils/loads.dart';
import 'package:afletes_app_v1/utils/vehicles.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

GlobalKey<AnimatedListState> globalKey = GlobalKey<AnimatedListState>();
TextEditingController oferta = TextEditingController();
int receiverId = 0;
int voteStars = 0;
User user = User();
List<ChatMessage> messages = [];

late bool canOffer;
late bool showDefaultMessages = false;
late bool toPay = false;
late bool paid = false;
late bool canVote = false;
late int loadState = 0;

late Load load;
late Vehicle vehicle;

TextEditingController commentController = TextEditingController();

ButtonStyle pillStyle = ButtonStyle(
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
            side: const BorderSide(color: Colors.orange))));

Future<List<ChatMessage>> getNegotiationChat(id, BuildContext context) async {
  // try {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  user = User(userData: jsonDecode(sharedPreferences.getString('user')!))
      .userFromArray();

  sharedPreferences.setString('negotiation_id', id.toString());
  context.read<ChatProvider>().setNegotiationId(id);

  Api api = Api();

  context.read<ChatProvider>().clearMessages();
  FocusManager.instance.primaryFocus?.unfocus();

  Response response = await api.getData('negotiation/?id=' + id.toString());
  ChatProvider chatProvider = context.read<ChatProvider>();

  chatProvider.setCanOffer(false);
  chatProvider.setPaid(false);
  chatProvider.setCanVote(false);
  chatProvider.setShowDefaultMessages(false);
  chatProvider.setToPay(false);
  if (response.statusCode == 200) {
    Map jsonResp = jsonDecode(response.body);
    List listMessages = jsonResp['data']['messages'];
    List<ChatMessage> providerMessages = [];
    if (listMessages.isNotEmpty) {
      listMessages.asMap().forEach((key, message) {
        providerMessages.add(ChatMessage(
            message['img_url'] ?? message['message'],
            message['created_at'],
            message['sender_id'],
            message['id'],
            message['img_url'] != null));
      });
      chatProvider.setMessages(providerMessages);
    }
    receiverId = jsonResp['data']['negotiation']
        [user.isCarrier ? 'generator_id' : 'transportist_id'];
    print('Estado de la negociación: ' +
        jsonResp['data']['negotiation_state']['id'].toString());
    chatProvider.setNegState(jsonResp['data']['negotiation_state']['id']);
    //MANEJA LOS ELEMENTOS QUE APARECERAN EN PANTALLA
    switch (chatProvider.negState) {
      case 1:
        chatProvider.setCanOffer(true);
        chatProvider.setPaid(false);
        chatProvider.setCanVote(false);
        chatProvider.setShowDefaultMessages(false);
        chatProvider.setToPay(false);
        break;
      case 2:
        chatProvider.setCanOffer(false);
        chatProvider.setPaid(false);
        chatProvider.setCanVote(false);
        chatProvider.setShowDefaultMessages(false);
        chatProvider.setToPay(true);
        break;
      case 6:
        chatProvider.setCanOffer(true);
        chatProvider.setPaid(false);
        chatProvider.setToPay(false);
        break;
      case 8:
        chatProvider.setCanOffer(false);
        chatProvider.setPaid(true);
        chatProvider.setShowDefaultMessages(true);
        break;
      default:
        chatProvider.setCanVote(false);
        chatProvider.setToPay(false);
        chatProvider.setCanOffer(false);
        chatProvider.setPaid(false);
        chatProvider.setShowDefaultMessages(false);
    }
    // if (chatProvider.paid) {
    //   oferta.text = jsonResp['data']['load']['final_offer'] ?? '0';
    // }
    chatProvider.setLoadState(jsonResp['data']['load_state']['id']);
    chatProvider.setLoadId(jsonResp['data']['load']['id']);
    if (chatProvider.loadState == 13) {
      chatProvider.setCanVote(false);
      chatProvider.setToPay(false);
      chatProvider.setCanOffer(false);
      chatProvider.setPaid(false);
      chatProvider.setShowDefaultMessages(false);
    }

    load = Load.fromJSON(jsonResp['data']['load']);
  }
  return [];
  // } catch (e) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Compruebe su conexión a internet')));
  //   return [];
  // }
}

Future sendMessage(id, BuildContext context, ChatProvider chat,
    [bool isDefaultMessage = false,
    String message = '',
    bool isLocation = false]) async {
  try {
    FocusManager.instance.primaryFocus?.unfocus();
    String offer = oferta.text;
    oferta.text = '';
    Position? location;
    String mapImgUrl = "";
    if (isLocation) {
      location = await Geolocator.getCurrentPosition();
      mapImgUrl =
          "https://maps.googleapis.com/maps/api/staticmap?zoom=18&size=600x300&maptype=roadmap&markers=color:red%7C${location.latitude},${location.longitude}&key=$googleMapKey";
      message =
          """<a href="https://www.google.com/maps/search/?zoom=18&api=1&query=${location.latitude}%2C${location.longitude}" title="ubicación" target="_blank"><img src="$mapImgUrl" ><br>Mi ubicación</a>""";
    }
    Api api = Api();
    Response response = await api.postData('negotiation/send-message', {
      'negotiation_id': id,
      'message': isDefaultMessage ? message : offer,
      'is_final_offer': false,
      'is_default': isDefaultMessage,
      'is_location': isLocation,
      'img_url': isLocation ? mapImgUrl : null,
      'user_id': receiverId
    });

    Map jsonResp = jsonDecode(response.body);
    if (jsonResp['success']) {
      chat.addMessage(
          id,
          ChatMessage(isLocation ? mapImgUrl : jsonResp['data']['message'],
              jsonResp['data']['created_at'], user.id, id, isLocation));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(jsonResp['message']),
        duration: const Duration(seconds: 3),
      ));
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compruebe su conexión a internet')));
  }
}

Future cancelNegotiation(id, context) async {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Desea cancelar la negociación?'),
      actions: [
        IconButton(
          icon: const Icon(Icons.check),
          onPressed: () async {
            try {
              Api api = Api();
              Response response = await api.postData('negotiation/reject', {
                'id': id,
              });
              if (response.statusCode == 200) {
                context.read<ChatProvider>().setCanOffer(false);
              }
              log(response.body);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Compruebe su conexión a internet')));
            }
          },
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        )
      ],
    ),
  );
}

Future setLoadState(int negotiationId, int loadId, int state,
    BuildContext context, ChatProvider chat) async {
  FocusManager.instance.primaryFocus?.unfocus();
  oferta.text = '';
  try {
    Api api = Api();
    Response response = await api.postData('load/estado-carga', {
      'id': loadId,
      'negotiation_id': negotiationId,
      'state': state,
    });

    Map jsonResp = jsonDecode(response.body);
    if (jsonResp['success']) {
      chat.addMessage(
          negotiationId,
          ChatMessage(jsonResp['data']['message'],
              jsonResp['data']['created_at'], user.id, negotiationId));
      chat.setLoadState(state);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(jsonResp['message']),
        duration: const Duration(seconds: 3),
      ));
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compruebe su conexión a internet')));
  }
}

Future acceptNegotiation(id, context) async {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Desea aceptar la oferta?'),
      actions: [
        IconButton(
          onPressed: () async {
            try {
              Api api = Api();
              Response response = await api.postData('negotiation/accept', {
                'id': id,
              });
              if (response.statusCode == 200) {
                context.read<ChatProvider>().setCanOffer(false);
                context.read<ChatProvider>().setToPay(true);
                Navigator.pop(context);
                if (user.isLoadGenerator) {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => Payment(id),
                  ));
                }
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Compruebe su conexión a internet')));
            }
          },
          icon: const Icon(Icons.check),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        )
      ],
    ),
  );
}

class NegotiationChat extends StatefulWidget {
  NegotiationChat(this.id, {Key? key}) : super(key: key);
  int id;
  @override
  State<NegotiationChat> createState() => _NegotiationChatState();
}

class _NegotiationChatState extends State<NegotiationChat> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: FutureBuilder(
          future: getNegotiationChat(widget.id, context),
          builder: (context, snapshot) => BaseApp(
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
              ),
              margin: const EdgeInsets.only(
                top: 70,
                left: 20,
                right: 20,
              ),
              child: Stack(
                children: [
                  Column(
                    children: [
                      const Expanded(
                        // height: MediaQuery.of(context).size.height * 0.75,
                        child: ChatPanel(),
                      ),
                      DynamicSection(widget)
                    ],
                  ),
                  Positioned(
                    top: 20,
                    right: 20,
                    child: IconButton(
                      onPressed: () => {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            insetPadding: const EdgeInsets.all(20),
                            child: ListView(
                              padding: const EdgeInsets.all(20),
                              children: [
                                Text('Información de la carga',
                                    style:
                                        Theme.of(context).textTheme.headline5),
                                const SizedBox(
                                  height: 20,
                                ),
                                Text('Producto: ' + load.product),
                                Text('Descripción: ' + load.description),
                                Text('Peso: ' + load.weight.toString()),
                                Text('Volumen: ' + load.volumen.toString()),
                                Text('Fecha de servicio: ' +
                                    load.pickUpDate +
                                    ' a las ' +
                                    load.pickUpTime),
                                Text('Cantidad de vehículos: ' +
                                    load.vehicleQuantity.toString()),
                                Text('Cantidad de ayudantes: ' +
                                    load.helpersQuantity.toString()),
                                Text('Tiempo de espera (origen): ' +
                                    load.loadWait.toString()),
                                Text('Tiempo de espera (descarga): ' +
                                    load.deliveryWait.toString()),
                                Text('Oferta inicial: ' +
                                    load.initialOffer.toString()),
                                Text('Observaciones: ' + load.observations),
                                const Divider(),
                                Text('Información del vehículo',
                                    style:
                                        Theme.of(context).textTheme.headline5),
                                const SizedBox(
                                  height: 20,
                                ),
                                Text('')
                              ],
                            ),
                          ),
                        ),
                      },
                      icon: const Icon(
                        Icons.info_outline,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            resizeToAvoidBottomInset: true,
          ),
        ),
        onWillPop: () => Future(() {
              context.read<ChatProvider>().setNegotiationId(0);
              // context.read<ChatProvider>().setCanOffer(false);
              // context.read<ChatProvider>().setPaid(false);
              // context.read<ChatProvider>().setCanVote(false);
              // context.read<ChatProvider>().setShowDefaultMessages(false);
              // context.read<ChatProvider>().setToPay(false);

              return true;
            }));
  }
}

class DynamicSection extends StatefulWidget {
  DynamicSection(this.widget, {Key? key}) : super(key: key);
  NegotiationChat widget;
  @override
  State<DynamicSection> createState() => _DynamicSectionState();
}

class _DynamicSectionState extends State<DynamicSection> {
  @override
  Widget build(BuildContext context) {
    // int negState = context.watch<ChatProvider>().negState;
    // ChatProvider chatProvider = context.read();
    // if (mounted) {
    //   switch (negState) {
    //     case 1:
    //       chatProvider.setCanOffer(true);
    //       chatProvider.setPaid(false);
    //       chatProvider.setCanVote(false);
    //       chatProvider.setShowDefaultMessages(false);
    //       chatProvider.setToPay(false);
    //       break;
    //     case 2:
    //       chatProvider.setCanOffer(false);
    //       chatProvider.setPaid(false);
    //       chatProvider.setCanVote(false);
    //       chatProvider.setShowDefaultMessages(false);
    //       chatProvider.setToPay(true);
    //       break;
    //     case 6:
    //       chatProvider.setCanOffer(true);
    //       chatProvider.setPaid(false);
    //       chatProvider.setToPay(false);
    //       break;
    //     case 8:
    //       chatProvider.setCanOffer(false);
    //       chatProvider.setPaid(true);
    //       chatProvider.setShowDefaultMessages(true);
    //       break;
    //     default:
    //       chatProvider.setCanVote(false);
    //       chatProvider.setToPay(false);
    //       chatProvider.setCanOffer(false);
    //       chatProvider.setPaid(false);
    //       chatProvider.setShowDefaultMessages(false);
    //   }
    // }
    return Column(
      children: [
        OfferInputSection(widget: widget.widget),
        ButtonsSection(widget: widget.widget)
      ],
    );
  }
}

class ButtonsSection extends StatelessWidget {
  ButtonsSection({
    Key? key,
    required this.widget,
  }) : super(key: key);

  final NegotiationChat widget;

  ButtonStyle buttonStyle = ButtonStyle();

  @override
  Widget build(BuildContext context) {
    toPay = context.watch<ChatProvider>().toPay;
    paid = context.watch<ChatProvider>().paid;
    loadState = context.watch<ChatProvider>().loadState;
    canVote = context.watch<ChatProvider>().canVote;

    List<Widget> children = [
      const SizedBox(
        height: 20,
      )
    ];
    //Si la negociación está pagada
    if (paid) {
      switch (loadState) {
        case 8:
          //MUESTRA SOLO SI ES TRANSPORTISTA
          if (user.isCarrier) {
            children = [
              TextButton(
                style: buttonStyle,
                onPressed: () => {
                  setLoadState(widget.id, context.read<ChatProvider>().loadId,
                      9, context, context.read<ChatProvider>())
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Icon(Icons.location_on),
                    Text('En camino a recogida')
                  ],
                ),
              ),
            ];
          }
          break;
        case 9:
          //MUESTRA SOLO SI ES TRANSPORTISTA
          if (user.isCarrier) {
            children = [
              TextButton(
                style: buttonStyle,
                onPressed: () => {
                  setLoadState(widget.id, context.read<ChatProvider>().loadId,
                      11, context, context.read<ChatProvider>())
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Icon(Icons.arrow_forward_ios_rounded),
                    Text('Recogido y en camino a destino'),
                  ],
                ),
              ),
            ];
          }
          //MUESTRA SOLO SI ES GENERADOR
          if (user.isLoadGenerator) {
            children = [
              TextButton(
                style: buttonStyle,
                onPressed: () => {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Icon(Icons.location_searching_rounded),
                    Text('Ver ubicación del transportista'),
                  ],
                ),
              ),
            ];
          }
          break;
        case 11:
          //MUESTRA SOLO SI ES TRANSPORTISTA
          if (user.isCarrier) {
            children = [
              TextButton(
                style: buttonStyle,
                onPressed: () => {
                  setLoadState(widget.id, context.read<ChatProvider>().loadId,
                      12, context, context.read<ChatProvider>())
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Icon(Icons.check),
                    Text('Entregado'),
                  ],
                ),
              ),
            ];
          }
          break;
        case 12:
          //MUESTRA SOLO SI ES GENERADOR
          if (user.isLoadGenerator) {
            children = [
              TextButton(
                style: buttonStyle,
                onPressed: () => {
                  setLoadState(widget.id, context.read<ChatProvider>().loadId,
                      13, context, context.read<ChatProvider>()),
                  context.read<ChatProvider>().setCanVote(false),
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Icon(Icons.check),
                    Text('Confirmar entrega'),
                  ],
                ),
              ),
            ];
          }
          break;
        case 13:
          //MUESTRA SOLO SI ES GENERADOR
          if (canVote) {
            children = [
              TextButton(
                style: buttonStyle,
                onPressed: () => {
                  showDialog(
                      context: context,
                      builder: (context) => Dialog(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 40),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Que te pareció el trato con el ' +
                                      (user.isCarrier
                                          ? 'generador'
                                          : 'transportista') +
                                      '?'),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  const Stars(),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  TextField(
                                    controller: commentController,
                                    decoration: const InputDecoration(
                                      label: Text('Tienes algún comentario?'),
                                    ),
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null,
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      try {
                                        context
                                            .read<ChatProvider>()
                                            .setCanVote(false);
                                        Navigator.pop(context);
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    'Compruebe su conexión a internet')));
                                      }
                                    },
                                    child: const Text('Votar'),
                                  )
                                ],
                              ),
                            ),
                          ))
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.star),
                    Text('Votar al ' +
                        (user.isCarrier ? 'generador' : 'transportista')),
                  ],
                ),
              ),
            ];
          }
          break;
        default:
          children = [
            const SizedBox(
              height: 20,
            )
          ];
      }
    } else {
      //Si la negociación no está pagada
      if (toPay) {
        //Si la negociación está para pago
        if (user.isLoadGenerator) {
          children = [
            Flexible(
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => Payment(widget.id),
                  ),
                ),
                style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsets>(
                      const EdgeInsets.symmetric(vertical: 20)),
                  backgroundColor: MaterialStateProperty.all<Color>(
                    kBlack,
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(0)),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Text(
                      'Pagar',
                      style: TextStyle(color: Colors.white),
                    ),
                    Icon(Icons.attach_money, color: Colors.white),
                  ],
                ),
              ),
            ),
          ];
        }
      } else {
        print('Puede ofertar? ' + (canOffer ? 'Sí' : 'No'));
        print('Estado de la carga ' + loadState.toString());
        if (loadState == 2 && canOffer) {
          //Si está en negociación
          children = [
            TextButton(
              style: buttonStyle,
              onPressed: () => acceptNegotiation(widget.id, context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Icon(Icons.check),
                  Text('Aceptar'),
                ],
              ),
            ),
            TextButton(
              style: buttonStyle,
              onPressed: () => cancelNegotiation(widget.id, context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Icon(Icons.cancel),
                  Text('Rechazar'),
                ],
              ),
            ),
          ];
        } else {
          children = [
            const SizedBox(
              height: 20,
            )
          ];
        }
      }
    }
    return Row(
      children: children.map((e) => Flexible(flex: 1, child: e)).toList(),
    );
  }
}

class OfferInputSection extends StatelessWidget {
  const OfferInputSection({
    Key? key,
    required this.widget,
  }) : super(key: key);

  final NegotiationChat widget;

  @override
  Widget build(BuildContext context) {
    canOffer = context.watch<ChatProvider>().canOffer;
    showDefaultMessages = context.watch<ChatProvider>().showDefaultMessages;
    return Row(
      children: canOffer
          ? [
              const SizedBox(
                width: 20,
              ),
              Flexible(
                  child: TextField(
                controller: oferta,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Oferto',
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                ),
              )),
              const SizedBox(
                width: 20,
              ),
              IconButton(
                onPressed: () => {
                  sendMessage(widget.id, context, context.read<ChatProvider>())
                },
                icon: const Icon(Icons.send),
                splashColor: Colors.red,
              ),
              const SizedBox(
                width: 20,
              ),
            ]
          : (showDefaultMessages
              ? ([
                  Flexible(
                      flex: 1,
                      child: SizedBox(
                        height: 70,
                        child: ListView(
                          padding: const EdgeInsets.all(20),
                          scrollDirection: Axis.horizontal,
                          children: user.isCarrier
                              ? [
                                  PillButton('Hola!', widget.id),
                                  const SizedBox(width: 10),
                                  PillButton('En camino', widget.id),
                                  const SizedBox(width: 10),
                                  PillButton('Estoy cerca', widget.id),
                                  const SizedBox(width: 10),
                                  PillButton('Ya llegué', widget.id),
                                  const SizedBox(width: 10),
                                  PillButton(
                                    'Enviar ubicación',
                                    widget.id,
                                    isLocation: true,
                                  ),
                                ]
                              : [
                                  PillButton('Hola!', widget.id),
                                  const SizedBox(width: 10),
                                  PillButton('En dónde estás?', widget.id),
                                  const SizedBox(width: 10),
                                  PillButton(
                                      'Ya recogista la carga?', widget.id),
                                  const SizedBox(width: 10),
                                  PillButton(
                                    'Enviar ubicación',
                                    widget.id,
                                    isLocation: true,
                                  ),
                                ],
                        ),
                      ))
                ])
              : []),
    );
  }
}

class ChatPanel extends StatefulWidget {
  const ChatPanel({Key? key}) : super(key: key);

  @override
  State<ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<ChatPanel> {
  @override
  Widget build(BuildContext context) {
    List<ChatMessage> chat = context.watch<ChatProvider>().messages;
    return ListView(
      padding: const EdgeInsets.all(20),
      reverse: true,
      children: List.generate(
        chat.length,
        (index) => chat[index].senderId != user.id
            ? MessageBubbleReceived(
                chat[index].message,
                chat[index].time,
                isImage: chat[index].isImage,
              )
            : MessageBubbleSent(chat[index].message, chat[index].time,
                isImage: chat[index].isImage),
      ),
    );
  }
}

class PillButton extends StatelessWidget {
  PillButton(this.title, this.id, {this.isLocation = false, Key? key})
      : super(key: key);
  String title;
  int id;
  bool isLocation;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => {
        sendMessage(
            id, context, context.read<ChatProvider>(), true, title, isLocation)
      },
      child: Text(
        title,
        style: const TextStyle(color: Colors.orange),
      ),
      style: pillStyle,
    );
  }
}

class Stars extends StatefulWidget {
  const Stars({Key? key}) : super(key: key);

  @override
  State<Stars> createState() => _StarsState();
}

class _StarsState extends State<Stars> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        5,
        (index) => GestureDetector(
          onTap: () => setState(() {
            if (voteStars == 1) {
              voteStars = 0;
            } else {
              voteStars = index + 1;
            }
          }),
          child: Icon(
            (voteStars >= (index + 1) ? Icons.star : Icons.star_border),
            color: Colors.yellow,
            size: 24,
          ),
        ),
      ),
    );
  }
}
