



import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'provider.dart';

Widget mainScreenWidget(){
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('сканируй QR-код или штрих-код,\nа я выведу результат ниже:', textAlign: TextAlign.center, style: TextStyle(fontSize: 16),),
        const SizedBox(height: 20,),
        Consumer(
          builder: (context, ref, child) {
            final scanResult = ref.watch(scanProvider);
            return Text(scanResult, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 22), textAlign: TextAlign.center,);
          }
        )
      ],
    ),
  );
}