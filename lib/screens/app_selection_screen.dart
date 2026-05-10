import 'package:flutter/material.dart';

import 'package:installed_apps/app_info.dart';

class AppSelectionScreen extends StatefulWidget {
  final List<AppInfo> installedApps;

  const AppSelectionScreen({super.key, required this.installedApps});

  @override
  State<AppSelectionScreen> createState() => _AppSelectionScreenState();
}

class _AppSelectionScreenState extends State<AppSelectionScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<AppInfo> _filteredApps = [];

  @override
  void initState() {
    super.initState();
    _filteredApps = widget.installedApps;
    _searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchCtrl.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredApps = widget.installedApps;
      } else {
        _filteredApps =
            widget.installedApps
                .where((app) => app.name.toLowerCase().contains(query))
                .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select App'),
        backgroundColor: scheme.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  labelText: 'Search Apps',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: scheme.primary,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),
            Expanded(
              child:
                  _filteredApps.isEmpty
                      ? Center(
                        child: Text(
                          "No apps found.",
                          style: TextStyle(
                            color: scheme.onSurface.withValues(alpha: 0.6),
                            fontSize: 16,
                          ),
                        ),
                      )
                      : ListView.builder(
                        itemCount: _filteredApps.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return ListTile(
                              title: const Text("Add manually"),
                              leading: CircleAvatar(
                                backgroundColor: scheme.primary.withValues(alpha: 0.1),
                                child: Icon(
                                  Icons.add_rounded,
                                  color: scheme.primary,
                                ),
                              ),
                              onTap: () {
                                Navigator.pop(context, "__ADD_MANUALLY__");
                              },
                            );
                          }
                          final app = _filteredApps[index - 1];
                          final appName = app.name;
                          return ListTile(
                            title: Text(appName),
                            leading:
                                app.icon != null
                                    ? Image.memory(
                                      app.icon!,
                                      width: 40,
                                      height: 40,
                                    )
                                    : CircleAvatar(
                                      backgroundColor: scheme.primary
                                          .withValues(alpha: 0.1),
                                      child: Icon(
                                        Icons.widgets_rounded,
                                        color: scheme.primary,
                                      ),
                                    ),
                            onTap: () {
                              Navigator.pop(context, appName);
                            },
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
