import 'package:afletes_app_v1/ui/components/password_input.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with TickerProviderStateMixin {
  late TabController tabController;
  bool canAdvance = false;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFED8232),
        elevation: 0,
      ),
      body: DefaultTabController(
        initialIndex: 0,
        length: 2,
        child: Column(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height * .3,
              width: MediaQuery.of(context).size.width,
              child: const Image(
                image: AssetImage('assets/img/logo.jpg'),
                fit: BoxFit.fitHeight,
              ),
              padding: const EdgeInsets.only(
                bottom: 40,
              ),
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(
                  color: Color(0xFFED8232),
                  borderRadius:
                      BorderRadius.only(bottomLeft: Radius.circular(80))),
            ),
//using expanded means you dont have set height manually
            Expanded(
              child: Form(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 60),
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: TabBarView(
                      physics: canAdvance
                          ? const AlwaysScrollableScrollPhysics()
                          : const NeverScrollableScrollPhysics(),
                      children: <Widget>[
                        //primera parte del login
                        ListView(children: [
                          const FormInput(label: 'Cédula de identidad o RUC'),
                          const SizedBox(
                            height: 20,
                          ),
                          const FormInput(label: 'Razón social'),
                          const SizedBox(
                            height: 20,
                          ),
                          const FormInput(label: 'Nombre'),
                          const SizedBox(
                            height: 20,
                          ),
                          const FormInput(label: 'Apellido'),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () => {
                                    setState(() {
                                      canAdvance = !canAdvance;
                                    }),
                                    DefaultTabController.of(context)!.ani |
                                        mateTo(1,
                                            duration: Duration(seconds: 1))
                                  },
                                  child: const Text(
                                    'Siguiente',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        const Color(0xFFED8232)),
                                    padding: MaterialStateProperty.all(
                                        const EdgeInsets.all(15)),
                                    shape: MaterialStateProperty.all(
                                      const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(100),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ]),
                        ListView(children: const [
                          Text('Documentos'),
                        ]),
                      ]),
                ),
              ),
            )
          ],
        ),
      ),
    );
    //   body: DefaultTabController(
    //     length: 2,
    //     child: Column(
    //       children: [
    //         Container(
    //           height: MediaQuery.of(context).size.height * .3,
    //           child: const Image(
    //             image: AssetImage('assets/img/logo.jpg'),
    //             fit: BoxFit.fitHeight,
    //           ),
    //           padding: const EdgeInsets.only(
    //             bottom: 40,
    //           ),
    //           clipBehavior: Clip.hardEdge,
    //           decoration: const BoxDecoration(
    //               color: Color(0xFFED8232),
    //               borderRadius:
    //                   BorderRadius.only(bottomLeft: Radius.circular(80))),
    //         ),
    //         const Form(
    //           child: Padding(
    //             padding: EdgeInsets.symmetric(vertical: 60, horizontal: 40),
    //             child: TabBarView(
    //               children: [
    //                 Center(child: Text('page 1')),
    //                 Center(child: Text('page 2')),
    //               ],
    //             ),
    //           ),
    //         )
    //       ],
    //     ),
    //   ),
    // );
  }
}

class FormInput extends StatelessWidget {
  const FormInput({Key? key, this.label = '', this.icon = Icons.person})
      : super(key: key);
  final String label;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              blurRadius: 5, color: Color(0xAACCCCCC), offset: Offset(0, 5)),
        ],
        borderRadius: BorderRadius.all(
          Radius.circular(100),
        ),
      ),
      child: TextFormField(
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          label: Text(label),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(100)),
            borderSide: BorderSide(color: Color(0xFFAAAAAA)),
          ),
        ),
      ),
    );
  }
}

// class RegisterPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         margin: const EdgeInsets.only(top: 30),
//         child: DefaultTabController(
//           initialIndex: 0,
//           length: 4,
//           child: Column(children: <Widget>[
//             Container(
//               margin: EdgeInsets.symmetric(horizontal: 30),
//               child: TabBar(
//                   indicatorSize: TabBarIndicatorSize.label,
//                   isScrollable: true,
//                   indicatorColor: Colors.orangeAccent,
//                   unselectedLabelColor: Colors.grey,
//                   labelPadding: EdgeInsets.only(
//                     bottom: 15,
//                   ),
//                   indicatorWeight: 3.5,
//                   labelColor: Colors.black,
//                   labelStyle: TextStyle(
//                     fontWeight: FontWeight.w600,
//                     fontSize: 18,
//                   ),
//                   tabs: <Widget>[
//                     Container(
//                       width: 140,
//                       child: Center(
//                         child: Text("Popular"),
//                       ),
//                     ),
//                     Container(
//                       width: 140,
//                       child: Center(
//                         child: Text("New"),
//                       ),
//                     ),
//                     Container(
//                       width: 140,
//                       child: Center(
//                         child: Text("Recommended"),
//                       ),
//                     ),
//                     Container(
//                       width: 140,
//                       child: Center(
//                         child: Text("Saved"),
//                       ),
//                     ),
//                   ]),
//             ),
// //using expanded means you dont have set height manually
//             Expanded(
//                 child: Container(
//               margin: const EdgeInsets.symmetric(vertical: 25),
//               padding: const EdgeInsets.symmetric(horizontal: 0),
//               child: TabBarView(children: <Widget>[
//                 ListView(
//                   children: List.generate(
//                       100,
//                       (index) => Center(
//                             child: Text('hola'),
//                           )),
//                 ),
//                 Text("New"),
//                 Text("Recommended"),
//                 Text("Saved"),
//               ]),
//             ))
//           ]),
//         ),
//       ),
//     );
//   }
// }
