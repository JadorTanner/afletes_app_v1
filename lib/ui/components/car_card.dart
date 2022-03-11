import 'dart:convert';

import 'package:afletes_app_v1/utils/globals.dart';
import 'package:afletes_app_v1/utils/vehicles.dart';
import 'package:flutter/material.dart';

class CarCard2 extends StatefulWidget {
  CarCard2(this.vehicle, {this.onTap, Key? key}) : super(key: key);
  var onTap;
  Vehicle vehicle;

  @override
  State<CarCard2> createState() => _CarCard2State();
}

class _CarCard2State extends State<CarCard2> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap ?? () => {},
      // onTap: () => Navigator.of(context)
      //     .push(MaterialPageRoute(builder: (context) => VehicleInfo)),
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
                tag: 'vehicle_' + widget.vehicle.id.toString(),
                child: widget.vehicle.imgs.isNotEmpty
                    ? Image.network(
                        vehicleImgUrl + widget.vehicle.imgs[0]['path'])
                    : const Image(
                        image: AssetImage('assets/img/noimage.png'),
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
                          text: ' ' + widget.vehicle.licensePlate,
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
                      children: List.generate(widget.vehicle.score,
                          (index) => const StarFeedBack()),
                    )
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    (widget.vehicle.dinatran
                        ? const Text(
                            'DINATRAN',
                            style: TextStyle(fontSize: 12),
                          )
                        : const SizedBox.shrink()),
                    (widget.vehicle.senacsa
                        ? const Text(
                            'SENACSA',
                            style: TextStyle(fontSize: 12),
                          )
                        : const SizedBox.shrink()),
                    (widget.vehicle.seguro
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
                ),
                Text(widget.vehicle.owner != null
                    ? widget.vehicle.owner!.fullName
                    : '')
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
