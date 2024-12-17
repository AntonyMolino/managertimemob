import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:network_info_plus/network_info_plus.dart'; // Per ottenere l'SSID della rete Wi-Fi
import 'package:permission_handler/permission_handler.dart'; // Per richiedere i permessi di posizione
import 'package:managertimemob/screens/loginScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Inizializza notifiche locali
  await _initializeNotifications();

  // Avvia l'app
  runApp(MyApp());
}

// Plugin per notifiche locali
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

// Funzione per inizializzare notifiche locali
Future<void> _initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

// Funzione per mostrare notifiche locali
Future<void> _showNotification(String title, String body) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails(
    'channel_id',
    'channel_name',
    channelDescription: 'Channel for notifications',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: true,
  );

  const NotificationDetails platformChannelSpecifics =
  NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    platformChannelSpecifics,
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Messaging Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MessagingHome(),
    );
  }
}

class MessagingHome extends StatefulWidget {
  @override
  _MessagingHomeState createState() => _MessagingHomeState();
}

class _MessagingHomeState extends State<MessagingHome> {
  String? _token;
  String? _ssid = 'Sconosciuto'; // Variabile per memorizzare il nome della rete Wi-Fi

  @override
  void initState() {
    super.initState();
    _initializeFirebaseMessaging();
    _fetchWifiInfo();
  }

  // Funzione per inizializzare Firebase Messaging
  Future<void> _initializeFirebaseMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Richiedi permessi per iOS
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Permesso notifiche concesso!');
    } else {
      print('Permesso notifiche negato!');
    }

    // Ottieni il token FCM
    String? token = await messaging.getToken();
    setState(() {
      _token = token;
    });
    print("FCM Token: $token");

    // Ascolta messaggi in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Messaggio in foreground: ${message.notification?.title}');
      _showNotification(
          message.notification?.title ?? "Titolo non disponibile",
          message.notification?.body ?? "Messaggio non disponibile");
    });

    // Ascolta quando si apre un messaggio
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Messaggio aperto: ${message.notification?.body}');
    });
  }

  // Funzione per recuperare il nome della rete Wi-Fi
  Future<void> _fetchWifiInfo() async {
    // Richiedi permessi di accesso alla posizione
    PermissionStatus status = await Permission.locationWhenInUse.request();

    if (status.isGranted) {
      try {
        final networkInfo = NetworkInfo();
        String? wifiName = await networkInfo.getWifiName();

        if (wifiName != null) {
          setState(() {
            _ssid = wifiName;
          });
          print('Sei connesso alla rete: $_ssid');

          // Controlla se sei connesso alla rete specifica "ap_made"
          if (_ssid == '"ap_made"') {
            print("Connesso alla rete ap_made: invio notifica.");
            _sendWifiNotification();
          }
        }
      } catch (e) {
        print('Errore nel recuperare l\'SSID: $e');
      }
    } else {
      print('Permesso per accedere alla posizione non concesso.');
    }
  }

  // Funzione per inviare una notifica quando connesso alla rete "ap_made"
  Future<void> _sendWifiNotification() async {
    await _showNotification(
      'Connessione Wi-Fi',
      'Sei connesso alla rete ap_made!',
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Login Screen",
      theme: ThemeData(
        primaryColor: Colors.blue,
      ),
      home: LoginScreen(),
    );
  }
}
