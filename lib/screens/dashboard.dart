import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'entrateUscite.dart';

class Dashboard extends StatefulWidget {
  final Map<String, dynamic>? dipendente; // Dati del dipendente

  Dashboard(this.dipendente);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? _ssid = 'Sconosciuto';
  late Map<String, dynamic> dipendenteData;

  @override
  void initState() {
    super.initState();
    dipendenteData = widget.dipendente ??
        {'cognome': 'Utente', 'codiceFiscale': 'Nessun dato'};
    _fetchWifiInfo();
  }

  // Recupera il nome della rete Wi-Fi e gestisce i permessi
  Future<void> _fetchWifiInfo() async {
    PermissionStatus status = await Permission.locationWhenInUse.request();

    if (!status.isGranted) {
      setState(() {
        _ssid = 'Permesso non concesso';
      });
      print('Permesso posizione non concesso.');
      return;
    }

    try {
      final info = NetworkInfo();
      final wifiName = await info.getWifiName();
      setState(() {
        _ssid = wifiName ?? 'Sconosciuto';
      });
    } catch (e) {
      setState(() {
        _ssid = 'Errore nel recupero SSID';
      });
      print('Errore nel recuperare l\'SSID: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
      ),
      endDrawer: _buildDrawer(),
      body: _buildBody(),
    );
  }

  // Corpo principale della pagina
  Widget _buildBody() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'SSID attuale: $_ssid',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          _buildQRButton(),
          SizedBox(height: 20),
          _buildNavigateButton(),
        ],
      ),
    );
  }

  // Drawer laterale
  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.indigo),
            child: Text(
              'Ciao ${dipendenteData['cognome']}',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () => print('Logout tappato'),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Impostazioni'),
            onTap: () => print('Impostazioni tappato'),
          ),
        ],
      ),
    );
  }

  // Bottone per mostrare il codice QR
  Widget _buildQRButton() {
    return ElevatedButton(
      onPressed: () => _showQRCode(),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.indigo,
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      child: Text(
        'Mostra il mio codice QR',
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }

  // Mostra il dialog con il codice QR
  void _showQRCode() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Il tuo codice QR'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QrImageView(
                data: dipendenteData['codiceFiscale'] ??
                    'Nessun dato disponibile',
                version: QrVersions.auto,
                size: 200.0,
              ),
              SizedBox(height: 16),
              Text(
                'Scansiona questo codice per entrare e uscire da lavoro',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Chiudi'),
            ),
          ],
        );
      },
    );
  }

  // Bottone per navigare alla pagina Entrate/Uscite
  Widget _buildNavigateButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EntrateUscitePage(dipendenteData),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.indigo,
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      child: Text(
        'Entrate/Uscite',
        style: TextStyle(fontSize: 18, color: Colors.indigo),
      ),
    );
  }
}
