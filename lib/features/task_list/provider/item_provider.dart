import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

final itemProvider = NotifierProvider<ItemNotifier, List<String>>(
  ItemNotifier.new,
);

class ItemNotifier extends Notifier<List<String>> {
  late final Box box;

  @override
  List<String> build() {
    box = Hive.box('HabitFlowBox');

    // Listen to changes in Hive box
    box.watch(key: 'TODO_LIST').listen((_) {
      state = box.get('TODO_LIST', defaultValue: <String>[]).cast<String>();
    });

    // Initial state
    return box.get('TODO_LIST', defaultValue: <String>[]).cast<String>();
  }

  void addItem(String item) {
    final updatedList = [...state, item];
    box.put('TODO_LIST', updatedList);
    state = updatedList;
  }

  void editItem(int index, String newItem) {
    final updatedList = [...state];
    updatedList[index] = newItem;
    box.put('TODO_LIST', updatedList);
    state = updatedList;
  }

  void deleteItem(int index) {
    final updatedList = [...state]..removeAt(index);
    box.put('TODO_LIST', updatedList);
    state = updatedList;
  }
}
