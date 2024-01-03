import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:device_calendar/device_calendar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:developer';
import 'package:device_calendar/device_calendar.dart' as calendarapione;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:add_2_calendar/add_2_calendar.dart' as calendarapitwo;
import 'package:timezone/standalone.dart';


class CalendarUtils {
  static final calendarapione.DeviceCalendarPlugin _deviceCalendarPlugin = calendarapione.DeviceCalendarPlugin();
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> createCalendarEvent(
      String title,
      DateTime eventDate,
      String description,
      ) async {
    // Request calendar permissions
    final PermissionStatus permissionStatus = await Permission.calendarWriteOnly.request();

    if (permissionStatus != PermissionStatus.granted) {
      print('Calendar permissions are not granted.');
      return;
    }
    try {
      final calendarCreateResult = await _deviceCalendarPlugin
          .retrieveCalendars();
      if (calendarCreateResult.data!.isEmpty) {
        // Create a new calendar
        final calendarCreateResult = await _deviceCalendarPlugin.createCalendar(
            'Pet Appointments');
      }

      if (calendarCreateResult.isSuccess) {
        // Retrieve the list of calendars to find the newly created one
        final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();

        if (calendarsResult.isSuccess && calendarsResult.data!.isNotEmpty) {
          final calendars = calendarsResult.data;
          final calendarId = calendars?.first.id;
          // Convert DateTime to TZDateTime
          final location = getLocation('Europe/London'); // Replace with your time zone
          final start = TZDateTime.from(eventDate, location);
          final end = TZDateTime.from(eventDate.add(Duration(hours: 1)), location);

          final eventInfo = calendarapione.Event(
            calendarId,
            title: title,
            start: start,
            end: end,
            description: description,
          );

          final createResult = await _deviceCalendarPlugin.createOrUpdateEvent(
              eventInfo);
          if (createResult!.isSuccess) {
            print('Event created successfully');

            // Send a push notification
            _sendNotification(title, description);
          } else {
            print('Failed to create event: ${createResult.errors}');
          }
        } else {
          print('No calendars available or failed to retrieve calendars.');
        }
      } else {
        print('Failed to create calendar: ${calendarCreateResult.errors}');
      }
    } catch (e) {
      // Convert DateTime to TZDateTime
      final start = eventDate;
      final end = eventDate.add(Duration(hours: 1));

      CalendarUtils.addToCalendar(
        title,
        description,
        'UK',
        start,
        end,
      );
    }
  }

  static void _sendNotification(String title, String description) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );


    print('User granted permission: ${settings.authorizationStatus}');


    // Initialize the FlutterLocalNotificationsPlugin
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

    // Initialize Android notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // Replace with your own channel ID
      'your_channel_name', // Replace with your own channel name
      description: 'your_channel_description', // Replace with your own channel description
      importance: Importance.max,
      playSound: true,
    );


    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    var initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOs = DarwinInitializationSettings(
        notificationCategories: [
          DarwinNotificationCategory(
            'demoCategory',
            actions: <DarwinNotificationAction>[
              DarwinNotificationAction.plain('id_1', 'Action 1'),
              DarwinNotificationAction.plain(
                'id_2',
                'Action 2',
                options: <DarwinNotificationActionOption>{
                  DarwinNotificationActionOption.destructive,
                },
              ),
              DarwinNotificationAction.plain(
                'id_3',
                'Action 3',
                options: <DarwinNotificationActionOption>{
                  DarwinNotificationActionOption.foreground,
                },
              ),
            ],
            options: <DarwinNotificationCategoryOption>{
              DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
            },
          )
        ],
    );
    var initSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOs);

    void onDidReceiveNotificationResponse(NotificationResponse notificationResponse) async {
// this should print now
      print(notificationResponse.payload);
// let's add some switch statements here
      switch (notificationResponse.notificationResponseType) {
// triggers when the notification is tapped
        case NotificationResponseType.selectedNotification:
          if (notificationResponse.payload != null) {
            try {
              Map notificationPayload =
              (jsonDecode(notificationResponse.payload!));
              print(notificationResponse.payload); // prints the decoded JSON
            } catch (error) {
              log('Notification payload error $error');
            }
          }
          break;
        default:
      }
    }

    await flutterLocalNotificationsPlugin.initialize(initSettings,onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,);

    /// Create an Android Notification Channel.
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'high_importance_channel', // Replace with your own channel ID
      'your_channel_name', // Replace with your own channel name
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const DarwinNotificationDetails iosPlatformChannelSpecifics = DarwinNotificationDetails(
      categoryIdentifier: 'plainCategory',
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      'Calendar Event Created',
      platformChannelSpecifics,
      payload: 'Event created successfully',
    );

  }

  static void addToCalendar(String title, String description, String location, DateTime startDate, DateTime endDate) {
    final calendarapitwo.Event event = calendarapitwo.Event(
      title: title,
      description: description,
      location: location,
      startDate: startDate,
      endDate: endDate,
      iosParams: calendarapitwo.IOSParams(
        reminder: Duration(milliseconds: 30), // on iOS, you can set alarm notification after your event.
        url: 'www.cmpet.co.uk', // on iOS, you can set url to your event.
      ),
      androidParams: calendarapitwo.AndroidParams(
        emailInvites: [], // on Android, you can add invite emails to your event.
      ),
    );

    // Add event to the calendar
    calendarapitwo.Add2Calendar.addEvent2Cal(event).then((success) {
      if (success) {
        print('Event added to calendar successfully');
        // You can add additional logic here if needed
      } else {
        print(success);
        print('Failed to add event to calendar');
        // Handle the failure scenario
      }
    });
  }

}