import 'package:algoga/page/analysis_result_page.dart';
import 'package:algoga/page/destination_select_page.dart';
import 'package:algoga/page/emergency_guide_page.dart';
import 'package:algoga/page/formpage.dart';
import 'package:algoga/page/health_travel_result_page.dart';
import 'package:algoga/page/medicine_finder_page.dart';
import 'package:algoga/page/member_info_page.dart';
import 'package:algoga/providers/api_service_provider.dart';
import 'package:algoga/providers/auth_provider.dart';
import 'package:algoga/widgets/app_bottom_nav_bar.dart';
import 'package:algoga/widgets/food_analysis_card.dart';
import 'package:algoga/widgets/user_info_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:image_picker/image_picker.dart';

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

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

    return _MainPageBody(memberId: memberId);
  }
}

class _MainPageBody extends ConsumerStatefulWidget {
  final int memberId;
  const _MainPageBody({super.key, required this.memberId});

  @override
  ConsumerState<_MainPageBody> createState() => _MainPageBodyState();
}

class _MainPageBodyState extends ConsumerState<_MainPageBody> {
  late int memberId;
  int currentIndex = 0;
  String _userTravelRegion = '';
  Map<String, dynamic>? _memberInfo;
  bool _isLoading = false;
  bool _isAnalyzing = false;
  bool _isHealthDialogOpen = false;
  String? _healthDialogDestination;
  @override
  void initState() {
    super.initState();
    memberId = widget.memberId;
    debugPrint('memberId: $memberId');
    fetchUserTravelRegion();
    fetchMemberInfo();
  }

  Future<void> fetchUserTravelRegion() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/member/$memberId/travel-locations'),
      );
      if (response.statusCode == 200) {
        setState(() {
          _userTravelRegion = response.body;
        });
      }
    } catch (e) {
      // 에러 핸들링 (네트워크 오류 등)
      debugPrint('Failed to load travel location information: $e');
    }
  }

  Future<void> fetchMemberInfo() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/member/$memberId/info'),
      );
      if (response.statusCode == 200) {
        setState(() {
          _memberInfo = json.decode(utf8.decode(response.bodyBytes));
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void onNavTap(int index) {
    if (index == 1) {
      if (index == 1) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => DestinationSelectPage(
                  memberId: memberId,
                  defaultDestination: _userTravelRegion,
                  recentDestinations: const [],
                  onDestinationSelected: (selectedDestination) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => MedicineFinderPage(
                              destination: selectedDestination,
                            ),
                      ),
                    );
                  },
                ),
          ),
        );
      }
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EmergencyGuidePage()),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MemberInfoPage(memberId: memberId),
        ),
      );
    } else {
      setState(() {
        currentIndex = index;
      });
    }
  }

  Future<void> handleImageAnalysis() async {
    final apiService = ref.read(apiServiceProvider);
    try {
      setState(() {
        _isAnalyzing = true;
      });

      final picker = ImagePicker();
      final imageFile = await picker.pickImage(source: ImageSource.camera);
      if (imageFile == null || !mounted) {
        setState(() {
          _isAnalyzing = false;
        });
        return;
      }

      final analysisResult = await apiService.analyzeImage(imageFile, memberId);

      if (!mounted) return;
      debugPrint(analysisResult.toString());
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => AnalysisResultPage(
                foodName: analysisResult['foodName'] ?? '',
                riskLevel: analysisResult['riskLevel'] ?? '',
                keywords:
                    (analysisResult['keywords'] is List)
                        ? (analysisResult['keywords'] as List)
                            .map((e) => e.toString())
                            .toList()
                        : [],
                conclusion: analysisResult['conclusion'] ?? '',
              ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: currentIndex,
        onTap: onNavTap,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildLocationHeader(),
                const SizedBox(height: 20),
                UserInfoCard(
                  name: _memberInfo?['name'] ?? '',
                  birth: _memberInfo?['birth'] ?? '',
                  disease:
                      (_memberInfo?['disease'] is String)
                          ? (_memberInfo?['disease'] as String).replaceAll(
                            ',',
                            ', ',
                          )
                          : (_memberInfo?['disease']?.toString() ?? ''),
                  travelLocation: _memberInfo?['travelLocations'] ?? '',
                ),
                const SizedBox(height: 28),
                buildSectionTitle('Automatic Food Risk Identification'),
                const SizedBox(height: 12),
                FoodAnalysisCard(
                  onCameraPressed: handleImageAnalysis,
                  isLoading: _isAnalyzing,
                ),
                const SizedBox(height: 28),
                buildSectionTitle('Analyze Results'),
                const SizedBox(height: 12),

                LayoutBuilder(
                  builder: (context, constraints) {
                    final maxWidth = constraints.maxWidth;
                    return Center(
                      child: SizedBox(
                        width: maxWidth,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 1,
                          margin: const EdgeInsets.only(bottom: 32),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 28,
                              horizontal: 16,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.health_and_safety,
                                  color: Colors.green[400],
                                  size: 56,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Pre-travel Health Prevention Analysis',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Receive customized analysis results based on your health information and travel destination for preventive measures before your trip.',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 15,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.health_and_safety),
                                  label: const Text('Get Prevention Analysis'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    minimumSize: const Size(180, 48),
                                    textStyle: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    elevation: 2,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _healthDialogDestination =
                                          _userTravelRegion;
                                      _isHealthDialogOpen = true;
                                    });
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        final controller =
                                            TextEditingController(
                                              text:
                                                  _healthDialogDestination ??
                                                  '',
                                            );
                                        return AlertDialog(
                                          title: const Text(
                                            'Enter Travel Destination',
                                          ),
                                          content: TextField(
                                            controller: controller,
                                            decoration: const InputDecoration(
                                              labelText: 'Destination',
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              child: const Text('Cancel'),
                                              onPressed:
                                                  () => Navigator.pop(context),
                                            ),
                                            ElevatedButton(
                                              child: const Text('Next Step'),
                                              onPressed: () {
                                                Navigator.pop(context);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (context) =>
                                                            HealthTravelResultPage(
                                                              memberId:
                                                                  memberId,
                                                              destination:
                                                                  controller
                                                                      .text
                                                                      .trim(),
                                                            ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildLocationHeader() {
    return Row(
      children: [
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 240, 240, 240),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: const [
                Icon(Icons.location_on, color: Colors.grey, size: 20),
                SizedBox(width: 4),
                Text('Seoul, Korea', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Icon(Icons.notifications_none, color: Colors.grey[600]),
      ],
    );
  }

  Widget buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
    );
  }

  Widget buildAnalysisResultCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [Text('예시 결과', style: TextStyle(fontSize: 15))],
        ),
      ),
    );
  }
}
