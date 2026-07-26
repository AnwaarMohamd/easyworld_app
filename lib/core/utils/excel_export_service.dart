import 'dart:io';

import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/character/data/models/character_model.dart';

class ExcelExportService {
  static Future<String?> exportCharactersToExcel(
    List<CharacterModel> characters,
  ) async {
    try {
      if (characters.isEmpty) {
        return null;
      }

      final excel = Excel.createExcel();
      final sheet = excel['Sheet1'];

      // Set column widths
      sheet.setColumnWidth(0, 20);
      sheet.setColumnWidth(1, 15);
      sheet.setColumnWidth(2, 15);
      sheet.setColumnWidth(3, 15);
      sheet.setColumnWidth(4, 25);
      sheet.setColumnWidth(5, 25);

      // Header row
      final headers = ['Name', 'Status', 'Species', 'Gender', 'Origin', 'Location'];
      for (int i = 0; i < headers.length; i++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = TextCellValue(headers[i]);
      }

      // Data rows
      for (int rowIndex = 0; rowIndex < characters.length; rowIndex++) {
        final character = characters[rowIndex];
        final row = rowIndex + 1;

        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
            .value = TextCellValue(character.name);
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
            .value = TextCellValue(character.status);
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
            .value = TextCellValue(character.species);
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
            .value = TextCellValue(character.gender);
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row))
            .value = TextCellValue(character.origin);
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row))
            .value = TextCellValue(character.location);
      }

      // Save file
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyy_MM_dd_HH_mm_ss').format(DateTime.now());
      final fileName = 'characters_$timestamp.xlsx';
      final filePath = '${directory.path}/$fileName';

      final file = File(filePath);
      await file.writeAsBytes(excel.encode()!);

      return filePath;
    } catch (e) {
      rethrow;
    }
  }

  static Future<OpenResult> openFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await OpenFilex.open(filePath);
      }
      return OpenResult(type: ResultType.fileNotFound);
    } catch (e) {
      return OpenResult(type: ResultType.permissionDenied);
    }
  }
}
