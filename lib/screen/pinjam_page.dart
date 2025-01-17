//kode ke-5
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../cubit/tools_cubit.dart';

class PinjamPage extends StatefulWidget {
  @override
  _PinjamPageState createState() => _PinjamPageState();
}

class NRPData {
  final String nrp;
  final String name;

  NRPData({required this.nrp, required this.name});

  factory NRPData.fromJson(Map<String, dynamic> json) {
    return NRPData(
      nrp: json['NRP'],
      name: json['Nama'],
    );
  }
}

class _PinjamPageState extends State<PinjamPage> {
  String selectedNRP = "";
  String selectedName = "";
  List<int> selectedToolIds = [];
  DateTime now = DateTime.now();
  String toolSearchQuery = "";
  List<NRPData> nrpDataList = [];

  @override
  void initState() {
    super.initState();
    context.read<ToolsCubit>().fetchTools();
    _fetchNRPData();
  }

  Future<void> _fetchNRPData() async {
    final response =
        await http.get(Uri.parse('http://209.182.237.240:5500/api/mp'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      setState(() {
        nrpDataList = jsonData.map((data) => NRPData.fromJson(data)).toList();
      });
    } else {
      throw Exception('Failed to load NRP data');
    }
  }

  Future<void> _submitData() async {
    if (selectedNRP.isEmpty || selectedToolIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih NRP dan tool sebelum submit.'),
        ),
      );
      return;
    }

    final jsonData = {
      "nrp": selectedNRP,
      "nama": selectedName,
      "tool": selectedToolIds,
      "date": "${now.year}-${now.month}-${now.day}",
      //"date": "${now.day} ${_monthName(now.month)} ${now.year}",
      "time": "${now.hour}:${now.minute.toString().padLeft(2, '0')}"
    };

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Submit"),
        content:
            Text("Apakah Anda yakin ingin mengirim data berikut?\n\n$jsonData"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Kirim"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final response = await http.post(
          Uri.parse('http://209.182.237.240:5500/api/trx'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(jsonData),
        );

        if (response.statusCode == 201) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Berhasil"),
              content: const Text('Data berhasil disubmit!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      selectedNRP = "";
                      selectedName = "";
                      selectedToolIds.clear();
                    });
                  },
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        } else {
          _showErrorDialog('Gagal mengirim data: ${response.statusCode}');
        }
      } catch (e) {
        _showErrorDialog('Terjadi kesalahan: $e');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Kesalahan"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _clearSelections() {
    setState(() {
      selectedToolIds.clear();
    });
  }

  String _monthName(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "Mei",
      "Jun",
      "Jul",
      "Agu",
      "Sep",
      "Okt",
      "Nov",
      "Des"
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pinjam Tool'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Ketik NRP Peminjam',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        selectedNRP = value;
                        selectedName = nrpDataList
                            .firstWhere(
                              (nrpData) => nrpData.nrp == value,
                              orElse: () => NRPData(nrp: "", name: ""),
                            )
                            .name;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            if (selectedName.isNotEmpty)
              Text(
                "NRP Peminjam : $selectedNRP - $selectedName",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Ketik nama tool',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  toolSearchQuery = value.toLowerCase();
                });
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: BlocBuilder<ToolsCubit, ToolsState>(
                builder: (context, state) {
                  if (state is ToolsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ToolsLoaded) {
                    final tools = state.tools.where((tool) {
                      return tool.name.toLowerCase().contains(toolSearchQuery);
                    }).toList();

                    return ListView.builder(
                      itemCount: tools.length,
                      itemBuilder: (context, index) {
                        final tool = tools[index];
                        final isSelected = selectedToolIds.contains(tool.id);

                        return ListTile(
                          leading: CachedNetworkImage(
                            imageUrl:
                                'http://209.182.237.240:5500${tool.imageUrl}',
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                          title: Text(tool.name),
                          subtitle: Text(tool.description),
                          trailing: Checkbox(
                            value: isSelected,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  selectedToolIds.add(tool.id);
                                } else {
                                  selectedToolIds.remove(tool.id);
                                }
                              });
                            },
                          ),
                        );
                      },
                    );
                  } else if (state is ToolsError) {
                    return Center(child: Text(state.message));
                  } else {
                    return const Center(child: Text('No tools available.'));
                  }
                },
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _submitData,
                  child: const Text('Submit'),
                ),
                ElevatedButton(
                  onPressed: _clearSelections,
                  child: const Text('Clear'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
