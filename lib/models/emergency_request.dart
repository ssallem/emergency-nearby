class EmergencyRequest {
  final String stage1; // 시도 (필수)
  final String stage2; // 시군구 (필수)
  final int pageNo; // 페이지 번호 (옵션, 기본값 1)
  final int numOfRows; // 목록 건수 (옵션, 기본값 10)

  EmergencyRequest({
    required this.stage1,
    required this.stage2,
    this.pageNo = 1,
    this.numOfRows = 10,
  });

  Map<String, dynamic> toMap() {
    return {
      'STAGE1': stage1,
      'STAGE2': stage2,
      'pageNo': pageNo,
      'numOfRows': numOfRows,
    };
  }
}
