import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ItemList extends StatelessWidget {
  const ItemList({
    super.key,
    required this.items,
    required this.onEdit,
    required this.onDelete,
  });

  final List<String> items;
  final void Function(int index, String newItem) onEdit;
  final void Function(int index) onDelete;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(items[index]),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  TextEditingController editController = TextEditingController(
                    text: items[index],
                  );
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('tasks.edit_title'.tr()),
                        content: TextField(
                          autofocus: true,
                          controller: editController,
                          decoration: InputDecoration(
                            hintText: 'tasks.edit_hint'.tr(),
                          ),
                        ),
                        actions: [
                          TextButton(
                            child: Text('cancel'.tr()),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text('action.save'.tr()),
                            onPressed: () {
                              onEdit(index, editController.text);
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  onDelete(index);
                },
              ),
            ],
          ),
        );
      },
      separatorBuilder: (context, index) =>
          const Divider(thickness: 1, color: Colors.white10),
    );
  }
}
