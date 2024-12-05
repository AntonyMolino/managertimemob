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


  // static Future<Map<String, dynamic>?> aggiungiUtenteAuth(String email){
  //
  //
  //
  //
  // }

}