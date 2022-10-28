import 'package:afletes_app_v1/ui/components/base_app.dart';
import 'package:afletes_app_v1/utils/notifications_api.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: context.read<NotificationsApi>().getNotifications(context),
      builder: (context, AsyncSnapshot snapshot) {
        return BaseApp(
          Stack(
            children: [
              const NotificationsPanel(),
              Positioned(
                bottom: 60,
                right: 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(50),
                    ),
                    border: Border.all(
                      color: Colors.grey,
                      style: BorderStyle.solid,
                      width: 1,
                    ),
                  ),
                  child: IconButton(
                    onPressed: () {
                      setState(() {});
                    },
                    icon: const Icon(Icons.refresh),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class NotificationsPanel extends StatefulWidget {
  const NotificationsPanel({Key? key}) : super(key: key);

  @override
  State<NotificationsPanel> createState() => _NotificationsPanelState();
}

class _NotificationsPanelState extends State<NotificationsPanel> {
  bool isLoading = false;
  int page = 1;
  ScrollController scrollController = ScrollController();
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      scrollController.addListener(() async {
        if (scrollController.offset >=
            (scrollController.position.maxScrollExtent -
                MediaQuery.of(context).size.height * 0.1)) {
          if (isLoading) return;

          setState(() {
            isLoading = true;
            page++;
          });

          await context
              .read<NotificationsApi>()
              .getNotifications(context, page: page);

          setState(() {
            isLoading = false;
          });
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    scrollController.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      margin: const EdgeInsets.only(
        top: 70,
        left: 20,
        right: 20,
      ),
      child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.only(
            top: 20,
            bottom: 20,
            left: 20,
            right: 20,
          ),
          children: context.watch<NotificationsApi>().notifications.isNotEmpty
              ? [
                  ...context
                      .watch<NotificationsApi>()
                      .notifications
                      .map(
                        (e) => Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          child: GestureDetector(
                            onTap: () {
                              context
                                  .read<NotificationsApi>()
                                  .readNotification(e, context);
                            },
                            child: Stack(
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 25),
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(100),
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      )
                                    ],
                                    color: Colors.white,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        e.mensaje,
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1,
                                      ),
                                      Text(
                                        e.sentAt,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  bottom: 3,
                                  right: 3,
                                  child: Text(
                                    'Negociación:' + e.negotiationId.toString(),
                                  ),
                                ),
                                if (!e.visto)
                                  const Positioned(
                                    top: 3,
                                    right: 3,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.red,
                                      radius: 10,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  if (isLoading)
                    const Center(
                      child: SizedBox(
                        child: CircularProgressIndicator(),
                        width: 30,
                        height: 30,
                      ),
                    ),
                ]
              : [const Text('No hay notificaciones')]),
    );
  }
}
