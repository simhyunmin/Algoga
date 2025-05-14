import 'dart:convert';

import 'package:algoga/page/member_info_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:algoga/widgets/app_bottom_nav_bar.dart';
import 'package:algoga/page/mainpage.dart';
import 'package:algoga/page/emergency_guide_page.dart';
import 'package:algoga/providers/auth_provider.dart';
import 'package:algoga/page/formpage.dart';
import 'package:http/http.dart' as http;

class MedicineFinderPage extends ConsumerWidget {
  const MedicineFinderPage({super.key, required this.destination});
  final String destination;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberId = ref.watch(authProvider);

    if (memberId == null) {
      // 로그인이 필요한 경우 FormPage로 리다이렉트
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const FormPage()),
        );
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return _MedicineFinderPageBody(
      memberId: memberId,
      destination: destination,
    );
  }
}

class _MedicineFinderPageBody extends ConsumerStatefulWidget {
  final int memberId;
  final String destination;
  const _MedicineFinderPageBody({
    super.key,
    required this.memberId,
    required this.destination,
  });

  @override
  ConsumerState<_MedicineFinderPageBody> createState() =>
      _MedicineFinderPageBodyState();
}

class _MedicineFinderPageBodyState
    extends ConsumerState<_MedicineFinderPageBody> {
  int _currentIndex = 1;
  Map<String, dynamic>? _drugAnalysisResult;
  bool _isLoading = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    fetchDrugAnalysis();
  }

  Future<void> fetchDrugAnalysis() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    try {
      final uri = Uri.parse(
        'http://localhost:8080/analyze/drug/${widget.memberId}?destination=${Uri.encodeComponent(widget.destination)}',
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        setState(() {
          _drugAnalysisResult = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMsg = 'Failed to load analysis results.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMsg = 'Network error: $e';
        _isLoading = false;
      });
    }
  }

  void _onNavTap(int index) {
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MainPage()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const EmergencyGuidePage()),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MemberInfoPage(memberId: widget.memberId),
        ),
      );
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: AppBottomNavBar(currentIndex: 1, onTap: _onNavTap),
      body: SafeArea(
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMsg != null
                ? Center(
                  child: Text(
                    _errorMsg!,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
                : _drugAnalysisResult == null
                ? const Center(child: Text('No analysis results available.'))
                : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 상단 로고 & 위치
                        Row(
                          children: [
                            Text(
                              'Algoga',
                              style: TextStyle(
                                fontFamily: 'Pacifico',
                                color: Colors.blue[700],
                                fontSize: 24,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: Colors.grey,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.destination,
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // 섹션1 타이틀
                        const Text(
                          'Local Alternative Medicine Recommendations',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildCurrentMedicationCard(
                          _drugAnalysisResult!['current_medication'],
                        ),
                        const SizedBox(height: 24),
                        // 섹션2 타이틀
                        const Text(
                          'Available Local Alternative Medicines',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildAlternativeMedications(
                          _drugAnalysisResult!['alternative_medications'],
                        ),
                        // 안내 박스
                        if (_drugAnalysisResult!['precautions'] != null)
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(top: 8, bottom: 20),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE3F2FD),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(
                                      Icons.info_outline,
                                      color: Color(0xFF1976D2),
                                      size: 20,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Precautions for Medicine Substitution',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1976D2),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ...(_drugAnalysisResult!['precautions'] as List)
                                    .map(
                                      (p) => Text(
                                        p['message'],
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildCurrentMedicationCard(Map<String, dynamic>? med) {
    if (med == null) return const SizedBox();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  med['name'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Active Ingredient: ${med['active_ingredient'] ?? ''}',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  'Dosage: ${med['dosage'] ?? ''}',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  'Usage: ${med['usage'] ?? ''}',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlternativeMedications(List<dynamic>? meds) {
    if (meds == null || meds.isEmpty) return const SizedBox();
    return Column(
      children:
          meds
              .map(
                (m) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 상단: 의약품명과 브랜드명
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                m['name'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                                softWrap: true,
                                overflow: TextOverflow.visible,
                                maxLines: 2,
                              ),
                              if (m['brand_name'] != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  m['brand_name'],
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                  maxLines: 1,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 12),
                          // 중단: 주요 정보
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.science,
                                      size: 16,
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Active Ingredient: ${m['active_ingredient'] ?? ''}',
                                        style: const TextStyle(fontSize: 14),
                                        softWrap: true,
                                        overflow: TextOverflow.visible,
                                        maxLines: 2,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.medication,
                                      size: 16,
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Dosage: ${m['dosage'] ?? ''}',
                                        style: const TextStyle(fontSize: 14),
                                        softWrap: true,
                                        overflow: TextOverflow.visible,
                                        maxLines: 2,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          // 성분 일치도 분석
                          if (m['match_percentage'] != null)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.analytics,
                                    size: 16,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Ingredient Match Analysis: ${m['match_percentage']}%',
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      softWrap: true,
                                      overflow: TextOverflow.visible,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 12),
                          // 하단: 가격 정보
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Icon(
                                Icons.attach_money,
                                size: 16,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                m['price'] ?? '',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }
}
