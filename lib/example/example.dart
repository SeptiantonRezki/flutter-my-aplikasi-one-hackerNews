import 'dart:collection';

import 'package:rxdart/rxdart.dart';

void main() {
  // ada list
  // listnya mau-nya kosong diganti digantikan dengan ber isi
  var contohIntSatu = <UnmodifiableListView<int>>[];
  final contohIntDua = BehaviorSubject<UnmodifiableListView<int>>();
  final contohIntTIga = Map<int, String>();
  var angkaList = [1, 2, 3, 4, 5];
  contohIntSatu.add(UnmodifiableListView(angkaList));

  contohIntDua.add(UnmodifiableListView(angkaList));
  print(contohIntSatu);
  print(contohIntSatu[0].length);
  print(contohIntDua);
}
