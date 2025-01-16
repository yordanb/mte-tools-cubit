/*
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Untuk formatting tanggal

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final int toolsBorrowed = 5;
  final int openBorrowers = 3;

  final List<Map<String, String>> toolData = [
    {
      "no": "1",
      "peminjam": "Budi",
      "nrp": "61122292",
      "jumlahTool": "7",
      "namaTool": "Dompet, Meja, Kursi, Sarung, Panci, Sajadah, Tangga",
      "durasi": "2 hari",
      "tanggalPinjam": "08 Jan 2025"
    },
    {
      "no": "2",
      "peminjam": "Agus",
      "nrp": "61122292",
      "jumlahTool": "5",
      "namaTool": "Topi, Sarung, Panci",
      "durasi": "3 hari",
      "tanggalPinjam": "07 Jan 2025"
    },
  ];

  String get lastUpdate {
    final DateTime now = DateTime.now();
    return DateFormat('dd MMM yyyy - HH:mm WITA').format(now);
  }

  int currentPage = 0;
  final int itemsPerPage = 7;

  @override
  Widget build(BuildContext context) {
    final int totalPages = (toolData.length / itemsPerPage).ceil();
    final List<Map<String, String>> currentData =
        toolData.skip(currentPage * itemsPerPage).take(itemsPerPage).toList();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Dashboard Tool MTE'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDashboardCard(
                  color: Colors.amber,
                  label: "Tool Dipinjam",
                  value: toolsBorrowed.toString(),
                ),
                _buildDashboardCard(
                  color: Colors.blue,
                  label: "Peminjam Open",
                  value: openBorrowers.toString(),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  columns: const [
                    DataColumn(
                        label: Text("No",
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text("Peminjam - Tool",
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text("Durasi",
                            style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: currentData.map((data) {
                    return DataRow(
                      cells: [
                        DataCell(
                          InkWell(
                            onTap: () {
                              _showStatusForm(
                                context,
                                data["peminjam"]!,
                                data["nrp"]!,
                                data["jumlahTool"]!,
                                data["namaTool"]!,
                                data["tanggalPinjam"]!,
                              );
                            },
                            child: Text(data["no"]!),
                          ),
                        ),
                        DataCell(
                          InkWell(
                            onTap: () {
                              _showDetailsDialog(
                                context,
                                data["peminjam"]!,
                                data["nrp"]!,
                                data["jumlahTool"]!,
                                data["namaTool"]!,
                                data["tanggalPinjam"]!,
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${data["peminjam"]} - ${data["nrp"]}"),
                                Text("${data["jumlahTool"]} tool"),
                              ],
                            ),
                          ),
                        ),
                        DataCell(Text(data["durasi"]!)),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (toolData.length > itemsPerPage)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: currentPage > 0
                        ? () {
                            setState(() {
                              currentPage--;
                            });
                          }
                        : null,
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Text("Halaman ${currentPage + 1} / $totalPages"),
                  IconButton(
                    onPressed: currentPage < totalPages - 1
                        ? () {
                            setState(() {
                              currentPage++;
                            });
                          }
                        : null,
                    icon: const Icon(Icons.arrow_forward),
                  ),
                ],
              ),
            Center(
              child: Text(
                "Last Data Update : $lastUpdate",
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required Color color,
    required String label,
    required String value,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Container(
        width: 150,
        height: 150,
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailsDialog(BuildContext context, String peminjam, String nrp,
      String jumlahTool, String namaTool, String tanggalPinjam) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Detail Peminjam"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Nama Peminjam: $peminjam"),
                Text("NRP: $nrp"),
                Text("Jumlah Tool: $jumlahTool"),
                Text("Nama Tool: $namaTool"),
                Text("Tanggal Pinjam: $tanggalPinjam"),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Tutup"),
            ),
          ],
        );
      },
    );
  }

  void _showStatusForm(BuildContext context, String peminjam, String nrp,
      String jumlahTool, String namaTool, String tanggalPinjam) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Detail Peminjam"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Nama Peminjam: $peminjam"),
                Text("NRP: $nrp"),
                Text("Jumlah Tool: $jumlahTool"),
                Text("Nama Tool: $namaTool"),
                Text("Tanggal Pinjam: $tanggalPinjam"),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Tutup"),
            ),
          ],
        );
      },
    );
  }
}
*/

//kode ke-2
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<void> fetchDataFuture;
  List<Map<String, dynamic>> toolData = [];
  int toolsBorrowed = 0;
  int openBorrowers = 0;

  String get lastUpdate {
    final DateTime now = DateTime.now();
    return DateFormat('dd MMM yyyy - HH:mm WITA').format(now);
  }

  int currentPage = 0;
  final int itemsPerPage = 7;

  @override
  void initState() {
    super.initState();
    fetchDataFuture = fetchData();
  }

  Future<void> fetchData() async {
    const apiUrl = 'http://209.182.237.240:5500/api/trx';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);

        List<Map<String, dynamic>> filteredData = responseData
            .where((data) => data['status'] == 'borrowed')
            .map((data) {
          final DateTime borrowedAt =
              DateTime.parse(data['borrowed_at'] as String);
          final int durationDays = DateTime.now().difference(borrowedAt).inDays;

          return {
            "no": toolData.length + 1,
            "peminjam": data['peminjam_nama'],
            "nrp": data['peminjam_nrp'],
            "jumlahTool": data['tool_qty'],
            "namaTool": data['tool_id'],
            "durasi": "$durationDays hari",
            "tanggalPinjam": DateFormat('dd MMM yyyy').format(borrowedAt),
          };
        }).toList();

        setState(() {
          toolData = filteredData;
          toolsBorrowed = filteredData.fold(
              0, (sum, item) => sum + (item['jumlahTool'] as int));
          openBorrowers = filteredData.length;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print("Error fetching data: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    final int totalPages = (toolData.length / itemsPerPage).ceil();
    final List<Map<String, dynamic>> currentData =
        toolData.skip(currentPage * itemsPerPage).take(itemsPerPage).toList();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Dashboard Tool MTE'),
      ),
      body: FutureBuilder<void>(
        future: fetchDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildDashboardCard(
                      color: Colors.amber,
                      label: "Tool Dipinjam",
                      value: toolsBorrowed.toString(),
                    ),
                    _buildDashboardCard(
                      color: Colors.blue,
                      label: "Peminjam Open",
                      value: openBorrowers.toString(),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      columns: const [
                        DataColumn(
                            label: Text("No",
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text("Peminjam - Tool",
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text("Durasi",
                                style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: currentData.map((data) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(data["no"].toString()),
                            ),
                            DataCell(
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("${data["peminjam"]} - ${data["nrp"]}"),
                                  Text("${data["jumlahTool"]} tool"),
                                ],
                              ),
                            ),
                            DataCell(Text(data["durasi"])),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (toolData.length > itemsPerPage)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: currentPage > 0
                            ? () {
                                setState(() {
                                  currentPage--;
                                });
                              }
                            : null,
                        icon: const Icon(Icons.arrow_back),
                      ),
                      Text("Halaman ${currentPage + 1} / $totalPages"),
                      IconButton(
                        onPressed: currentPage < totalPages - 1
                            ? () {
                                setState(() {
                                  currentPage++;
                                });
                              }
                            : null,
                        icon: const Icon(Icons.arrow_forward),
                      ),
                    ],
                  ),
                Center(
                  child: Text(
                    "Last Data Update : $lastUpdate",
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDashboardCard({
    required Color color,
    required String label,
    required String value,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Container(
        width: 150,
        height: 150,
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
