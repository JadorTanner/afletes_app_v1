import 'package:afletes_app_v1/ui/pages/vehicles/vehicle_info.dart';
import 'package:afletes_app_v1/utils/vehicles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CarCard2 extends StatelessWidget {
  CarCard2(this.vehicle, {Key? key}) : super(key: key);

  Vehicle vehicle;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => VehicleInfo(vehicle))),
      child: Container(
        clipBehavior: Clip.none,
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(bottom: 15),
        width: MediaQuery.of(context).size.width - 20,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border.fromBorderSide(
              BorderSide(width: 1, color: Color(0xFFCCCCCC))),
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
                offset: Offset(0, 10),
                color: Color(0xFFBBBBBB),
                blurRadius: 10),
          ],
        ),
        child: Column(
          children: [
            Container(
              height: 115,
              width: 270,
              // decoration: const BoxDecoration(
              //     image: DecorationImage(
              //         image: AssetImage('assets/img/image 121.png'),
              //         fit: BoxFit.fitWidth)),
              child: Hero(
                tag: 'vehicle_' + vehicle.id.toString(),
                child: const Image(
                  image: AssetImage('assets/img/image 121.png'),
                ),
              ),
            ),
            const Divider(
              indent: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    RichText(
                      text: TextSpan(children: [
                        const WidgetSpan(
                          child: Icon(Icons.directions_car,
                              color: Color.fromRGBO(22, 22, 26, 1)),
                        ),
                        TextSpan(
                          text: ' ' + vehicle.licensePlate,
                          style: const TextStyle(
                              color: Color.fromRGBO(22, 22, 26, 1),
                              fontFamily: 'Inter',
                              fontSize: 16,
                              letterSpacing: 0,
                              fontWeight: FontWeight.normal,
                              height: 1),
                        ),
                      ]),
                    ),
                    const Spacer(flex: 1),
                    Row(
                      children:
                          List.generate(5, (index) => const StarFeedBack()),
                    )
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    (vehicle.dinatran
                        ? const Text(
                            'DINATRAN',
                            style: TextStyle(fontSize: 12),
                          )
                        : const SizedBox.shrink()),
                    (vehicle.senacsa
                        ? const Text(
                            'SENACSA',
                            style: TextStyle(fontSize: 12),
                          )
                        : const SizedBox.shrink()),
                    (vehicle.seguro
                        ? const Text(
                            'SEGURO',
                            style: TextStyle(fontSize: 12),
                          )
                        : const SizedBox.shrink()),
                    // ( ? const Text(
                    //   'A/C',
                    //   style: TextStyle(fontSize: 12),
                    // ) : const SizedBox.shrink()),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class StarFeedBack extends StatelessWidget {
  const StarFeedBack({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.star, color: Colors.yellow);
  }
}

class CarCard extends StatelessWidget {
  const CarCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 335,
      height: 257,
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: 335,
              height: 190,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                  bottomLeft: Radius.circular(0),
                  bottomRight: Radius.circular(0),
                ),
                color: const Color.fromRGBO(245, 246, 248, 1),
                border: Border.all(
                  color: const Color.fromRGBO(226, 226, 226, 1),
                  width: 1,
                ),
              ),
            ),
          ),
          const Positioned(
              top: 133,
              left: 12,
              child: Text(
                'AYGO',
                textAlign: TextAlign.left,
                style: TextStyle(
                    color: Color.fromRGBO(22, 22, 26, 1),
                    fontFamily: 'Inter',
                    fontSize: 14,
                    letterSpacing:
                        0 /*percentages not used in flutter. defaulting to zero*/,
                    fontWeight: FontWeight.normal,
                    height: 1),
              )),
          Positioned(
              top: 162,
              left: 38,
              child: SizedBox(
                child: Row(
                  children: const [
                    Icon(
                      Icons.settings_input_component_sharp,
                      size: 12,
                    ),
                    Text(
                      'A/T',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          color: Color.fromRGBO(22, 22, 26, 1),
                          fontFamily: 'Inter',
                          fontSize: 12,
                          letterSpacing:
                              0 /*percentages not used in flutter. defaulting to zero*/,
                          fontWeight: FontWeight.normal,
                          height: 1),
                    )
                  ],
                ),
              )),
          const Positioned(
              top: 162,
              left: 98,
              child: Text(
                '5',
                textAlign: TextAlign.left,
                style: TextStyle(
                    color: Color.fromRGBO(22, 22, 26, 1),
                    fontFamily: 'Inter',
                    fontSize: 12,
                    letterSpacing:
                        0 /*percentages not used in flutter. defaulting to zero*/,
                    fontWeight: FontWeight.normal,
                    height: 1),
              )),
          const Positioned(
              top: 162,
              left: 144,
              child: Text(
                '4',
                textAlign: TextAlign.left,
                style: TextStyle(
                    color: Color.fromRGBO(22, 22, 26, 1),
                    fontFamily: 'Inter',
                    fontSize: 12,
                    letterSpacing:
                        0 /*percentages not used in flutter. defaulting to zero*/,
                    fontWeight: FontWeight.normal,
                    height: 1),
              )),
          const Positioned(
              top: 162,
              left: 190,
              child: Text(
                'A/C',
                textAlign: TextAlign.left,
                style: TextStyle(
                    color: Color.fromRGBO(22, 22, 26, 1),
                    fontFamily: 'Inter',
                    fontSize: 12,
                    letterSpacing:
                        0 /*percentages not used in flutter. defaulting to zero*/,
                    fontWeight: FontWeight.normal,
                    height: 1),
              )),
          Positioned(
            top: 189,
            left: 0,
            child: Container(
              width: 335,
              height: 68,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(0),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                color: const Color.fromRGBO(234, 236, 240, 1),
                border: Border.all(
                  color: const Color.fromRGBO(226, 226, 226, 1),
                  width: 1,
                ),
              ),
            ),
          ),
          Positioned(
            top: 206,
            left: 292,
            child: SizedBox(
              width: 32,
              height: 34,
              child: Stack(children: const <Widget>[
                Positioned(
                    top: 19,
                    left: 0,
                    child: Text(
                      '\$250',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          color: Color.fromRGBO(44, 182, 125, 1),
                          fontFamily: 'Inter',
                          fontSize: 12,
                          letterSpacing:
                              0 /*percentages not used in flutter. defaulting to zero*/,
                          fontWeight: FontWeight.normal,
                          height: 1),
                    )),
                Positioned(
                    top: 0,
                    left: 0,
                    child: Text(
                      'Day/',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          color: Color.fromRGBO(22, 22, 26, 1),
                          fontFamily: 'Inter',
                          fontSize: 12,
                          letterSpacing:
                              0 /*percentages not used in flutter. defaulting to zero*/,
                          fontWeight: FontWeight.normal,
                          height: 1),
                    )),
              ]),
            ),
          ),
          Positioned(
            top: 161,
            left: 118,
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/images/Cardoor.png'),
                    fit: BoxFit.fitWidth),
              ),
            ),
          ),
          Positioned(
            top: 161,
            left: 164,
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/images/Sun.png'),
                    fit: BoxFit.fitWidth),
              ),
            ),
          ),
          Positioned(
            top: 160,
            left: 72,
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/images/Useraccount.png'),
                    fit: BoxFit.fitWidth),
              ),
            ),
          ),
          Positioned(
            top: 161,
            left: 12,
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/images/Gearbox.png'),
                    fit: BoxFit.fitWidth),
              ),
            ),
          ),
          Positioned(
            top: 202,
            left: 12,
            child: SizedBox(
              width: 131,
              height: 13,
              child: Stack(children: <Widget>[
                Positioned(
                    top: 0,
                    left: 20,
                    child: SizedBox(
                      height: 20,
                      child: RichText(
                        text: const TextSpan(children: [
                          WidgetSpan(
                            child: Icon(Icons.check, color: Colors.green),
                          ),
                          TextSpan(
                            text: 'Instant confirmation',
                            style: TextStyle(
                                color: Color.fromRGBO(22, 22, 26, 1),
                                fontFamily: 'Inter',
                                fontSize: 11,
                                letterSpacing:
                                    0 /*percentages not used in flutter. defaulting to zero*/,
                                fontWeight: FontWeight.normal,
                                height: 1),
                          ),
                        ]),
                      ),
                    )
                    // Text(
                    //   'Instant confirmation',
                    //   textAlign: TextAlign.left,
                    //   style: TextStyle(
                    //       color: Color.fromRGBO(22, 22, 26, 1),
                    //       fontFamily: 'Inter',
                    //       fontSize: 11,
                    //       letterSpacing:
                    //           0 /*percentages not used in flutter. defaulting to zero*/,
                    //       fontWeight: FontWeight.normal,
                    //       height: 1),
                    // )
                    ),
                Positioned(
                  top: 2,
                  left: 0,
                  child: SizedBox(
                    width: 12,
                    height: 8.25,
                    child: Stack(children: <Widget>[
                      Positioned(
                        top: 0,
                        left: 0,
                        child: SvgPicture.asset('assets/images/vector.svg',
                            semanticsLabel: 'vector'),
                      ),
                    ]),
                  ),
                ),
              ]),
            ),
          ),
          Positioned(
            top: 230,
            left: 12,
            child: SizedBox(
              width: 111,
              height: 13,
              child: Stack(children: <Widget>[
                const Positioned(
                    top: 0,
                    left: 20,
                    child: Text(
                      'Free cancelation',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          color: Color.fromRGBO(22, 22, 26, 1),
                          fontFamily: 'Inter',
                          fontSize: 11,
                          letterSpacing:
                              0 /*percentages not used in flutter. defaulting to zero*/,
                          fontWeight: FontWeight.normal,
                          height: 1),
                    )),
                Positioned(
                  top: 2,
                  left: 0,
                  child: SizedBox(
                    width: 12,
                    height: 8.25,
                    child: Stack(children: <Widget>[
                      Positioned(
                        top: 0,
                        left: 0,
                        child: SvgPicture.asset('assets/images/vector.svg',
                            semanticsLabel: 'vector'),
                      ),
                    ]),
                  ),
                ),
              ]),
            ),
          ),
          Positioned(
            top: 8,
            left: 36,
            child: Container(
              width: 274,
              height: 113,
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/img/image 121.png'),
                    fit: BoxFit.fitWidth),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
