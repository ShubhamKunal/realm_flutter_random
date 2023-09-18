import 'package:flutter/material.dart';
import 'package:realm/realm.dart';

import '../settings/settings_view.dart';
import 'sample_item.dart';
import 'sample_item_details_view.dart';

class Lister {
  final RealmResults<SampleItem> items;
  final Realm _realm;
  Lister({required this.items}) : _realm = items.realm;
  void addNewItem() {
    _realm.write(() => _realm.add(SampleItem(
        ObjectId(), 1 + ((items.lastOrNull == null) ? 0 : items.last.no))));
  }
}

/// Displays a list of SampleItems.
class SampleItemListView extends StatelessWidget {
  const SampleItemListView({
    super.key,
    required this.lister,
  });

  static const routeName = '/';

  final Lister lister;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sample Items'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to the settings page. If the user leaves and returns
              // to the app after it has been killed while running in the
              // background, the navigation stack is restored.
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: lister.addNewItem,
        child: const Icon(Icons.add),
      ),
      // To work with lists that may contain a large number of items, it’s best
      // to use the ListView.builder constructor.
      //
      // In contrast to the default ListView constructor, which requires
      // building all Widgets up front, the ListView.builder constructor lazily
      // builds Widgets as they’re scrolled into view.
      body: StreamBuilder<Object>(
          stream: lister.items.changes,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            return ListView.builder(
              // Providing a restorationId allows the ListView to restore the
              // scroll position when a user leaves and returns to the app after it
              // has been killed while running in the background.
              restorationId: 'sampleItemListView',
              itemCount: lister.items.length,
              itemBuilder: (BuildContext context, int index) {
                final item = lister.items[index];

                return SampleItemTile(itemU: ItemUnit(item: item));
              },
            );
          }),
    );
  }
}

class ItemUnit {
  final SampleItem item;
  final Realm _realm;
  ItemUnit({required this.item}) : _realm = item.realm;

  void deleteItem() {
    _realm.write(() => _realm.delete(item));
  }
}

class SampleItemTile extends StatelessWidget {
  const SampleItemTile({
    super.key,
    required this.itemU,
  });
  final ItemUnit itemU;

  @override
  Widget build(BuildContext context) {
    final item = itemU.item;
    return Dismissible(
      key: ValueKey(item.id),
      onDismissed: (direction) => itemU.deleteItem(),
      background: Container(
        color: Colors.red,
      ),
      child: ListTile(
          title: Text('SampleItem ${item.id}'),
          leading: const CircleAvatar(
            // Display the Flutter Logo image asset.
            foregroundImage: AssetImage('assets/images/flutter_logo.png'),
          ),
          onTap: () {
            // Navigate to the details page. If the user leaves and returns to
            // the app after it has been killed while running in the
            // background, the navigation stack is restored.
            Navigator.restorablePushNamed(
              context,
              SampleItemDetailsView.routeName,
            );
          }),
    );
  }
}
