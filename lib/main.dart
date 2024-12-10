import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:network_info_plus/network_info_plus.dart'; // Per ottenere l'SSID della rete Wi-Fi
import 'package:permission_handler/permission_handler.dart';
import 'package:managertimemob/screens/loginScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Inizializza le notifiche locali
  _initializeNotifications();

  runApp(MyApp());
}

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
NetworkInfo _networkInfo = NetworkInfo();
String? _ssid = 'Sconosciuto'; // Variabile per memorizzare il nome della rete Wi-Fi

void _initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher'); // Usa il tuo ic_launcher
  final InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid);

  flutterLocalNotificationsPlugin.initialize(initializationSettings);

  if (await Permission.notification.isDenied) {
    PermissionStatus status = await Permission.notification.request();
    if (!status.isGranted) {
      print('Permesso per le notifiche non concesso.');
    }
  }
}

// Funzione per recuperare il nome della rete Wi-Fi
Future<void> _fetchWifiInfo() async {
  // Verifica il permesso per l'accesso alla posizione
  PermissionStatus status = await Permission.locationWhenInUse.request();

  if (status.isGranted) {
    try {
      // Ottieni il nome della rete Wi-Fi
      String? wifiName = await _networkInfo.getWifiName();
      if (wifiName != null) {
        _ssid = wifiName;
        print('Sei connesso alla rete: $_ssid');

        // Controlla se sei connesso alla rete specifica "ap_made"
        if (_ssid == '"ap_made"') {
          print("mando notifica");
          _sendNotification(); // Invia la notifica se connesso alla rete "ap_made"
        }
      }
    } catch (e) {
      print('Errore nel recuperare l\'SSID: $e');
    }
  } else {
    print('Permesso per accedere alla posizione non concesso.');
  }
}

// Funzione per inviare una notifica locale
Future<void> _sendNotification() async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails(
    'your_channel_id',
    'your_channel_name',
    channelDescription: 'Channel for wifi notifications',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
  );

  const NotificationDetails platformChannelSpecifics =
  NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0,
    'WiFi Connessione',
    'Sei connesso alla rete ap_made!',
    platformChannelSpecifics,
    payload: 'wifi_ap_made',
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Inizia a monitorare la rete Wi-Fi non appena l'app viene avviata
    _fetchWifiInfo();

    return MaterialApp(
      title: 'Login Firebase',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
    );
  }
}
