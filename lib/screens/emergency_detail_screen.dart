import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/emergency_response.dart';

class EmergencyDetailScreen extends StatelessWidget {
  final EmergencyItem room;
  final String selectedRegion; // 현재 선택된 시도 또는 시군구를 전달받는 변수

  const EmergencyDetailScreen({super.key, required this.room, required this.selectedRegion});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(room.dutyName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 기관명, 병원 이미지
            GestureDetector(
              onTap: () => _launchNaverSearch(room.dutyName, selectedRegion),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // 병원 이름
                        Row(
                          children: [
                            const Icon(
                              Icons.local_hospital,
                              color: Colors.redAccent,
                              size: 36.0,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              room.dutyName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                decoration: TextDecoration.underline,
                                height: 2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        // 병원 이미지 추가 (임시 이미지 경로, 실제 이미지는 네트워크 이미지 사용 가능)
                        Container(
                          width: double.infinity,
                          height: 180,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: const DecorationImage(
                              fit: BoxFit.contain,
                              image: NetworkImage(
                                  'https://cdn.pixabay.com/photo/2024/04/10/00/46/hospital-8687007_1280.jpg'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        // 병원 정보
                        Text(
                          '기관명: ${room.dutyName}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 응급실 정보 카드
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.phone, color: Colors.blueAccent, size: 24),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _launchPhoneDialer(room.dutyTel3),
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Text(
                              '응급실 전화번호: ${room.dutyTel3}',
                              style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.blueAccent,
                                  decoration: TextDecoration.underline,
                                  height: 2,
                                  decorationColor: Colors.blueAccent),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.bedroom_child_outlined, color: Colors.redAccent, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          '응급실 가용 병상: ${room.hvec}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.king_bed, color: Colors.amber[800], size: 24),
                        const SizedBox(width: 8),
                        Text(
                          '입원실 가용 병상: ${room.hvgc}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _launchPhoneDialer(String telNumber) async {
    final Uri telUri = Uri(scheme: 'tel', path: telNumber);

    if (await canLaunchUrl(telUri)) {
      await launchUrl(telUri);
    } else {
      throw 'Could not launch call $telUri';
    }
  }

  _launchNaverSearch(String dutyName, String selectedRegion) async {
    final Uri searchUri = Uri.parse(
      'https://search.naver.com/search.naver?query=$selectedRegion+$dutyName',
    );

    if (await canLaunchUrl(searchUri)) {
      await launchUrl(searchUri);
    } else {
      throw 'Could not launch naver $searchUri';
    }
  }
}
