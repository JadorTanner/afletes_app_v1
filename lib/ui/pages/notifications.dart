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
        future: context.read<NotificationsApi>().getNotifications(),
        builder: (context, AsyncSnapshot snapshot) {
          return RefreshIndicator(
            onRefresh: () => Future(() => setState(() {})),
            child: BaseApp(
              const NotificationsPanel(),
            ),
          );
        });
  }
}

class NotificationsPanel extends StatelessWidget {
  const NotificationsPanel({
    Key? key,
  }) : super(key: key);

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
          padding: const EdgeInsets.only(
            top: 20,
            bottom: 20,
            left: 20,
            right: 20,
          ),
          children: context.watch<NotificationsApi>().notifications.isNotEmpty
              ? context
                  .watch<NotificationsApi>()
                  .notifications
                  .map(
                    (e) => GestureDetector(
                      onTap: () {
                        context
                            .read<NotificationsApi>()
                            .readNotification(e, context);
                      },
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  e.mensaje,
                                  style: Theme.of(context).textTheme.subtitle1,
                                ),
                                Text(
                                  e.sentAt,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 3,
                            right: 3,
                            child: Text(
                                'Negociación:' + e.negotiationId.toString()),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList()
              : [const Text('No hay notificaciones')]),
    );
  }
}
