import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/DatabaseHelper.dart';

class EntrateUscitePage extends StatefulWidget {
  final Map<String, dynamic>? dipendente;

  // Constructor
  EntrateUscitePage(this.dipendente);

  @override
  _EntrateUscitePageState createState() => _EntrateUscitePageState(dipendente);
}

class _EntrateUscitePageState extends State<EntrateUscitePage> {
  final Map<String, dynamic>? dipendente; // Campo dipendente usato nello stato.

  // Variabile che conterrà la stringa del QR Code.
  var dipendenteData;

  _EntrateUscitePageState(this.dipendente);

  List<Map<String, dynamic>> _entrate = [];
  List<Map<String, dynamic>> _uscite = [];
  DateTime? _startDate; // Data inizio filtro
  DateTime? _endDate;   // Data fine filtro

  @override
  void initState() {
    dipendenteData = dipendente != null ? dipendente : 'Nessun dato disponibile';
    super.initState();
    _fetchEntrateUscite();
  }

  Future<void> _fetchEntrateUscite() async {
    // Recupera tutte le entrate per il dipendente
    List<Map<String, dynamic>> entrate = await FirebaseDatabaseHelper.getEntrate(dipendente!['id']);

    // Crea una lista vuota per le uscite
    List<Map<String, dynamic>> uscite = [];

    // Recupera le uscite per ogni entrata, se esistono
    for (var entrata in entrate) {
      var uscita = await FirebaseDatabaseHelper.getUscitaByEntrataId(entrata['id']);
      if (uscita != null) {
        uscite.add(uscita);
        print("Uscita trovata per entrata ${entrata['id']}: $uscita");
      } else {
        uscite.add({});
        print("Nessuna uscita trovata per entrata ${entrata['id']}");
      }
    }

    // Aggiorna lo stato con i dati recuperati
    setState(() {
      _entrate = entrate;
      _uscite = uscite;
    });
  }

  void _filterByDateRange(DateTime? start, DateTime? end) {
    setState(() {
      _startDate = start;
      _endDate = end;
    });
  }

  @override
  Widget build(BuildContext context) {


    List<Map<String, dynamic>> filteredEntrate = _entrate.where((entrata) {
      // Verifica che 'data' e 'ora' siano presenti
      if (entrata['data'] == null || entrata['ora'] == null) return false;

      DateTime? entrataDate;
      try {
        // Parsing della data e dell'ora
        String data = entrata['data']; // Esempio: "2024-12-01"
        String ora = entrata['ora'];   // Esempio: "14:30"
        DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm");
        entrataDate = dateFormat.parse("$data $ora");
      } catch (e) {
        print("Errore nel parsing della data/ora: $e");
        return false; // Ignora l'elemento se il parsing fallisce
      }

      // Applica i filtri di intervallo
      if (_startDate != null && entrataDate.isBefore(_startDate!)) return false;
      if (_endDate != null && entrataDate.isAfter(_endDate!)) return false;

      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: dipendente != null
            ? Text(
          'Entrate/Uscite di ${dipendente!['cognome']} ${dipendente!['nome']}',
          style: TextStyle(color: Colors.white),
        )
            : Text('Entrate/Uscite'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.date_range, color: Colors.white),
            onPressed: () async {
              DateTimeRange? selectedRange = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                initialDateRange: _startDate != null && _endDate != null
                    ? DateTimeRange(start: _startDate!, end: _endDate!)
                    : null,
              );
              if (selectedRange != null) {
                _filterByDateRange(selectedRange.start, selectedRange.end);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_startDate != null && _endDate != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Periodo: ${DateFormat('dd/MM/yyyy').format(_startDate!)} - ${DateFormat('dd/MM/yyyy').format(_endDate!)}",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredEntrate.length,
              itemBuilder: (context, index) {
                var entrata = filteredEntrate[index];
                var uscita = _uscite.isNotEmpty && index < _uscite.length
                    ? _uscite[index]
                    : null;

                return Card(
                  child: ListTile(
                    title: Text("Data: ${entrata['data']}"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Entrata: ${entrata['ora']}"),
                        if (uscita != null && uscita.isNotEmpty)
                          Text("Uscita: ${uscita['ora']}"),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

