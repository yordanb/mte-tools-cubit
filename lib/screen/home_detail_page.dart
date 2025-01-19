import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DetailPage extends StatefulWidget {
  final String nrp;

  const DetailPage({Key? key, required this.nrp}) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Map<String, dynamic>? detailData;
  bool isLoading = true;
  bool hasError = false;

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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (detailData!['tool_image_url'] != null)
                            Image.network(
                              'http://209.182.237.240:5500${detailData!['tool_image_url']}',
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image, size: 100),
                            ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  detailData!['tool_name'] ??
                                      'Nama tool tidak tersedia',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Crew: ${detailData!['peminjam_crew'] ?? '-'}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nama Peminjam: ${detailData!['peminjam_nama'] ?? '-'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'NRP: ${detailData!['peminjam_nrp'] ?? '-'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Status: ${detailData!['status'] ?? '-'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tanggal Pinjam: ${detailData!['borrowed_at'] != null ? DateTime.parse(detailData!['borrowed_at']).toLocal().toString() : '-'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
    );
  }
}
