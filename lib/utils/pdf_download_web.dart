// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:html' as html;
import '../models/portfolio_state_model.dart';

void downloadPdfFile(CertificationModel cert) {
  if (cert.pdfBase64.isEmpty) return;
  
  if (cert.pdfBase64.startsWith('http://') || cert.pdfBase64.startsWith('https://')) {
    html.AnchorElement(href: cert.pdfBase64)
      ..target = '_blank'
      ..click();
  } else {
    final base64Data = cert.pdfBase64.contains(',') 
        ? cert.pdfBase64.split(',').last 
        : cert.pdfBase64;
        
    html.AnchorElement(href: 'data:application/pdf;base64,$base64Data')
      ..target = '_blank'
      ..download = '${cert.title.replaceAll(' ', '_')}.pdf'
      ..click();
  }
}

