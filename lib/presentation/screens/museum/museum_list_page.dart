import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:seekr_app/localization/localization_type.dart';
import 'package:seekr_app/presentation/screens/museum/museum_processing_page.dart';

class MuseumListPage extends StatelessWidget {
  static const routePath = '/museum-list';
  static const routeName = 'museum-list';
  const MuseumListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: Semantics(
              sortKey: const OrdinalSortKey(2),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      backgroundColor: Colors.blue.shade200,
                      shape: const RoundedRectangleBorder(),
                      foregroundColor: Colors.white,
                      textStyle:
                          Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              )),
                  onPressed: () {
                    context.pop();
                  },
                  child: Text(Words.of(context)!.goBack)),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                CupertinoListSection.insetGrouped(
                  header: const Text('Available Museums'),
                  children: [
                    CupertinoListTile(
                      title: Text('YMCA'),
                      onTap: () {
                        context.push(MuseumProcessingPage.routePath);
                      },
                    ),
                    CupertinoListTile(
                      title: Text('Museum 2'),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Coming soon!'),
                          ),
                        );
                      },
                    ),
                    CupertinoListTile(
                      title: Text('Museum 3'),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Coming soon!'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
