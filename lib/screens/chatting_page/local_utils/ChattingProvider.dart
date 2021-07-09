import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2_chat/models/ChattingModel.dart';
import 'package:flutter_application_2_chat/screens/chatting_page/local_widgets/chatting_item.dart';

class ChattingProvider extends ChangeNotifier {
  static const String CHATTING_ROOM = 'CHATTING_ROOM';

  ChattingProvider(this.pk, this.name);
  final String pk;
  final String name;

  var chattingList = <ChattingModel>[];

  Stream<QuerySnapshot> getSnapshot() {
    final f = FirebaseFirestore.instance;
    return f
        .collection(CHATTING_ROOM)
        .limit(1)
        .orderBy('uploadTime', descending: true)
        .snapshots();
  }

  void addOne(ChattingModel model) {
    chattingList.insert(0, model);
    notifyListeners();
  }

  Future load() async {
    var now =
        DateTime.now().add(const Duration(days: -10)).millisecondsSinceEpoch;
    final f = FirebaseFirestore.instance;
    var result = await f
        .collection(CHATTING_ROOM)
        .where('uploadTime', isGreaterThan: now)
        .orderBy('uploadTime', descending: true)
        .get();

    var l = result.docs.map((e) => ChattingModel.fromJson(e.data())).toList();
    chattingList.addAll(l);
    notifyListeners();
  }

  Future send(String text) async {
    var now = DateTime.now().millisecondsSinceEpoch;
    final f = FirebaseFirestore.instance;
    await f
        .collection(CHATTING_ROOM)
        .doc(now.toString())
        .set(ChattingModel(pk, name, text, now).toJson());
  }
}
