import 'dart:math';

import 'package:adaptive_app_demos/global/device_type.dart';
import 'package:adaptive_app_demos/global/styling.dart';
import 'package:flutter/material.dart';

class AdaptiveGridView extends StatefulWidget {
  @override
  _AdaptiveGridViewState createState() => _AdaptiveGridViewState();
}

class _AdaptiveGridViewState extends State<AdaptiveGridView> {
  ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    List<Widget> listChildren = List.generate(100, (index) => _GridItem(index));
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // Calculate how many columns we want depending on availabel space
        int colCount = max(1, (constraints.maxWidth / 250).floor());
        return Scrollbar(
          isAlwaysShown: DeviceType.isDesktop,
          controller: _scrollController,
          child: GridView.count(
              controller: _scrollController,
              padding: EdgeInsets.all(Insets.extraLarge),
              childAspectRatio: 1,
              crossAxisCount: colCount,
              children: listChildren),
        );
      },
    );
  }
}

class _GridItem extends StatelessWidget {
  const _GridItem(this.index, {Key? key}) : super(key: key);
  final int index;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(Insets.large),
      child: TextButton(
        onPressed: () {},
        child: Stack(children: [
          Center(child: FlutterLogo(size: 64)),
          Container(color: Colors.grey.withOpacity(.7)),
          Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                  width: double.infinity,
                  color: Colors.grey.shade600,
                  height: 50,
                  alignment: Alignment.center,
                  child: Text("Grid Item $index", style: TextStyle(color: Colors.white))))
        ]),
      ),
    );
  }
}
