import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';


class Dashboard extends StatefulWidget {
  final Map<String, dynamic>? dipendente; // Campo dipendente passato dal genitore.

  Dashboard(this.dipendente);

  @override
  _DashboardState createState() => _DashboardState(dipendente);
}

class _DashboardState extends State<Dashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Map<String, dynamic>? dipendente; // Campo dipendente usato nello stato.

  // Variabile che conterrà la stringa del QR Code.
  var dipendenteData;

  _DashboardState(this.dipendente);

  @override
  void initState() {
    super.initState();
    // Inizializza dipendenteData convertendo la mappa in una stringa JSON
    dipendenteData = dipendente != null ? dipendenteData = dipendente : 'Nessun dato disponibile';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Dashboard', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            color: Colors.white,
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      endDrawer: Drawer(
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
              onTap: () {
                // Implementa il logout
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Impostazioni'),
              onTap: () {
                // Implementa impostazioni
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Il tuo codice QR'),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 200.0,
                              height: 200.0,
                              child: QrImageView(
                                data: '${dipendenteData['codiceFiscale']}', // Usa la variabile dipendenteData per il QR.
                                version: QrVersions.auto,
                                size: 200.0,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Scansiona questo codice per entrare e uscire da lavoro',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Chiudi'),
                        ),
                      ],
                    );
                  },
                );
              },
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
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {



                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Bottone 2 premuto!')),
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
            ),
          ],
        ),
      ),
    );
  }
}
