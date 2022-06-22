// ignore_for_file: must_be_immutable

import 'package:afletes_app_v1/models/notifications.dart';
import 'package:afletes_app_v1/models/user.dart';
import 'package:afletes_app_v1/ui/pages/my_profile.dart';
import 'package:afletes_app_v1/utils/constants.dart';
import 'package:afletes_app_v1/utils/loads.dart';
import 'package:afletes_app_v1/utils/notifications_api.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BaseApp extends StatefulWidget {
  BaseApp(this.body,
      {this.title = '',
      this.resizeToAvoidBottomInset = false,
      this.isMap = false,
      this.floatingButton,
      this.onPop,
      this.scaffKey,
      Key? key})
      : super(key: key);
  Widget body;
  String title;
  bool resizeToAvoidBottomInset, isMap;
  FloatingActionButton? floatingButton;
  GlobalKey<ScaffoldState>? scaffKey;
  var onPop;
  @override
  State<BaseApp> createState() => _BaseAppState();
}

class _BaseAppState extends State<BaseApp> {
  late ThemeData theme;

  @override
  Widget build(BuildContext context) {
    widget.scaffKey = widget.scaffKey ?? GlobalKey<ScaffoldState>();
    theme = Theme.of(context);
    return Scaffold(
      key: widget.scaffKey,
      backgroundColor: const Color(0xFFEBE3CD),
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
      drawer: CustomDrawer(theme: theme),
      body: SafeArea(
        child: Stack(
          children: [
            widget.body,
            Positioned(
              top: 40,
              left: 20,
              child: widget.floatingButton ?? const SizedBox.shrink(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.only(top: 20, left: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.white,
                  ),
                  child: IconButton(
                    onPressed: () =>
                        {widget.scaffKey!.currentState!.openDrawer()},
                    icon: const Icon(Icons.menu, size: 20),
                  ),
                ),
                Navigator.canPop(context) && !widget.isMap
                    ? Container(
                        width: 40,
                        height: 40,
                        margin: const EdgeInsets.only(top: 20, right: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.white,
                        ),
                        child: IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            if (widget.onPop != null) {
                              widget.onPop();
                            }
                          },
                          icon: const Icon(Icons.chevron_left, size: 20),
                        ),
                      )
                    : const SizedBox.shrink()
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CustomDrawer extends StatefulWidget {
  CustomDrawer({
    Key? key,
    required this.theme,
  }) : super(key: key);
  ThemeData theme;

  @override
  State<StatefulWidget> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  late User user;
  late Load loadProvider;
  late ThemeData theme;
  late List<NotificationModel> notifications;
  @override
  void initState() {
    super.initState();
    theme = widget.theme;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadProvider = Provider.of<Load>(context);
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<User>(context).user;
    notifications = context.watch<NotificationsApi>().notifications;

    return Drawer(
      child: SafeArea(
        minimum: const EdgeInsets.all(15),
        child: ListView(
          children: [
            const SizedBox(
              height: 20,
            ),
            CircleAvatar(
              backgroundColor: theme.backgroundColor,
              minRadius: 60,
              child: Text(
                user.fullName
                    .split(' ')
                    .map((e) => e.length > 2 ? e.substring(0, 1) : '')
                    .join(''),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(user.fullName),
            Text(user.email),
            const SizedBox(
              height: 25,
            ),
            Container(
              width: double.infinity,
              height: 1,
              color: theme.dividerColor,
            ),
            const SizedBox(
              height: 25,
            ),
            TextButton.icon(
              onPressed: () => {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => MyProfilePage(user),
                ))
              },
              icon: CircleAvatar(
                backgroundColor: Constants.kGrey,
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                ),
              ),
              label: Container(
                padding: const EdgeInsets.all(15),
                width: double.infinity,
                child: Text(
                  'Mi perfil',
                  style: theme.textTheme.bodyText1,
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            DrawerItem(
                user.isCarrier ? '/my-vehicles' : '/my-loads',
                user.isCarrier ? 'Mis vehículos' : 'Mis cargas',
                Icons.local_activity),
            const SizedBox(
              height: 15,
            ),
            DrawerItem(
                user.isCarrier ? '/loads' : '/vehicles',
                user.isCarrier ? 'Buscar cargas' : 'Buscar vehículos',
                Icons.search),
            const SizedBox(
              height: 15,
            ),
            DrawerItem('/my-negotiations', 'Mis negociaciones', Icons.ac_unit),
            const SizedBox(
              height: 15,
            ),
            user.isCarrier
                ? DrawerItem(
                    '/pending-loads', 'Cargas pendientes', Icons.all_inbox)
                : const SizedBox.shrink(),
            Stack(
              children: [
                TextButton.icon(
                  onPressed: () =>
                      {Navigator.of(context).pushNamed('/notifications')},
                  icon: CircleAvatar(
                    backgroundColor: Constants.kGrey,
                    child: const Icon(
                      Icons.notification_important,
                      color: Colors.white,
                    ),
                  ),
                  label: Container(
                    padding: const EdgeInsets.all(15),
                    width: double.infinity,
                    child: Text(
                      'Notificaciones',
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ),
                ),
                notifications.isNotEmpty
                    ? const Positioned(
                        top: 5,
                        left: 5,
                        child: CircleAvatar(
                          backgroundColor: Colors.red,
                          maxRadius: 10,
                        ),
                      )
                    : const SizedBox.shrink()
              ],
            ),
            const SizedBox(
              height: 80,
            ),
            LogOutButton(user),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class LogOutButton extends StatefulWidget {
  LogOutButton(this.user, {Key? key}) : super(key: key);
  User user;
  @override
  State<LogOutButton> createState() => _LogOutButtonState();
}

class _LogOutButtonState extends State<LogOutButton> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: isLoading
          ? () {}
          : () async {
              setState(() {
                isLoading = !isLoading;
              });
              await widget.user.logout(context);
              setState(() {
                isLoading = !isLoading;
              });
            },
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(),
            )
          : const Text(
              'Cerrar sesión',
              style: TextStyle(
                decoration: TextDecoration.underline,
              ),
            ),
    );
  }
}

class DrawerItem extends StatelessWidget {
  DrawerItem(this.routeName, this.title, this.icon, {Key? key})
      : super(key: key);
  String routeName;
  String title;
  IconData icon;
  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => {Navigator.of(context).pushNamed(routeName)},
      icon: CircleAvatar(
        backgroundColor: Constants.kGrey,
        child: Icon(
          icon,
          color: Colors.white,
        ),
      ),
      label: Container(
        padding: const EdgeInsets.all(15),
        width: double.infinity,
        child: Text(
          title,
          style: Theme.of(context).textTheme.bodyText1,
        ),
      ),
    );
  }
}
