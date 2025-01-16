import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/tool.dart';

abstract class ToolsState {}

class ToolsInitial extends ToolsState {}

class ToolsLoading extends ToolsState {}

class ToolsLoaded extends ToolsState {
  final List<Tool> tools;
  ToolsLoaded(this.tools);
}

class ToolsError extends ToolsState {
  final String message;
  ToolsError(this.message);
}

class ToolsCubit extends Cubit<ToolsState> {
  ToolsCubit() : super(ToolsInitial());
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> fetchTools() async {
    emit(ToolsLoading());
    try {
      final response =
          await http.get(Uri.parse('http://209.182.237.240:5500/api/tools'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final tools = jsonData.map((tool) => Tool.fromJson(tool)).toList();
        emit(ToolsLoaded(tools));
      } else {
        emit(ToolsError(
            'Failed to load tools. Status code: ${response.statusCode}'));
      }
    } catch (e) {
      emit(ToolsError('Failed to load tools. Error: $e'));
    }
  }

  Future<File?> pickImageFromCameraOrGallery(BuildContext context) async {
    try {
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Choose Image Source'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, ImageSource.camera),
                child: const Text('Camera'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, ImageSource.gallery),
                child: const Text('Gallery'),
              ),
            ],
          );
        },
      );

      if (source != null) {
        final XFile? pickedImage = await _imagePicker.pickImage(source: source);
        if (pickedImage != null) {
          return File(pickedImage.path);
        }
      }
    } catch (e) {
      emit(ToolsError('Failed to pick image: $e'));
    }
    return null;
  }

  Future<void> addTool(String name, String description, File imageFile) async {
    try {
      final uri = Uri.parse('http://209.182.237.240:5500/api/tools');
      final request = http.MultipartRequest('POST', uri)
        ..fields['name'] = name
        ..fields['description'] = description
        ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      final response = await request.send();
      print(response.statusCode);

      if (response.statusCode == 201) {
        if (state is ToolsLoaded) {
          final currentTools = (state as ToolsLoaded).tools;
          final newToolResponse = await http.Response.fromStream(response);
          final newTool = Tool.fromJson(json.decode(newToolResponse.body));
          emit(ToolsLoaded([...currentTools, newTool]));
        } else {
          fetchTools();
        }
      } else {
        emit(ToolsError(
            'Failed to add tool. Status code: ${response.statusCode}'));
      }
    } catch (e) {
      emit(ToolsError('Failed to add tool. Error: $e'));
    }
  }

  Future<void> deleteTool(int toolId) async {
    emit(ToolsLoading());
    try {
      final response = await Dio().delete(
        'http://209.182.237.240:5500/api/tools/$toolId',
      );
      if (response.statusCode == 200) {
        await fetchTools(); // Perbarui daftar tools
        //emit(ToolsLoaded(tools));
      } else {
        emit(ToolsError('Gagal menghapus tool.'));
      }
    } catch (e) {
      emit(ToolsError('Terjadi kesalahan: $e'));
    }
  }
}
