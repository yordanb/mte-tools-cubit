//kode ke-3
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class DetailPage extends StatefulWidget {
  final String nrp;

  const DetailPage({Key? key, required this.nrp}) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Map<String, dynamic>? detailData;
  List<dynamic> tools = [];
  bool isLoading = true;
  bool hasError = false;

  // Variables for pagination
  int currentPage = 0;
  int itemsPerPage = 9; // Number of items per page
  int totalPages = 0;

  @override
  void initState() {
    super.initState();
    fetchDetailData(widget.nrp);
  }

  Future<void> fetchDetailData(String nrp) async {
    const apiUrl = 'http://209.182.237.240:5500/api/trx';

    try {
      final response = await http.get(Uri.parse('$apiUrl/$nrp'));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);

        if (responseData.isNotEmpty) {
          setState(() {
            detailData = responseData.first;
            tools = responseData;
            totalPages =
                (tools.length / itemsPerPage).ceil(); // Calculate total pages
            isLoading = false;
          });
        } else {
          setState(() {
            hasError = true;
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load detail data');
      }
    } catch (error) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
      print('Error fetching detail data: $error');
    }
  }

  String formatDate(String rawDate) {
    try {
      // Parsing tanggal dari raw data
      final DateTime parsedDate = DateTime.parse(rawDate);

      // Konversi waktu ke WITA (GMT+8)
      final DateTime witaDate = parsedDate.add(const Duration(hours: 8));

      // Format tanggal menjadi '19 Jan 2025'
      final String formattedDate = DateFormat('dd MMM yyyy').format(witaDate);

      // Format waktu menjadi '08:25'
      final String formattedTime = DateFormat('HH:mm').format(witaDate);

      // Menggabungkan tanggal dan waktu dengan format "19 Jan 2025 - 08:25 WITA"
      return '$formattedDate - $formattedTime WITA';
    } catch (e) {
      print('Error formatting date: $e');
      return '-';
    }
  }

  // Get subset of tools for current page
  List<dynamic> getPaginatedTools() {
    final startIndex = currentPage * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;
    return tools.sublist(
      startIndex,
      endIndex > tools.length ? tools.length : endIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Peminjaman'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError || detailData == null
              ? const Center(
                  child: Text(
                    'Gagal memuat data.',
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${detailData!['peminjam_nama'] ?? '-'}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '(${detailData!['peminjam_nrp'] ?? '-'}) - ${detailData!['peminjam_crew'] ?? '-'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pinjam : ${formatDate(detailData!['borrowed_at'])}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'List tool yang dipinjam:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, // 3 kolom per baris
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            childAspectRatio: 1,
                          ),
                          itemCount: getPaginatedTools().length,
                          itemBuilder: (context, index) {
                            final tool = getPaginatedTools()[index];
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: tool['tool_image_url'] != null
                                  ? Image.network(
                                      'http://209.182.237.240:5500${tool['tool_image_url']}',
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                        Icons.broken_image,
                                        size: 50,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.broken_image,
                                      size: 50,
                                    ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (tools.length > itemsPerPage)
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
                      const SizedBox(height: 16),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Tool Kembali'),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
