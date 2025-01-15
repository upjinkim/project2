import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'image_picker_page.dart';
import 'analysis_result_page.dart';

class ImageUploadPage extends StatefulWidget {
  @override
  _ImageUploadPageState createState() => _ImageUploadPageState();
}

class _ImageUploadPageState extends State<ImageUploadPage> {
  Uint8List? _imageBytes; // 선택된 이미지 데이터

  // 이미지 선택 및 분석 처리
  Future<void> _pickAndAnalyzeImage() async {
    try {
      // 이미지 선택 화면으로 이동
      final imageBytes = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ImagePickerPage()),
      );

      if (imageBytes != null) {
        setState(() {
          _imageBytes = imageBytes; // 선택된 이미지 데이터 저장
        });

        // 분석 결과 얻기
        final analysisResult = await _analyzeImage(imageBytes);

        // 분석 결과 페이지로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnalysisResultPage(analysisResult: analysisResult),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("오류 발생: $e")),
      );
    }
  }

  // 서버에 이미지 보내기 및 분석 결과 받기
  Future<String> _analyzeImage(Uint8List imageBytes) async {
    const String apiUrl = "실제 api url"; 
    String result = "분석 결과를 가져올 수 없습니다.";

    try {
      final request = http.MultipartRequest("POST", Uri.parse(apiUrl))
        ..files.add(http.MultipartFile.fromBytes('image', imageBytes, filename: 'image.jpg'));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final data = jsonDecode(responseBody);

        result = """
        약품 이름: ${data['name'] ?? '정보 없음'}
        복용 방법: ${data['usage'] ?? '정보 없음'}
        성분: ${data['ingredients'] ?? '정보 없음'}
        효과: ${data['effects'] ?? '정보 없음'}
        부작용: ${data['side_effects'] ?? '정보 없음'}
        주의사항: ${data['precautions'] ?? '정보 없음'}
        """;
      } else {
        result = "분석 실패: 상태 코드 ${response.statusCode}";
      }
    } catch (e) {
      result = "분석 중 오류 발생: $e";
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("이미지 업로드 및 분석")),
      body: Center(
        child: ElevatedButton(
          onPressed: _pickAndAnalyzeImage, // 이미지 선택 및 분석
          child: Text("이미지 선택 및 분석"),
        ),
      ),
    );
  }
}
