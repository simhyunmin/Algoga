import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MemberInfoPage extends StatefulWidget {
  final int memberId;
  const MemberInfoPage({super.key, required this.memberId});

  @override
  State<MemberInfoPage> createState() => _MemberInfoPageState();
}

class _MemberInfoPageState extends State<MemberInfoPage> {
  Map<String, dynamic>? _memberInfo;
  bool _isLoading = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _fetchMemberInfo();
  }

  Future<void> _fetchMemberInfo() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/member/${widget.memberId}/info'),
      );
      if (response.statusCode == 200) {
        setState(() {
          _memberInfo = json.decode(utf8.decode(response.bodyBytes));
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMsg = 'Failed to load member information.';
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('My Information'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
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
              : _memberInfo == null
              ? const Center(child: Text('No member information available.'))
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 상단 프로필
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 240, 240, 240),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.location_on,
                                  color: Colors.grey,
                                  size: 18,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Seoul, Korea',
                                  style: TextStyle(fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // 프로필 사진, 이름, 한줄소개, 수정
                      Column(
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: const Color(0xFF2979FF),
                            child: const Icon(
                              Icons.person,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _memberInfo!['name'] ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Striving for a healthy day',
                            style: TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: _showEditDialog,
                              icon: const Icon(
                                Icons.edit,
                                size: 18,
                                color: Color(0xFF2979FF),
                              ),
                              label: const Text(
                                'Edit',
                                style: TextStyle(color: Color(0xFF2979FF)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // 정보 카드
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0.5,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _infoColumn(
                                    'Nationality',
                                    _memberInfo!['country'] ?? '',
                                  ),
                                  _infoColumn(
                                    'Gender',
                                    _memberInfo!['gender'] ?? '',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _infoColumn(
                                    'Birth Date',
                                    _formatBirth(_memberInfo!['birth']),
                                  ),
                                  const SizedBox(width: 0),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _infoColumn(
                                    'Travel Locations',
                                    (_memberInfo!['travelLocations'] ?? '')
                                        .toString(),
                                  ),
                                  const SizedBox(width: 0),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Divider(),
                              const Text(
                                'Disease Information',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              ..._parseDiseaseList(_memberInfo!['disease']),
                              const SizedBox(height: 16),
                              const Text(
                                'Medications',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              ..._parseMedicationList(
                                _memberInfo!['medications'],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _infoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  static Widget _diseaseChip(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF2979FF), size: 18),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }

  List<Widget> _parseDiseaseList(dynamic disease) {
    if (disease == null || (disease is String && disease.trim().isEmpty))
      return [
        const Text('No information', style: TextStyle(color: Colors.black54)),
      ];
    if (disease is List) {
      return disease
          .map<Widget>((d) => _diseaseChip(d.toString().trim()))
          .toList();
    } else if (disease is String) {
      return disease.split(',').map((d) => _diseaseChip(d.trim())).toList();
    }
    return [Text(disease.toString())];
  }

  List<Widget> _parseMedicationList(dynamic meds) {
    if (meds == null || (meds is String && meds.trim().isEmpty))
      return [
        const Text('No information', style: TextStyle(color: Colors.black54)),
      ];
    if (meds is List) {
      return meds
          .map<Widget>((d) => _diseaseChip(d.toString().trim()))
          .toList();
    } else if (meds is String) {
      return meds.split(',').map((d) => _diseaseChip(d.trim())).toList();
    }
    return [Text(meds.toString())];
  }

  void _showEditDialog() async {
    final nameController = TextEditingController(
      text: _memberInfo?['name'] ?? '',
    );
    final travelController = TextEditingController(
      text: _memberInfo?['travelLocations'] ?? '',
    );
    final diseaseController = TextEditingController(
      text: _memberInfo?['disease'] ?? '',
    );
    final medsController = TextEditingController(
      text: _memberInfo?['medications'] ?? '',
    );
    final birthRaw = _memberInfo?['birth'];
    DateTime? birthDate;
    if (birthRaw is String && birthRaw.isNotEmpty) {
      try {
        birthDate = DateTime.parse(birthRaw);
      } catch (_) {}
    }
    final birthController = TextEditingController(
      text: birthDate != null ? _formatBirth(birthDate) : (birthRaw ?? ''),
    );
    final countryController = TextEditingController(
      text: _memberInfo?['country'] ?? '',
    );
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Member Information'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: countryController,
                  decoration: const InputDecoration(labelText: 'Nationality'),
                ),
                TextField(
                  controller: travelController,
                  decoration: const InputDecoration(
                    labelText: 'Travel Locations',
                  ),
                ),
                TextField(
                  controller: birthController,
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'Birth Date'),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: birthDate ?? DateTime(2000, 1, 1),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      birthController.text = _formatBirth(picked);
                      birthDate = picked;
                    }
                  },
                ),
                TextField(
                  controller: diseaseController,
                  decoration: const InputDecoration(
                    labelText: 'Diseases (comma separated)',
                  ),
                ),
                TextField(
                  controller: medsController,
                  decoration: const InputDecoration(
                    labelText: 'Medications (comma separated)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () async {
                final updated = {
                  'name': nameController.text.trim(),
                  'birth': birthController.text.trim(),
                  'country': countryController.text.trim(),
                  'travelLocations': travelController.text.trim(),
                  'disease': diseaseController.text.trim(),
                  'medications': medsController.text.trim(),
                };
                final url =
                    'http://localhost:8080/member/${widget.memberId}/info/update';
                final res = await http.put(
                  Uri.parse(url),
                  headers: {'Content-Type': 'application/json'},
                  body: json.encode(updated),
                );
                if (res.statusCode == 200) {
                  Navigator.pop(context);
                  _fetchMemberInfo();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Update failed')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  String _formatBirth(dynamic birth) {
    if (birth == null) return '';
    if (birth is String && birth.isNotEmpty) {
      final match = RegExp(r'\d{4}[-/]\d{2}[-/]\d{2}').firstMatch(birth);
      if (match != null) return match.group(0)!;
      return birth;
    }
    if (birth is DateTime) {
      return "${birth.year.toString().padLeft(4, '0')}-${birth.month.toString().padLeft(2, '0')}-${birth.day.toString().padLeft(2, '0')}";
    }
    return birth.toString();
  }
}
