import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../cubit/tools_cubit.dart';
import '../models/tool.dart';

class ToolsPage extends StatefulWidget {
  @override
  _ToolsPageState createState() => _ToolsPageState();
}

class _ToolsPageState extends State<ToolsPage> {
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _initializeStorage();
    context.read<ToolsCubit>().fetchTools();
  }

  Future<void> _initializeStorage() async {
    setState(() {});
  }

  Future<bool?> _confirmDelete(BuildContext context, Tool tool) async {
    final cubit = context.read<ToolsCubit>();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Tool'),
          content: Text('Apakah Anda yakin ingin menghapus ${tool.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                cubit.deleteTool(tool.id);
                Navigator.pop(context);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
    return null;
  }

  Future<void> _showAddToolDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final cubit = context.read<ToolsCubit>();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Tool'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Tool Name'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () async {
                    final image =
                        await cubit.pickImageFromCameraOrGallery(context);
                    if (image != null) {
                      setState(() {
                        _selectedImage = image;
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No image selected.')),
                      );
                    }
                  },
                  icon: const Icon(Icons.image),
                  label: const Text('Select Image'),
                ),
                if (_selectedImage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        _selectedImage!,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final description = descriptionController.text.trim();
                if (name.isNotEmpty &&
                    description.isNotEmpty &&
                    _selectedImage != null) {
                  await cubit.addTool(name, description, _selectedImage!);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Please fill all fields and select an image'),
                    ),
                  );
                }
              },
              child: const Text('Add'),
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
        title: const Text('Tools List'),
      ),
      body: BlocBuilder<ToolsCubit, ToolsState>(
        builder: (context, state) {
          if (state is ToolsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ToolsLoaded) {
            final tools = state.tools;
            return GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.8,
              ),
              itemCount: tools.length,
              itemBuilder: (context, index) {
                final tool = tools[index];
                return GestureDetector(
                  onLongPress: () => _confirmDelete(context, tool),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16)),
                            child: tool.imageUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl:
                                        'http://209.182.237.240:5500${tool.imageUrl}',
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        const CircularProgressIndicator(),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.broken_image),
                                  )
                                : const Icon(
                                    Icons.broken_image,
                                    size: 50,
                                  ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Kolom kiri: Nama dan deskripsi tool
                              Expanded(
                                flex: 3, // Mengatur proporsi kolom
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tool.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      tool.description,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                              // Kolom kanan: Indeks tool

                              Expanded(
                                flex: 1, // Mengatur proporsi kolom
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Column(
                                    mainAxisSize: MainAxisSize
                                        .min, // Mengatur ukuran column sesuai isi
                                    children: [
                                      // Lingkaran indikator
                                      Container(
                                        width: 16, // Sesuai dengan ukuran font
                                        height: 16,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: tool.ready == "True"
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                      const SizedBox(
                                          height:
                                              4), // Jarak antara lingkaran dan teks
                                      // Teks indeks
                                      Text(
                                        '#${index + 1}', // Menampilkan indeks (dimulai dari 1)
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddToolDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
