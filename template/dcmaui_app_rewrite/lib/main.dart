import 'dart:async';

import 'package:flutter/material.dart';

import 'dart:developer' as developer;

import 'framework/packages/vdom/vdom.dart';
import 'framework/packages/vdom/vdom_node.dart';
import 'framework/packages/vdom/component.dart';
import 'framework/components/comp_props/text_props.dart';
import 'framework/components/ui.dart';
import 'framework/constants/layout_properties.dart';
import 'framework/constants/style_properties.dart';
import 'framework/constants/yoga_enums.dart';
import 'framework/utilities/screen_utilities.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  developer.log('Starting DCMAUI application', name: 'App');

  // Start the native UI application
  startNativeApp();
}

void startNativeApp() async {
  // Initialize screen utilities first
  await ScreenUtilities.instance.refreshDimensions();

  // Log actual screen dimensions for debugging
  developer.log(
      'Screen dimensions: ${ScreenUtilities.instance.screenWidth} x ${ScreenUtilities.instance.screenHeight}',
      name: 'App');

  // Create VDOM instance
  final vdom = VDom();

  // Wait for the VDom to be ready
  await vdom.isReady;
  developer.log('VDom is ready', name: 'App');

  // Create our main app component
  final mainApp = AnimatedAppComponent();

  // Create a component node
  final appNode = vdom.createComponent(mainApp);

  // Render the component to native UI
  await vdom.renderToNative(appNode, parentId: "root", index: 0);
  developer.log(
      'DCMAUI framework successfully initialized and running in headless mode',
      name: 'App');
}

class AnimatedAppComponent extends StatefulComponent {
  @override
  VDomNode render() {
    // State hooks
    final counter = useState(0, 'counter');
    final screenWidth =
        useState(ScreenUtilities.instance.screenWidth, 'screenWidth');
    final screenHeight =
        useState(ScreenUtilities.instance.screenHeight, 'screenHeight');

    // useEffect(() {
    //   screenHeight.setValue(ScreenUtilities.instance.screenHeight);
    //   screenWidth.setValue(ScreenUtilities.instance.screenWidth);
    //   return () {
    //     screenHeight.dispose();
    //     screenWidth.dispose();
    //   };
    // }, dependencies: []);

    return UI.View(
        layout: LayoutProps(
          width: '100%',
          height: '100%',
          alignItems: YogaAlign.center,
          justifyContent: YogaJustifyContent.center,
        ),
        style: StyleSheet(backgroundColor: Colors.amber),
        children: [
          UI.View(
            layout: LayoutProps(height: 100, width: 200),
            style: StyleSheet(
              backgroundColor: Colors.transparent,
              borderRadius: 8,
            ),
            children: [
              UI.Text(
                style: StyleSheet(
                  backgroundColor: Colors.blue,
                  borderRadius: 8,
                ),
                layout: LayoutProps(
                    width: '100%', height: 50, alignSelf: YogaAlign.center),
                content:
                    'Screen: ${screenWidth.value.toInt()} x ${screenHeight.value.toInt()}',
                textProps: TextProps(
                  color: Colors.purpleAccent,
                  fontSize: 20,
                  fontWeight: 'bold',
                ),
              ),
            ],
          ),
        ]);
  }
}
