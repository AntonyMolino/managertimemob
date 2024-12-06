import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirebaseDatabaseHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final CollectionReference dipendentiCollection = _firestore.collection('dipendenti');

  static Future<Map<String, dynamic>?> checkUtentebyEmail(String email , bool isRegistration) async {
    try {
      final querySnapshot = await dipendentiCollection
          .where('email', isEqualTo: email)
          .where('registrato' , isEqualTo: isRegistration)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty ? querySnapshot.docs.first.data() as Map<String, dynamic> : null;
    } catch (e) {
      print("Errore durante il recupero dell'utente tramite email: $e");
      return null;
    }
  }
  static Future<Map<String, dynamic>?> getUtentebyEmail(String email) async {
    try {
      final querySnapshot = await dipendentiCollection
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty ? querySnapshot.docs.first.data() as Map<String, dynamic> : null;
    } catch (e) {
      print("Errore durante il recupero dell'utente tramite email: $e");
      return null;
    }
  }
  static Future<Map<String, dynamic>?> getUtentebyCodiceFiscale(String codiceFiscale) async {
    try {
      final querySnapshot = await dipendentiCollection
          .where('codiceFiscale', isEqualTo: codiceFiscale)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty ? querySnapshot.docs.first.data() as Map<String, dynamic> : null;
    } catch (e) {
      print("Errore durante il recupero dell'utente tramite email: $e");
      return null;
    }
  }

  static Future<bool> setRegisterTrue(int id) async{
    try {
     await dipendentiCollection.doc(id.toString()).update({
        'registrato': true,
      });
     return true;
    }catch (e){
      print("Errore nella modifica della registrazione utente");
      return false;
    }
  }

  static Future<bool> setEmail(int id , String email) async{
    try {
      await dipendentiCollection.doc(id.toString()).update({
        'email': email,
      });
      return true;
    }catch (e){
      print("Errore nella modifica della registrazione utente");
      return false;
    }
  }
  static Future<List<Map<String, dynamic>>> getEntrate(int dipendenteId) async {
    if (dipendenteId <= 0) {
      print("ID dipendente non valido.");
      return [];
    }
    try {
      final querySnapshot = await _firestore
          .collection('Entrate')
          .where('dipendenteEntr', isEqualTo: dipendenteId)
          .orderBy('data', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => {
        'id': doc.id, // Include anche l'ID del documento
        ...doc.data(), // Include i dati
      }).toList();
    } catch (e) {
      print("Errore durante il recupero delle entrate: $e");
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getUscitaByEntrataId(int entrataId) async {
    if (entrataId <= 0) {
      print("ID entrata non valido.");
      return null;
    }
    try {
      final querySnapshot = await _firestore
          .collection('Uscite')
          .where('entrataId', isEqualTo: entrataId)
          .limit(1) // Limitiamo a una sola uscita
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return {
          'id': doc.id, // Include l'ID del documento
          ...doc.data(), // Include i dati
        };
      } else {
        print("Nessuna uscita trovata per entrataId $entrataId.");
        return null;
      }
    } catch (e) {
      print('Errore durante il recupero delle uscite: $e');
      return null;
    }
  }


  // static Future<Map<String, dynamic>?> aggiungiUtenteAuth(String email){
  //
  //
  //
  //
  // }

}