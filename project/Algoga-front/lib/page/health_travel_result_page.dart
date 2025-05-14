import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HealthTravelResultPage extends StatefulWidget {
  final int memberId;
  final String destination;
  const HealthTravelResultPage({
    super.key,
    required this.memberId,
    required this.destination,
  });

  @override
  State<HealthTravelResultPage> createState() => _HealthTravelResultPageState();
}

class _HealthTravelResultPageState extends State<HealthTravelResultPage> {
  Map<String, dynamic>? _result;
  bool _isLoading = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _fetchResult();
  }

  Future<void> _fetchResult() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    try {
      final uri = Uri.parse(
        'http://localhost:8080/analyze/health-travel/${widget.memberId}?destination=${Uri.encodeComponent(widget.destination)}',
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        setState(() {
          _result = json.decode(utf8.decode(response.bodyBytes));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE3F2FD),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Pre-travel Health Prevention Analysis Results',
          style: TextStyle(
            color: Color(0xFF1976D2),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMsg != null
              ? Center(
                child: Text(
                  _errorMsg!,
                  style: const TextStyle(color: Colors.red),
                ),
              )
              : _result == null
              ? const Center(child: Text('No analysis results available.'))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      'Basic Health Assessment',
                      _result!['basicHealthAssessment'],
                    ),
                    _buildSection(
                      'Remission Consultation',
                      _result!['remissionConsultation'],
                    ),
                    _buildSection(
                      'Medication Preparation',
                      _result!['medicationPreparation'],
                    ),
                    _buildSection(
                      'Medical Documents and Insurance',
                      _result!['medicalDocumentsAndInsurance'],
                    ),
                    _buildSection(
                      'Local Medical Infrastructure',
                      _result!['localMedicalInfrastructure'],
                    ),
                    _buildSection(
                      'Diet and Emergency Kit',
                      _result!['dietAndEmergencyKit'],
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildSection(String title, dynamic data) {
    if (data == null) return const SizedBox();
    final Map<String, dynamic> map = data is Map<String, dynamic> ? data : {};
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD), // 연한 파란색
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info, color: Color(0xFF1976D2), size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...map.entries
                .where((e) => e.key != 'reference')
                .map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _toKoreanLabel(e.key),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _buildPrettyText(e.value.toString()),
                      ],
                    ),
                  ),
                ),
            if (map['reference'] != null && map['reference'] is List)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(
                  spacing: 8,
                  children:
                      (map['reference'] as List)
                          .map<Widget>(
                            (url) => InkWell(
                              onTap: () => _launchUrl(url.toString()),
                              child: Text(
                                url.toString(),
                                style: const TextStyle(
                                  color: Color(0xFF1976D2),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrettyText(String text) {
    // 글머리표, 줄바꿈, 가독성 개선
    final lines = text.split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (lines.length <= 1) {
      return Text(
        text,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          lines.map((l) {
            final bullet = l.trim().startsWith('•') ? '' : '• ';
            return Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                '$bullet${l.trim()}',
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            );
          }).toList(),
    );
  }

  String _toKoreanLabel(String key) {
    switch (key) {
      case 'medicalHistorySummary':
        return 'Medical History Summary';
      case 'dietarySensitivityCheck':
        return 'Dietary Sensitivity Check';
      case 'stressImpactAssessment':
        return 'Stress Impact Assessment';
      case 'currentStatusCheck':
        return 'Current Status Check';
      case 'doseAdjustmentAdvice':
        return 'Dose Adjustment Advice';
      case 'regularMedications':
        return 'Regular Medications';
      case 'emergencyMedications':
        return 'Emergency Medications';
      case 'storageAndTransport':
        return 'Storage and Transport';
      case 'airportRegulations':
        return 'Airport Regulations';
      case 'englishDiagnosis':
        return 'English Diagnosis';
      case 'insuranceCoverage':
        return 'Insurance Coverage';
      case 'emergencySupport':
        return 'Emergency Support';
      case 'hospitalList':
        return 'Local Hospital List';
      case 'emergencyContacts':
        return 'Emergency Contacts';
      case 'languagePhrases':
        return 'Local Language Phrases';
      case 'dietPlan':
        return 'Diet Plan';
      case 'emergencySnacks':
        return 'Emergency Snacks';
      case 'survivalKit':
        return 'Survival Kit';
      default:
        return key;
    }
  }

  void _launchUrl(String url) async {
    // 실제 앱에서는 url_launcher 패키지 사용 권장
    // 이 예시에서는 단순히 복사만 구현
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('URL copied: $url')));
  }
}
