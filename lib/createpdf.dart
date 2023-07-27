import 'dart:typed_data';

import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

//Local imports
import 'mobile.dart';

Future<void> generatePDF({
  required String consumerName,
  required String employeeName,
  required Map<String, TimeOfDay> startTimeWeek1,
  required Map<String, TimeOfDay> endTimeWeek1,
  required Map<String, int> tasksWeek1,
  required Map<String, String> tasksCompletedWeek1,
  required Map<String, TimeOfDay> startTimeWeek2,
  required Map<String, TimeOfDay> endTimeWeek2,
  required Map<String, int> tasksWeek2,
  required Map<String, String> tasksCompletedWeek2,
  required DateTime consumerSignatureDate,
  required DateTime employeeSignatureDate,
  required ByteData consumerSignimg,
  required ByteData employeeSignimg,
}) async {
  int totalHoursOfWeek1 = 0;
  int totalHoursOfWeek2 = 0;
  tasksWeek1.forEach((key, value) {
    totalHoursOfWeek1 += value;
  });

  tasksWeek2.forEach((key, value) {
    totalHoursOfWeek2 += value;
  });

  //Create a PDF document.
  final PdfDocument document = PdfDocument();
  //Add page to the PDF
  final PdfPage page = document.pages.add();
  document.pageSettings.margins.all = 0;
  //Get page client size
  final Size pageSize = page.getClientSize();
  //Draw rectangle
  page.graphics.drawRectangle(
      bounds: Rect.fromLTWH(0, 0, pageSize.width, pageSize.height),
      pen: PdfPen(PdfColor(142, 170, 219)));
  //Generate PDF grid.
  final PdfGrid grid1 = getGrid1(
      endTimeWeek1: endTimeWeek1,
      endTimeWeek2: endTimeWeek2,
      startTimeWeek1: startTimeWeek1,
      startTimeWeek2: startTimeWeek2,
      tasksCompletedWeek1: tasksCompletedWeek1,
      tasksCompletedWeek2: tasksCompletedWeek2,
      tasksWeek1: tasksWeek1,
      tasksWeek2: tasksWeek2);
  final PdfGrid grid2 = getGrid2(
      endTimeWeek1: endTimeWeek1,
      endTimeWeek2: endTimeWeek2,
      startTimeWeek1: startTimeWeek1,
      startTimeWeek2: startTimeWeek2,
      tasksCompletedWeek1: tasksCompletedWeek1,
      tasksCompletedWeek2: tasksCompletedWeek2,
      tasksWeek1: tasksWeek1,
      tasksWeek2: tasksWeek2);
  //Draw the header section by creating text element
  final PdfLayoutResult result = drawHeader(page, pageSize, grid1,
      consumerName: consumerName, employeeName: employeeName);
  //Draw grid

  grid1.draw(
      page: page, bounds: Rect.fromLTWH(0, result.bounds.top + 40, 0, 0));
  grid2.draw(
    page: page,
    bounds: Rect.fromLTWH(0, result.bounds.bottom + 250, 0, 0),
  )!;

  page.graphics.drawString('TOTAL HOURS OF WEEK 1: ',
      PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.bold),
      bounds: Rect.fromLTWH(100, result.bounds.bottom + 220, 0, 0));
  page.graphics.drawString(
      totalHoursOfWeek1.toString(),
      // getTotalAmount(grid).toString(),
      PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.bold),
      bounds: Rect.fromLTWH(250, result.bounds.bottom + 220, 0, 0));
  page.graphics.drawString('TOTAL HOURS OF WEEK 2: ',
      PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.bold),
      bounds: Rect.fromLTWH(100, result.bounds.bottom + 450, 0, 0));
  page.graphics.drawString(
      totalHoursOfWeek2.toString(),
      // getTotalAmount(grid).toString(),
      PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.bold),
      bounds: Rect.fromLTWH(250, result.bounds.bottom + 450, 0, 0));
  page.graphics.drawString('TOTAL HOURS OF 2 WEEKS: ',
      PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.bold),
      bounds: Rect.fromLTWH(100, result.bounds.bottom + 470, 0, 0));
  page.graphics.drawString(
      (totalHoursOfWeek1 + totalHoursOfWeek2).toString(),
      // getTotalAmount(grid).toString(),
      PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.bold),
      bounds: Rect.fromLTWH(250, result.bounds.bottom + 470, 0, 0));

  //Add invoice footer
  drawFooter(page, pageSize,
      consumerSignatureDate: consumerSignatureDate,
      consumerSignimg: consumerSignimg,
      employeeSignatureDate: employeeSignatureDate,
      employeeSignimg: employeeSignimg);
  //Save the PDF document
  final List<int> bytes = document.saveSync();
  //Dispose the document.
  document.dispose();
  //Save and launch the file.
  await saveAndLaunchFile(bytes, 'Home Care Form.pdf');
}

// Draws the invoice header
PdfLayoutResult drawHeader(
  PdfPage page,
  Size pageSize,
  PdfGrid grid, {
  required String consumerName,
  required String employeeName,
}) {
  // Draw rectangle
  page.graphics.drawRectangle(
    brush: PdfSolidBrush(PdfColor(91, 126, 215)),
    bounds: Rect.fromLTWH(0, 0, pageSize.width, 50),
  );
  // Draw string
  page.graphics.drawString(
    'Prestige Home Care, LLC',
    PdfStandardFont(PdfFontFamily.helvetica, 30),
    brush: PdfBrushes.white,
    bounds: Rect.fromLTWH(30, 0, pageSize.width - 115, 50),
    format: PdfStringFormat(lineAlignment: PdfVerticalAlignment.middle),
  );

  final PdfFont contentFont = PdfStandardFont(PdfFontFamily.helvetica, 9);

  String address =
      '''Consumer Name: $consumerName\n\nEmployee Name:  $employeeName''';

  return PdfTextElement(text: address, font: contentFont).draw(
    page: page,
    bounds: Rect.fromLTWH(
      30,
      60,
      pageSize.width - 115,
      80,
    ),
  )!;
}

//Draw the invoice footer data.
void drawFooter(
  PdfPage page,
  Size pageSize, {
  required DateTime consumerSignatureDate,
  required DateTime employeeSignatureDate,
  required ByteData consumerSignimg,
  required ByteData employeeSignimg,
}) {
  final PdfPen linePen =
      PdfPen(PdfColor(142, 170, 219), dashStyle: PdfDashStyle.custom);
  linePen.dashPattern = <double>[3, 3];
  //Draw line
  page.graphics.drawLine(linePen, Offset(0, pageSize.height - 120),
      Offset(pageSize.width, pageSize.height - 120));

  const String footerContent = '''
CODE:    TASK:
  A          Bed & Chair Bathing/Grooming/Shampooing/Oral Care
  B          Dressing/Undressing
  C          Toiletting/Bathroom/Urinal
  D          Laundry
  E          Mobility/Exercise/Transfers/Walking Assistance/Wheelchair & Walker
  F          Meal Prep/Assist with eating & drinking
  G          Shopping
  H          Light Housekeeping
  I          Respite-Personal Care
  J          Respite-Walk & Exercise
''';
  //Added 30 as a margin for the layout
  String consumerSignature = 'Consumer Signature:';
  String consumerSignatureDDate =
      'Date: ${DateFormat('d MMM, y').format(consumerSignatureDate)}';
  String employeeSignature = 'Employee Signature:';
  String employeeSignatureDDate =
      'Date: ${DateFormat('d MMM, y').format(employeeSignatureDate)}';

  //Create a new PDF document
  // PdfDocument document = PdfDocument();

//Adds a page to the document

//Draw the image

  final Uint8List consumerSignatureBytes = consumerSignimg.buffer.asUint8List();
  final Uint8List employeeSignatureBytes = employeeSignimg.buffer.asUint8List();

  page.graphics.drawString(
      consumerSignature, PdfStandardFont(PdfFontFamily.helvetica, 9),
      format: PdfStringFormat(alignment: PdfTextAlignment.left),
      bounds: Rect.fromLTWH(30, pageSize.height - 110, 0, 0));

  page.graphics.drawImage(PdfBitmap(consumerSignatureBytes),
      Rect.fromLTWH(30, pageSize.height - 100, 60, 30));

  page.graphics.drawString(
      consumerSignatureDDate, PdfStandardFont(PdfFontFamily.helvetica, 9),
      format: PdfStringFormat(alignment: PdfTextAlignment.left),
      bounds: Rect.fromLTWH(30, pageSize.height - 70, 0, 0));

  page.graphics.drawString(
      employeeSignature, PdfStandardFont(PdfFontFamily.helvetica, 9),
      format: PdfStringFormat(alignment: PdfTextAlignment.left),
      bounds: Rect.fromLTWH(30, pageSize.height - 60, 0, 0));

  page.graphics.drawImage(PdfBitmap(employeeSignatureBytes),
      Rect.fromLTWH(30, pageSize.height - 40, 40, 30));

  page.graphics.drawString(
      employeeSignatureDDate, PdfStandardFont(PdfFontFamily.helvetica, 9),
      format: PdfStringFormat(alignment: PdfTextAlignment.left),
      bounds: Rect.fromLTWH(30, pageSize.height - 10, 0, 0));

  page.graphics.drawString(
      footerContent, PdfStandardFont(PdfFontFamily.helvetica, 7),
      format: PdfStringFormat(alignment: PdfTextAlignment.left),
      bounds: Rect.fromLTWH(pageSize.width * 0.4, pageSize.height - 110,
          pageSize.width * 0.6, 0));
}

//Create PDF grid and return
PdfGrid getGrid1({
  required Map<String, TimeOfDay> startTimeWeek1,
  required Map<String, TimeOfDay> endTimeWeek1,
  required Map<String, int> tasksWeek1,
  required Map<String, String> tasksCompletedWeek1,
  required Map<String, TimeOfDay> startTimeWeek2,
  required Map<String, TimeOfDay> endTimeWeek2,
  required Map<String, int> tasksWeek2,
  required Map<String, String> tasksCompletedWeek2,
}) {
  String formatTimeOfDay(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final time = DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    final format = DateFormat('hh:mm a');
    return format.format(time);
  }

  //Create a PDF grid
  final PdfGrid grid = PdfGrid();
  //Secify the columns count to the grid.
  grid.columns.add(count: 5);
  //Create the header row of the grid.
  final PdfGridRow headerRow = grid.headers.add(1)[0];
  //Set style
  headerRow.style.backgroundBrush = PdfSolidBrush(PdfColor(68, 114, 196));
  headerRow.style.textBrush = PdfBrushes.white;
  headerRow.cells[0].value = '                 Date';
  headerRow.cells[1].value = 'Start Time';
  headerRow.cells[2].value = 'End Time';
  headerRow.cells[3].value = 'Total Hours';
  headerRow.cells[4].value = 'Tasks Completed (Use Codes Below)';
  //Add rows
  addProducts(
      'SUNDAY',
      formatTimeOfDay(startTimeWeek1['Sunday'] ?? TimeOfDay.now()),
      formatTimeOfDay(endTimeWeek1['Sunday'] ?? TimeOfDay.now()),
      '${tasksWeek1['Sunday']}',
      '${tasksCompletedWeek1['Sunday']}',
      grid);
  addProducts(
      'MONDAY',
      formatTimeOfDay(startTimeWeek1['Monday'] ?? TimeOfDay.now()),
      formatTimeOfDay(endTimeWeek1['Monday'] ?? TimeOfDay.now()),
      '${tasksWeek1['Monday']}',
      '${tasksCompletedWeek1['Monday']}',
      grid);
  addProducts(
      'TUESDAY',
      formatTimeOfDay(startTimeWeek1['Tuesday'] ?? TimeOfDay.now()),
      formatTimeOfDay(endTimeWeek1['Tuesday'] ?? TimeOfDay.now()),
      '${tasksWeek1['Tuesday']}',
      '${tasksCompletedWeek1['Tuesday']}',
      grid);
  addProducts(
      'WEDNESDAY',
      formatTimeOfDay(startTimeWeek1['Wednesday'] ?? TimeOfDay.now()),
      formatTimeOfDay(endTimeWeek1['Wednesday'] ?? TimeOfDay.now()),
      '${tasksWeek1['Wednesday']}',
      '${tasksCompletedWeek1['Wednesday']}',
      grid);
  addProducts(
      'THURSDAY',
      formatTimeOfDay(startTimeWeek1['Thursday'] ?? TimeOfDay.now()),
      formatTimeOfDay(endTimeWeek1['Thursday'] ?? TimeOfDay.now()),
      '${tasksWeek1['Thursday']}',
      '${tasksCompletedWeek1['Thursday']}',
      grid);
  addProducts(
      'FRIDAY',
      formatTimeOfDay(startTimeWeek1['Friday'] ?? TimeOfDay.now()),
      formatTimeOfDay(endTimeWeek1['Friday'] ?? TimeOfDay.now()),
      '${tasksWeek1['Friday']}',
      '${tasksCompletedWeek1['Friday']}',
      grid);
  addProducts(
      'SATURDAY',
      formatTimeOfDay(startTimeWeek1['Saturday'] ?? TimeOfDay.now()),
      formatTimeOfDay(endTimeWeek1['Saturday'] ?? TimeOfDay.now()),
      '${tasksWeek1['Saturday']}',
      '${tasksCompletedWeek1['Saturday']}',
      grid);

  //Apply the table built-in style
  grid.applyBuiltInStyle(PdfGridBuiltInStyle.listTable4Accent5);
  //Set gird columns width
  for (int i = 0; i < headerRow.cells.count; i++) {
    headerRow.cells[i].style.cellPadding =
        PdfPaddings(bottom: 5, left: 5, right: 5, top: 5);
  }
  for (int i = 0; i < grid.rows.count; i++) {
    final PdfGridRow row = grid.rows[i];
    for (int j = 0; j < row.cells.count; j++) {
      final PdfGridCell cell = row.cells[j];
      if (j == 0) {
        cell.stringFormat.alignment = PdfTextAlignment.center;
      }
      cell.style.cellPadding =
          PdfPaddings(bottom: 5, left: 5, right: 5, top: 5);
    }
  }
  return grid;
}

//Create PDF grid and return
PdfGrid getGrid2({
  required Map<String, TimeOfDay> startTimeWeek1,
  required Map<String, TimeOfDay> endTimeWeek1,
  required Map<String, int> tasksWeek1,
  required Map<String, String> tasksCompletedWeek1,
  required Map<String, TimeOfDay> startTimeWeek2,
  required Map<String, TimeOfDay> endTimeWeek2,
  required Map<String, int> tasksWeek2,
  required Map<String, String> tasksCompletedWeek2,
}) {
  String formatTimeOfDay(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final time = DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    final format = DateFormat('hh:mm a');
    return format.format(time);
  }

  //Create a PDF grid
  final PdfGrid grid = PdfGrid();
  //Secify the columns count to the grid.
  grid.columns.add(count: 5);
  //Create the header row of the grid.
  final PdfGridRow headerRow = grid.headers.add(1)[0];
  //Set style
  headerRow.style.backgroundBrush = PdfSolidBrush(PdfColor(68, 114, 196));
  headerRow.style.textBrush = PdfBrushes.white;
  headerRow.cells[0].value = '                 Date';
  headerRow.cells[1].value = 'Start Time';
  headerRow.cells[2].value = 'End Time';
  headerRow.cells[3].value = 'Total Hours';
  headerRow.cells[4].value = 'Tasks Completed (Use Codes Below)';
  //Add rows
  addProducts(
      'SUNDAY',
      formatTimeOfDay(startTimeWeek2['Sunday'] ?? TimeOfDay.now()),
      formatTimeOfDay(endTimeWeek2['Sunday'] ?? TimeOfDay.now()),
      '${tasksWeek2['Sunday']}',
      '${tasksCompletedWeek2['Sunday']}',
      grid);
  addProducts(
      'MONDAY',
      formatTimeOfDay(startTimeWeek2['Monday'] ?? TimeOfDay.now()),
      formatTimeOfDay(endTimeWeek2['Monday'] ?? TimeOfDay.now()),
      '${tasksWeek2['Monday']}',
      '${tasksCompletedWeek2['Monday']}',
      grid);
  addProducts(
      'TUESDAY',
      formatTimeOfDay(startTimeWeek2['Tuesday'] ?? TimeOfDay.now()),
      formatTimeOfDay(endTimeWeek2['Tuesday'] ?? TimeOfDay.now()),
      '${tasksWeek2['Tuesday']}',
      '${tasksCompletedWeek2['Tuesday']}',
      grid);
  addProducts(
      'WEDNESDAY',
      formatTimeOfDay(startTimeWeek2['Wednesday'] ?? TimeOfDay.now()),
      formatTimeOfDay(endTimeWeek2['Wednesday'] ?? TimeOfDay.now()),
      '${tasksWeek2['Wednesday']}',
      '${tasksCompletedWeek2['Wednesday']}',
      grid);
  addProducts(
      'THURSDAY',
      formatTimeOfDay(startTimeWeek2['Thursday'] ?? TimeOfDay.now()),
      formatTimeOfDay(endTimeWeek2['Thursday'] ?? TimeOfDay.now()),
      '${tasksWeek2['Thursday']}',
      '${tasksCompletedWeek2['Thursday']}',
      grid);
  addProducts(
      'FRIDAY',
      formatTimeOfDay(startTimeWeek2['Friday'] ?? TimeOfDay.now()),
      formatTimeOfDay(endTimeWeek2['Friday'] ?? TimeOfDay.now()),
      '${tasksWeek2['Friday']}',
      '${tasksCompletedWeek2['Friday']}',
      grid);
  addProducts(
      'SATURDAY',
      formatTimeOfDay(startTimeWeek2['Saturday'] ?? TimeOfDay.now()),
      formatTimeOfDay(endTimeWeek2['Saturday'] ?? TimeOfDay.now()),
      '${tasksWeek2['Saturday']}',
      '${tasksCompletedWeek2['Saturday']}',
      grid);

  //Apply the table built-in style
  grid.applyBuiltInStyle(PdfGridBuiltInStyle.listTable4Accent5);
  //Set gird columns width
  for (int i = 0; i < headerRow.cells.count; i++) {
    headerRow.cells[i].style.cellPadding =
        PdfPaddings(bottom: 5, left: 5, right: 5, top: 5);
  }
  for (int i = 0; i < grid.rows.count; i++) {
    final PdfGridRow row = grid.rows[i];
    for (int j = 0; j < row.cells.count; j++) {
      final PdfGridCell cell = row.cells[j];
      if (j == 0) {
        cell.stringFormat.alignment = PdfTextAlignment.center;
      }
      cell.style.cellPadding =
          PdfPaddings(bottom: 5, left: 5, right: 5, top: 5);
    }
  }
  return grid;
}

//Create and row for the grid.
void addProducts(String productId, String productName, String price,
    String quantity, String total, PdfGrid grid) {
  final PdfGridRow row = grid.rows.add();
  row.cells[0].value = productId;
  row.cells[1].value = productName;
  row.cells[2].value = price.toString();
  row.cells[3].value = quantity.toString();
  row.cells[4].value = total.toString();
}

//Get the total amount.
double getTotalAmount(PdfGrid grid) {
  double total = 0;
  for (int i = 0; i < grid.rows.count; i++) {
    final String value =
        grid.rows[i].cells[grid.columns.count - 1].value as String;
    total += double.parse(value);
  }
  return total;
}
