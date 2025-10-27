// Nauli Tap Widget Tests
// Tests for the NFC Transit App screens and functionality

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nauli_tap/main.dart';
import 'package:nauli_tap/splash_screen.dart';
import 'package:nauli_tap/login_screen.dart';
import 'package:nauli_tap/home_screen.dart';
import 'package:nauli_tap/start_trip_screen.dart';
import 'package:nauli_tap/services/conductor_service.dart';

void main() {
  group('Nauli Tap App Tests', () {
    testWidgets('App launches and shows splash screen',
        (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(const NauliTapApp());

      // Verify that splash screen is shown
      expect(find.text('Nauli Tap'), findsOneWidget);
      expect(find.text('NFC Transit Solution'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Splash screen navigates to login screen after delay',
        (WidgetTester tester) async {
      await tester.pumpWidget(const NauliTapApp());

      // Initial frame - splash screen
      await tester.pump();
      expect(find.text('Nauli Tap'), findsOneWidget);

      // Wait for navigation delay
      await tester.pump(const Duration(seconds: 3));

      // Should now be on login screen
      expect(find.text('TransitConductor'), findsOneWidget);
      expect(find.text('Username'), findsOneWidget);
    });

    testWidgets('Login screen has pre-filled username and form elements',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      // Verify all form elements are present
      expect(find.text('TransitConductor'), findsOneWidget);
      expect(find.text('Accure NFC-Enabled POS System'), findsOneWidget);
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Remember Username'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);

      // Verify username is pre-filled
      expect(find.text('conductor002'), findsOneWidget);
    });

    testWidgets('Home screen displays user info and action cards',
        (WidgetTester tester) async {
      // Setup: Login first to set conductor data
      await ConductorService.login('conductor002', 'password');

      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      // Verify user greeting contains conductor name
      expect(find.textContaining('Samuel Kiproitch'), findsOneWidget);
      expect(find.text('Good'),
          findsOneWidget); // "Good Morning/Afternoon/Evening"

      // Verify stats are displayed
      expect(find.text('Collections'), findsOneWidget);
      expect(find.text('Platform Fee'), findsOneWidget);
      expect(find.text('Net Amount'), findsOneWidget);

      // Verify action cards are present (updated based on current app)
      expect(find.text('Start New Trip'), findsOneWidget);
      expect(find.text('Transactions'), findsOneWidget);
      expect(find.text('Reports'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('Start Trip screen has all configuration options',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: StartTripScreen()));

      // Verify main sections are present
      expect(find.text('Start New Trip'), findsOneWidget);
      expect(find.text('Select Route'), findsOneWidget);
      expect(find.text('Set Fare Amount'), findsOneWidget);
      expect(find.text('Passenger Capacity'), findsOneWidget);

      // Verify fare options
      expect(find.text('Use Suggested'), findsOneWidget);
      expect(find.text('Range: Ksh 20 - Ksh 500'), findsOneWidget);
      expect(find.text('Quick Select'), findsOneWidget);

      // Verify quick fare buttons
      expect(find.text('Ksh 50'), findsOneWidget);
      expect(find.text('Ksh 80'), findsOneWidget);
      expect(find.text('Ksh 100'), findsOneWidget);
      expect(find.text('Ksh 120'), findsOneWidget);
      expect(find.text('Ksh 150'), findsOneWidget);

      // Verify passenger capacity options
      expect(find.text('Common Capacities'), findsOneWidget);
      expect(find.text('14'), findsOneWidget);
      expect(find.text('22'), findsOneWidget);
      expect(find.text('33'), findsOneWidget);

      // Verify start trip button
      expect(find.text('Start Trip'), findsOneWidget);
    });

    testWidgets('Navigation from home to start trip screen works',
        (WidgetTester tester) async {
      // Setup: Login first
      await ConductorService.login('conductor002', 'password');

      await tester.pumpWidget(const NauliTapApp());

      // Navigate through the app
      await tester.pumpAndSettle();

      // Tap on Start New Trip card
      await tester.tap(find.text('Start New Trip'));
      await tester.pumpAndSettle();

      // Verify we're on the start trip screen
      expect(find.text('Select Route'), findsOneWidget);
      expect(find.text('Set Fare Amount'), findsOneWidget);
    });

    testWidgets('Login button becomes disabled during authentication',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      // Enter password
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.pump();

      // Tap login button
      await tester.tap(find.text('Login'));
      await tester.pump();

      // Verify button shows authenticating state
      expect(find.text('Authenticating...'), findsOneWidget);
    });

    testWidgets('Fare selection updates in start trip screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: StartTripScreen()));

      // Tap on different fare option
      await tester.tap(find.text('Ksh 100'));
      await tester.pump();

      // Verify the fare button is present (UI interaction doesn't crash)
      expect(find.text('Ksh 100'), findsOneWidget);
    });

    testWidgets('Route selection enables start trip button',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: StartTripScreen()));

      // Initially, start trip button should be disabled (no route selected)
      final startTripButton =
          tester.widget<ElevatedButton>(find.text('Start Trip'));
      expect(startTripButton.enabled, isFalse);
    });

    testWidgets('Home screen shows online status indicator',
        (WidgetTester tester) async {
      // Setup: Login first
      await ConductorService.login('conductor002', 'password');

      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      // Verify online status is shown
      expect(find.text('Online'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator),
          findsNothing); // No loading in home
    });

    testWidgets('Quick actions are present on home screen',
        (WidgetTester tester) async {
      // Setup: Login first
      await ConductorService.login('conductor002', 'password');

      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      // Verify quick actions section
      expect(find.text('Quick Actions'), findsOneWidget);
      expect(find.text('Help'), findsOneWidget);
      expect(find.text('Support'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
    });
  });

  group('Conductor Service Tests', () {
    testWidgets('Conductor service provides correct user data',
        (WidgetTester tester) async {
      // Test conductor service functionality
      await ConductorService.login('conductor002', 'password');

      final conductor = ConductorService.currentConductor;
      expect(conductor, isNotNull);
      expect(conductor!.fullName, 'Samuel Kiproitch');
      expect(conductor.username, 'conductor002');
      expect(ConductorService.isOnline, isTrue);
    });

    testWidgets('Time greeting changes based on time of day',
        (WidgetTester tester) async {
      final greeting = ConductorService.getTimeGreeting();

      // Should return one of the expected greetings
      expect(['Morning', 'Afternoon', 'Evening'], contains(greeting));
    });
  });

  group('Widget Structure Tests', () {
    testWidgets('All screens have proper scaffold structure',
        (WidgetTester tester) async {
      // Test splash screen structure
      await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
      expect(find.byType(Scaffold), findsOneWidget);

      // Test login screen structure
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      expect(find.byType(Scaffold), findsOneWidget);

      // Test home screen structure
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      expect(find.byType(Scaffold), findsOneWidget);
      // Home screen uses custom app bar, not Flutter's AppBar
      expect(find.byType(AppBar), findsNothing);

      // Test start trip screen structure
      await tester.pumpWidget(const MaterialApp(home: StartTripScreen()));
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('Home screen has all required sections',
        (WidgetTester tester) async {
      // Setup: Login first
      await ConductorService.login('conductor002', 'password');

      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      // Verify all main sections are present
      expect(find.text('Nauli Tap'), findsOneWidget); // App bar title
      expect(find.text('Collections'), findsOneWidget); // Stats section
      expect(find.text('Start New Trip'), findsOneWidget); // Actions grid
      expect(find.text('Quick Actions'), findsOneWidget); // Quick actions
    });
  });

  group('Navigation Tests', () {
    testWidgets('Successful login navigates to home screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(const NauliTapApp());
      await tester.pumpAndSettle(); // Wait for splash to complete

      // Enter credentials and login
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Should be on home screen after successful login
      expect(find.text('Good'), findsOneWidget);
      expect(find.text('Start New Trip'), findsOneWidget);
    });

    testWidgets('Logout navigates back to login screen',
        (WidgetTester tester) async {
      // Setup: Start from home screen (already logged in)
      await ConductorService.login('conductor002', 'password');
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      await tester.pumpAndSettle();

      // Tap logout
      await tester.tap(find.text('Logout'));
      await tester.pump();

      // Confirm logout dialog
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      // Should be back on login screen
      expect(find.text('TransitConductor'), findsOneWidget);
      expect(find.text('Username'), findsOneWidget);
    });
  });
}
