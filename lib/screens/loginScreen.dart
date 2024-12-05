import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:managertimemob/db/DatabaseHelper.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _login() async {
    try {
      final user = await FirebaseDatabaseHelper.checkUtentebyEmail(_emailController.text.trim(), true);
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Utente non trovato o non registrato.')),
        );
        return;
      }
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      final userDaAggiungere = await FirebaseDatabaseHelper.getUtentebyEmail(_emailController.text.trim());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login effettuato con successo!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore di login: ${e.toString()}')),
      );
    }
  }

  Future<void> _register() async {
    try {
      // Controlla se l'utente è già registrato tramite email
      final user = await FirebaseDatabaseHelper.checkUtentebyEmail(_emailController.text.trim(), true);

      // Se l'email è già registrata, mostra un messaggio e interrompi
      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Utente già registrato.')),
        );
        return;
      }

      // Se l'email non è registrata, mostra il dialog per il codice fiscale
      if (_emailController.text.trim().isNotEmpty) {
        final codiceFiscale = await _showCodiceFiscaleDialog();
        if (codiceFiscale == null || codiceFiscale.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Codice fiscale non fornito. Registrazione annullata.')),
          );
          return;
        }

        // Recupera utente tramite codice fiscale
        final userDaAggiungere = await FirebaseDatabaseHelper.getUtentebyCodiceFiscale(codiceFiscale);
        if (userDaAggiungere == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Nessun utente trovato con il codice fiscale fornito.')),
          );
          return;
        }

        // Imposta l'email nel database
        final userId = userDaAggiungere['id'];
        await FirebaseDatabaseHelper.setEmail(userId, _emailController.text.trim());
        await FirebaseDatabaseHelper.setRegisterTrue(userId);
      }

      // Crea l'utente in Firebase Authentication
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registrazione completata!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore di registrazione: ${e.toString()}')),
      );
    }
  }

// Mostra il dialog per il codice fiscale e restituisce il valore inserito
  Future<String?> _showCodiceFiscaleDialog() async {
    final TextEditingController _codiceFiscaleController = TextEditingController();

    return await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Inserisci Codice Fiscale'),
          content: TextField(
            controller: _codiceFiscaleController,
            decoration: InputDecoration(
              labelText: 'Codice Fiscale',
              hintText: 'Inserisci il codice fiscale',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null); // Ritorna null se annullato
              },
              child: Text('Annulla', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () {
                final codiceFiscale = _codiceFiscaleController.text.trim();
                Navigator.of(context).pop(codiceFiscale); // Ritorna il valore inserito
              },
              child: Text('Conferma'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/images/logo.jpg', fit: BoxFit.contain),
        ),
        title: Center(child: Text('Accesso', style: TextStyle(color: Colors.white))),
        backgroundColor: Colors.indigo, // Azzurro per l'AppBar
      ),
      body: Container(
        color: Colors.white, // Sfondo bianco per il corpo
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Titolo
                Text(
                  'Benvenuto!',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                SizedBox(height: 40),
                // Campo di inserimento email
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.indigo),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: Colors.indigo, width: 2.0),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  ),
                ),
                SizedBox(height: 20),
                // Campo di inserimento password
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.indigo),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: Colors.indigo, width: 2.0),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  ),
                ),
                SizedBox(height: 40),
                // Pulsanti centrati e separati
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Centra i pulsanti
                  children: [
                    ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo, // Colore indigo per il pulsante
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        'Login',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                    SizedBox(width: 20), // Spazio tra i due pulsanti
                    ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, // Colore bianco per il pulsante
                        foregroundColor: Colors.indigo, // Colore del testo blu
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        'Registrati',
                        style: TextStyle(fontSize: 18, color: Colors.indigo),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
