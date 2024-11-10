import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:camera_app/main.dart';

void main() {
  testWidgets('Camera app smoke test', (WidgetTester tester) async {
    // Build the CameraApp widget and trigger a frame.
    await tester.pumpWidget(CameraApp());

    // Verify if the camera icon button is displayed.
    expect(find.byIcon(Icons.camera_alt), findsOneWidget);

    // Tap the camera button to simulate taking a picture.
    await tester.tap(find.byIcon(Icons.camera_alt));
    await tester.pump();

    // Verify that tapping the camera button results in a "Picture taken" snackbar.
    expect(find.text('Picture taken'), findsOneWidget);
  });
}
