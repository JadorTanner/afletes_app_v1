import 'package:afletes_app_v1/models/notifications.dart';
import 'package:afletes_app_v1/ui/components/base_app.dart';
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
        future: context.read<NotificationsModel>().getNotifications(),
        builder: (context, AsyncSnapshot snapshot) {
          return RefreshIndicator(
            onRefresh: () => Future(() => setState(() {})),
            child: BaseApp(
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
                child: ListView(
                    padding: const EdgeInsets.only(
                      top: 20,
                      bottom: 20,
                      left: 20,
                      right: 20,
                    ),
                    children: context
                            .watch<NotificationsModel>()
                            .notifications
                            .isNotEmpty
                        ? context
                            .watch<NotificationsModel>()
                            .notifications
                            .map(
                              (e) => GestureDetector(
                                onTap: () {
                                  NotificationsModel()
                                      .readNotification(e, context);
                                },
                                child: Container(
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
                                  child: Text(e.mensaje),
                                ),
                              ),
                            )
                            .toList()
                        : [const Text('No hay notificaciones')]),
              ),
            ),
          );
        });
  }
}
