import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class TargetedActionRoot extends StatefulWidget {
  TargetedActionRoot({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  State<TargetedActionRoot> createState() => _TargetedActionRootState();
}

class _TargetedActionRootState extends State<TargetedActionRoot> {
  late _TargetedActionRegistry registry;
  late final GlobalKey registryKey;
  Map<ShortcutActivator, Intent> mappedShortcuts = <ShortcutActivator, Intent>{};

  @override
  void initState() {
    super.initState();
    registryKey = GlobalKey();
    registry = _TargetedActionRegistry(registryKey: registryKey);
    registry.addListener(_registryChanged);
    mappedShortcuts = _buildShortcuts();
  }

  @override
  void dispose() {
    registry.removeListener(_registryChanged);
    super.dispose();
  }

  void _registryChanged() {
    setState(() {
      mappedShortcuts = _buildShortcuts();
    });
  }

  Map<ShortcutActivator, Intent> _buildShortcuts() {
    Map<ShortcutActivator, Intent> mapped = <ShortcutActivator, Intent>{};
    for (final ShortcutActivator activator in registry.shortcuts.keys) {
      mapped[activator] = _TargetedIntent(registry.registryKey, registry.shortcuts[activator]!);
    }
    return mapped;
  }

  @override
  Widget build(BuildContext context) {
    registry.inBuild = true;
    Widget result = ChangeNotifierProvider<_TargetedActionRegistry>.value(
      value: registry,
      child: Shortcuts(
        shortcuts: mappedShortcuts,
        child: Actions(
          actions: <Type, Action<Intent>>{
            _TargetedIntent: _TargetedAction(),
          },
          child: KeyedSubtree(
            key: registryKey,
            child: widget.child,
          ),
        ),
      ),
    );
    registry.inBuild = false;
    return result;
  }
}

class TargetedActionBinding extends StatelessWidget {
  TargetedActionBinding({Key? key, required this.child, required this.shortcuts, this.actions})
      : _subtreeKey = GlobalKey(),
        super(key: key);

  final Widget child;
  final Map<ShortcutActivator, Intent> shortcuts;
  final Map<Type, Action<Intent>>? actions;
  final GlobalKey _subtreeKey;

  @override
  Widget build(BuildContext context) {
    _TargetedActionRegistry registry = Provider.of<_TargetedActionRegistry>(context);
    registry.addShortcuts(shortcuts);
    registry.targetKey = _subtreeKey;
    Widget child = KeyedSubtree(
      key: _subtreeKey,
      child: this.child,
    );
    if (actions != null) {
      child = Actions(actions: actions!, child: child);
    }
    return Shortcuts(
      shortcuts: shortcuts,
      child: child,
    );
  }
}

class _TargetedActionRegistry extends ChangeNotifier {
  _TargetedActionRegistry({GlobalKey? initialKey, required this.registryKey})
      : _targetKey = initialKey,
        _shortcuts = <ShortcutActivator, Intent>{};

  GlobalKey? get targetKey => _targetKey;
  GlobalKey? _targetKey;
  set targetKey(GlobalKey? value) {
    if (_targetKey != value) {
      _targetKey = value;
      scheduleMicrotask(() => notifyListeners());
    }
  }

  bool get inBuild => _inBuild;
  bool _inBuild = false;
  set inBuild(bool value) {
    if (_inBuild != value) {
      _inBuild = value;
      if (inBuild) {
        _shortcuts.clear();
      } else {
        // Have to do this in a microtask because children can't cause parents
        // to rebuild during the build. This means causing an extra frame
        // whenever the root builds.
        scheduleMicrotask(() => notifyListeners());
      }
    }
  }

  Map<ShortcutActivator, Intent> get shortcuts => _shortcuts;
  Map<ShortcutActivator, Intent> _shortcuts;
  void addShortcuts(Map<ShortcutActivator, Intent> value) {
    assert(value.keys.toSet().intersection(_shortcuts.keys.toSet()).isEmpty,
      'Warning: duplicate key binding for these activators: ${value.keys.toSet().intersection(_shortcuts.keys.toSet())}'
    );
    _shortcuts.addAll(value);
  }

  final GlobalKey registryKey;

  Object? invoke(Intent intent) {
    if (targetKey != null && targetKey!.currentContext != null) {
      return Actions.invoke(targetKey!.currentContext!, intent);
    }
    return null;
  }
}

class _TargetedIntent extends Intent {
  const _TargetedIntent(this.registryKey, this.intent);

  final GlobalKey registryKey;
  final Intent intent;
}

class _TargetedAction extends Action<_TargetedIntent> {
  _TargetedAction();

  @override
  Object? invoke(covariant _TargetedIntent intent) {
    if (intent.registryKey.currentContext != null) {
      Provider.of<_TargetedActionRegistry>(intent.registryKey.currentContext!, listen: false)
          .invoke(intent.intent);
    }
  }
}
