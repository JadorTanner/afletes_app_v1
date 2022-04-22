import 'package:afletes_app_v1/ui/components/base_app.dart';
import 'package:afletes_app_v1/ui/components/load_card.dart';
import 'package:afletes_app_v1/utils/loads.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PendingLoadsPage extends StatefulWidget {
  const PendingLoadsPage({Key? key}) : super(key: key);

  @override
  State<PendingLoadsPage> createState() => _PendingLoadsPageState();
}

class _PendingLoadsPageState extends State<PendingLoadsPage> {
  @override
  Widget build(BuildContext context) {
    return BaseApp(
      FutureBuilder(future: Future(() async {
        await context.read<Load>().getPendingLoad(context);
      }), builder: (context, AsyncSnapshot snapshot) {
        return RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: ListView(
            padding: const EdgeInsets.only(
              top: 80,
              bottom: 20,
              left: 20,
              right: 20,
            ),
            children: context
                .watch<Load>()
                .pendingLoads
                .map(
                  (Load load) => LoadCard(
                    load,
                    hasData: true,
                    isCarrier: true,
                    isFinalOffer: true,
                  ),
                )
                .toList(),
          ),
        );
      }),
    );
  }
}
