// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/emergency_request.dart';
import '../models/emergency_response.dart';
import '../models/location_data.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import 'emergency_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late GoogleMapController _mapController;
  List<Marker> _markers = [];
  final ApiService apiService = ApiService();
  EmergencyResponse? _emergencyResponse; // 응급실 데이터
  Position? _currentPosition;

  // Stage1 (시/도)와 Stage2 (시군구) 관련 상태 관리
  String? selectedStage1;
  String? selectedStage2;

  @override
  void initState() {
    super.initState();
    // 위치 권한 확인 (향후 GPS API 연동후 사용)
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Image.network(
            'https://i.imgur.com/B4FUo0m.png',
            width: 40, // 이미지 너비
            height: 40, // 이미지 높이
            fit: BoxFit.contain, // 이미지를 컨테이너에 맞게 표시
          ),
          const SizedBox(
            width: 10,
          ),
          const Text('응급실 찾기 앱')
        ]),
      ),
      body: Column(
        children: [
          // 시/도와 시군구 선택 콤보박스 및 조회 버튼을 한 줄(Row)로 배치
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Row(
              children: [
                // 시/도 선택 콤보박스
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: '시/도 선택',
                      labelStyle: TextStyle(fontSize: 14),
                      border: OutlineInputBorder(),
                    ),
                    value: selectedStage1,
                    items: LocationData.stage1Options.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedStage1 = newValue;
                        selectedStage2 = null; // 시/도가 변경되면 시군구 초기화
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8.0), // 시/도와 시군구 사이의 간격

                // 시군구 선택 콤보박스
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: '시군구 선택',
                      labelStyle: TextStyle(fontSize: 14),
                      border: OutlineInputBorder(),
                    ),
                    value: selectedStage2,
                    items: selectedStage1 != null
                        ? LocationData.stage2Options[selectedStage1!]!.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value, style: const TextStyle(fontSize: 14)),
                            );
                          }).toList()
                        : [],
                    onChanged: (newValue) {
                      setState(() {
                        selectedStage2 = newValue;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8.0), // 시군구와 조회 버튼 사이 간격

                // 조회 버튼
                ElevatedButton(
                  onPressed: selectedStage1 != null && selectedStage2 != null ? _fetchAndDisplayMarkers : null,
                  child: const Text(
                    '조회',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),

          // List 또는 Map을 보여주는 탭
          Expanded(
            child: _selectedIndex == 0 ? _buildEmergencyList() : _buildMap(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildEmergencyList() {
    if (_emergencyResponse == null) {
      // return Center(child: CircularProgressIndicator());
      return Icon(
        Icons.manage_search_rounded,
        size: 150,
        color: Colors.blue[600],
      );
    } else {
      if (_emergencyResponse!.body.items.isEmpty)
        return Center(child: Text('조회된 병원이 없습니다..', style: TextStyle(fontSize: 45, color: Colors.redAccent.shade400)));
    }

    // 응급실 리스트 UI
    return ListView.separated(
      itemCount: _emergencyResponse!.body.items.length,
      itemBuilder: (context, index) {
        final room = _emergencyResponse!.body.items[index];
        return ListTile(
          leading: const Icon(
            Icons.local_hospital,
            size: 40, // 아이콘 크기 설정
            color: Colors.redAccent, // 아이콘 색상 설정
          ),
          title: Text(
            room.dutyName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ), // 기관명
          subtitle: Text('응급실 가용 병상: ${room.hvec}'),
          onTap: () {
            // 응급실 상세 화면으로 이동
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EmergencyDetailScreen(
                  room: room,
                  selectedRegion: '${selectedStage1!} ${selectedStage2!}',
                ), // 객체 전달
              ),
            );
          },
        );
      },
      separatorBuilder: (context, index) => Divider(
        color: Colors.grey[300], // 구분선 색상 설정
        thickness: 1,
      ),
    );
  }

  Widget _buildMap() {
    if (_currentPosition == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        zoom: 12,
      ),
      markers: _markers.toSet(),
    );
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position? position = await LocationService().getCurrentLocation();

      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      log('Error: $e');
    }
  }

  Future<void> _fetchAndDisplayMarkers() async {
    if (selectedStage1 == null || selectedStage2 == null) return;

    try {
      // 요청 파라미터
      EmergencyRequest request = EmergencyRequest(
        stage1: selectedStage1!,
        stage2: selectedStage2!,
        pageNo: 1,
        numOfRows: 10,
      );

      // API 호출
      EmergencyResponse? emergencyResponse = await apiService.fetchEmergencyRoomInfo(request);

      if (emergencyResponse != null) {
        // 마커 생성
        List<Marker> markers = emergencyResponse.body.items.map((room) {
          // 위도, 경도를 사용하는 마커 생성 부분
          // 예시로 임시 값 사용 (실제로는 room에서 lat, lng 데이터를 가져와야 함)
          double lat = 37.5665; // 서울 임시 위도 (실제 데이터로 수정 필요)
          double lng = 126.9780; // 서울 임시 경도 (실제 데이터로 수정 필요)

          return createMarker(lat, lng, room.dutyName);
        }).toList();

        setState(() {
          _markers = markers;
          _emergencyResponse = emergencyResponse;
        });
      }
    } catch (e) {
      log('Error: $e');
    }
  }

  Marker createMarker(double lat, double lng, String title) {
    return Marker(
      markerId: MarkerId(title),
      position: LatLng(lat, lng),
      infoWindow: InfoWindow(
        title: title,
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
