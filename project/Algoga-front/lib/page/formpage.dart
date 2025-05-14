import 'package:algoga/providers/auth_provider.dart';
import 'package:algoga/page/mainpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dio/dio.dart';
import 'package:algoga/providers/dio_provider.dart';
import 'package:algoga/providers/api_service_provider.dart';

class FormPage extends ConsumerStatefulWidget {
  const FormPage({super.key});

  @override
  ConsumerState<FormPage> createState() => _UserTravelInfoPageState();
}

class _UserTravelInfoPageState extends ConsumerState<FormPage> {
  String? _age;
  String? _gender;
  String? _nationality;
  String? _diseaseInfo;
  String? _drugName;
  String? _dosage;
  DateTime? _startDate;

  // 여행지 관련 상태 변수만 남기고 나머지 여행 관련 변수/위젯/페이지 삭제
  String? _travelLocation;

  // 사용자 정보 입력 상태 변수 추가
  String? _userId;
  String? _userPw;
  String? _userName;
  DateTime? _birthDate;

  final List<String> nationalityOptions = [
    'korea',
    'china',
    'japan',
    'usa',
    'taiwan',
    'thailand',
    'vietnam',
    'philippines',
    'malaysia',
    'singapore',
    'indonesia',
    'hongkong',
    'australia',
    'canada',
    'russia',
    'mongolia',
    'india',
    'unitedkingdom',
    'germany',
    'france',
    'italy',
    'spain',
    'netherlands',
    'switzerland',
    'sweden',
    'norway',
    'denmark',
    'finland',
    'austria',
    'belgium',
    'czechrepublic',
    'poland',
    'turkey',
    'unitedarabemirates',
    'qatar',
    'saudiarabia',
    'kazakhstan',
    'uzbekistan',
    'newzealand',
    'brazil',
    'mexico',
    'argentina',
    'chile',
    'southafrica',
    'egypt',
    'morocco',
    'israel',
    'myanmar',
    'cambodia',
    'laos',
    'nepal',
  ];

  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _drugList = [];

  String? _errorMsg;
  bool _isLoading = false;

  // 국가, 성별, 질병 Enum 리스트 (영문만)
  final List<String> countryOptions = [
    'Korea',
    'China',
    'Japan',
    'Usa',
    'Taiwan',
    'Thailand',
    'Vietnam',
    'Philippines',
    'Malaysia',
    'Singapore',
    'Indonesia',
    'HongKong',
    'Australia',
    'Canada',
    'Russia',
    'Mongolia',
    'India',
    'UnitedKingdom',
    'Germany',
    'France',
    'Italy',
    'Spain',
    'Netherlands',
    'Switzerland',
    'Sweden',
    'Norway',
    'Denmark',
    'Finland',
    'Austria',
    'Belgium',
    'CzechRepublic',
    'Poland',
    'Turkey',
    'UnitedArabEmirates',
    'Qatar',
    'SaudiArabia',
    'Kazakhstan',
    'Uzbekistan',
    'NewZealand',
    'Brazil',
    'Mexico',
    'Argentina',
    'Chile',
    'SouthAfrica',
    'Egypt',
    'Morocco',
    'Israel',
    'Myanmar',
    'Cambodia',
    'Laos',
    'Nepal',
  ];
  final List<String> genderOptions = ['MEN', 'WOMEN', 'OTHER'];
  final List<String> diseaseOptions = [
    'UlcerativeColitis',
    'IrritableBowelSyndrome',
    'GastroesophagealReflux',
    'LactoseIntolerance',
  ];

  String? _nationalityEn;
  String? _genderEn;

  // 국가, 성별 드롭다운은 영문 Enum name을 value로 사용
  // _nationalityEn, _genderEn에 영문 Enum name 저장

  // Dio 인스턴스와 CookieJar 추가
  late final Dio _dio;

  int? _memberId;

  // 여행 정보 입력값 변수 추가
  String? _travelRegion;
  String? _travelPeriod;
  String? _travelUnit;
  // 여행지, 기간, 단위 옵션 예시
  final List<String> _regionOptions = [
    'Seoul',
    'Busan',
    'Daegu',
    'Incheon',
    'Gwangju',
    'Daejeon',
    'Ulsan',
    'Sejong',
    'Gyeonggi Province',
    'Gangwon Province',
    'North Chungcheong Province',
    'South Chungcheong Province',
    'North Jeolla Province',
    'South Jeolla Province',
    'North Gyeongsang Province',
    'South Gyeongsang Province',
    'Jeju Special Self-Governing Province',
  ];

  @override
  void initState() {
    super.initState();
  }

  String? _validateForm() {
    if ((_userId ?? '').isEmpty) return 'Please enter your ID.';
    if ((_userPw ?? '').isEmpty) return 'Please enter your password.';
    if ((_userName ?? '').isEmpty) return 'Please enter your name.';
    if (_birthDate == null) return 'Please select your birth date.';
    if ((_nationalityEn ?? '').isEmpty) return 'Please select your country.';
    if ((_genderEn ?? '').isEmpty) return 'Please select your gender.';
    if (_selectedInterests.isEmpty)
      return 'Please select at least one disease.';
    return null;
  }

  Future<void> postSignUp() async {
    final apiService = ref.read(apiServiceProvider);
    // 유효성 검사
    final validationError = _validateForm();
    if (validationError != null) {
      setState(() => _errorMsg = validationError);
      return;
    }
    if ((_userPw ?? '').isEmpty) {
      setState(() {
        _errorMsg = 'Please enter your password.';
      });
      return;
    }
    if ((_userName ?? '').isEmpty) {
      setState(() {
        _errorMsg = 'Please enter your name.';
      });
      return;
    }
    if (_birthDate == null) {
      setState(() {
        _errorMsg = 'Please select your birth date.';
      });
      return;
    }
    if ((_nationalityEn ?? '').isEmpty) {
      setState(() {
        _errorMsg = 'Please select your country.';
      });
      return;
    }
    if ((_genderEn ?? '').isEmpty) {
      setState(() {
        _errorMsg = 'Please select your gender.';
      });
      return;
    }
    if (_selectedInterests.isEmpty) {
      setState(() {
        _errorMsg = 'Please select at least one disease.';
      });
      return;
    }
    if ((_travelRegion ?? '').isEmpty) {
      setState(() {
        _errorMsg = 'Please select your travel destination.';
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    // Form 데이터 구성
    final formData = FormData.fromMap({
      'ID': _userId?.trim() ?? "",
      'password': _userPw?.trim() ?? "",
      'name': _userName?.trim() ?? "",
      'birth':
          _birthDate != null
              ? '${_birthDate!.year.toString().padLeft(4, '0')}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.day.toString().padLeft(2, '0')}'
              : "",
      'country': _nationalityEn?.trim() ?? "",
      'gender': _genderEn?.trim() ?? "",
      'disease': _selectedInterests
          .map((i) => diseaseOptions[i].trim())
          .join(','),
      'medications': _drugList
          .map((e) => e['name']?.toString().trim() ?? "")
          .join(','),
      'travelLocations': _travelRegion?.trim() ?? "",
    });

    print('회원가입 formData: $formData');

    final response = await apiService.signUp(formData);

    print('Response status: ${response.statusCode}');
    print('Response data: ${response.data}');

    if (response.statusCode == 200) {
      _handleSignUpSuccess(response.data);
    } else {
      _handleSignUpError(response.data);
    }
  }

  void _handleSignUpSuccess(dynamic responseData) {
    final memberId = responseData['memberId'] as int;
    setState(() {
      _isLoading = false;
    });

    // authProvider를 통해 memberId 설정
    ref.read(authProvider.notifier).setMemberId(memberId);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainPage()),
    );
  }

  void _handleSignUpError(dynamic error) {
    setState(() {
      _isLoading = false;
      _errorMsg =
          error is String
              ? 'Sign up failed: \n$error'
              : 'Network error: $error';
    });
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          children: [
            _buildUserInfoPage(),
            _buildInterestSelectionPage(),
            _buildDrugInfoPage(),
            _buildTravelInfoPage(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            const Text(
              'Welcome to Algoga!',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 10),
            const Text(
              'Please enter your information to receive smooth travel information.',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 48),
            _buildLabel('ID'),
            _buildTextField(
              hint: 'Enter your ID',
              obscure: false,
              onChanged: (v) => setState(() => _userId = v),
            ),
            const SizedBox(height: 18),
            _buildLabel('Password'),
            _buildTextField(
              hint: 'Enter your password',
              obscure: true,
              onChanged: (v) => setState(() => _userPw = v),
            ),
            const SizedBox(height: 18),
            _buildLabel('Name'),
            _buildTextField(
              hint: 'Enter your name',
              obscure: false,
              onChanged: (v) => setState(() => _userName = v),
            ),
            const SizedBox(height: 18),
            _buildLabel('Birth Date'),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _birthDate ?? DateTime(2000, 1, 1),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _birthDate = picked);
              },
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black26),
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFFF5F5F5),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.centerLeft,
                child: Text(
                  _birthDate == null
                      ? 'Select your birth date'
                      : '${_birthDate!.year}.${_birthDate!.month.toString().padLeft(2, '0')}.${_birthDate!.day.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: _birthDate == null ? Colors.black38 : Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            _buildLabel('Gender'),
            _buildDropdown(
              hint: 'Select your gender',
              value: _genderEn,
              items: genderOptions,
              onChanged: (v) => setState(() => _genderEn = v),
            ),
            const SizedBox(height: 18),
            _buildLabel('Country'),
            _buildDropdown(
              hint: 'Select your country',
              value: _nationalityEn,
              items: countryOptions,
              onChanged: (v) => setState(() => _nationalityEn = v),
            ),
            const SizedBox(height: 48),
            Center(
              child: SizedBox(
                width: 151,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B7BD1),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isLoading ? null : _nextPage,
                  child: const Text(
                    'Next Step',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  final Set<int> _selectedInterests = {};

  Widget _buildInterestSelectionPage() {
    final diseaseList = [
      'UlcerativeColitis',
      'IrritableBowelSyndrome',
      'GastroesophagealReflux',
      'LactoseIntolerance',
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Disease Types',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
          ),
          const SizedBox(height: 10),
          const Text(
            'Based on your selection, AI will provide information',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: GridView.builder(
              itemCount: diseaseList.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 32,
                crossAxisSpacing: 32,
                childAspectRatio: 1.1,
              ),
              itemBuilder: (context, index) {
                final isSelected = _selectedInterests.contains(index);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedInterests.remove(index);
                      } else if (_selectedInterests.length < 4) {
                        _selectedInterests.add(index);
                      }
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? const Color(0xFF0B7BD1)
                              : Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            diseaseList[index],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            diseaseList[index],
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 151,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD24C),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _prevPage,
                  child: const Text(
                    'Previous Step',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 151,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B7BD1),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed:
                      _selectedInterests.isEmpty || _isLoading
                          ? null
                          : _nextPage,
                  child:
                      _isLoading
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                          : const Text(
                            'Analyze',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
            ],
          ),
          if (_errorMsg != null) ...[
            const SizedBox(height: 10),
            Text(_errorMsg!, style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  Widget _buildDrugInfoPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const Text(
            'Enter Medication Information',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please enter any medications you are currently taking.',
            style: TextStyle(fontSize: 15, color: Colors.black),
          ),
          const Text(
            '(Will be reflected in AI analysis results)',
            style: TextStyle(fontSize: 14, color: Colors.black38),
          ),
          const SizedBox(height: 28),
          const Text(
            'Enter Medication Name',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              hintText: 'Example: Gaster, Trimebutine, etc.',
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black26),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            controller: TextEditingController(text: _drugName ?? '')
              ..selection = TextSelection.collapsed(
                offset: (_drugName ?? '').length,
              ),
            onChanged: (v) => setState(() => _drugName = v),
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
          const SizedBox(height: 18),
          const Text(
            'Added Medications',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
              ),
              padding: const EdgeInsets.all(12),
              child:
                  _drugList.isEmpty
                      ? const Center(
                        child: Text(
                          'No medications added',
                          style: TextStyle(color: Colors.black38, fontSize: 15),
                        ),
                      )
                      : ListView.separated(
                        itemCount: _drugList.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, idx) {
                          final drug = _drugList[idx];
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.black12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: ListTile(
                              title: Text(
                                drug['name'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _drugList.removeAt(idx);
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B7BD1),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                if ((_drugName ?? '').isNotEmpty) {
                  setState(() {
                    _drugList.add({'name': _drugName});
                    _drugName = null;
                  });
                }
              },
              child: const Text(
                '+ Add Medication',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B7BD1),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                // 여행지 정보 입력 페이지로 이동
                _nextPage();
              },
              child: const Text(
                'Next Step',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _buildTravelInfoPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            const Text(
              'Welcome to Algoga!',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 10),
            const Text(
              'Please select your travel destination!',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 32),
            _buildLabel('Travel Destination'),
            _buildDropdown(
              hint: 'Select your travel destination',
              value: _travelRegion,
              items: _regionOptions,
              onChanged: (v) => setState(() => _travelRegion = v),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B7BD1),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed:
                    (_travelRegion == null || _travelRegion!.isEmpty)
                        ? null
                        : () async {
                          await postSignUp();
                        },
                child: const Text(
                  'Next Step',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  );

  Widget _buildTextField({
    required String hint,
    required bool obscure,
    required void Function(String) onChanged,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFBDBDBD)),
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFFF5F5F5),
      ),
      child: TextField(
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    Widget Function(BuildContext, String)? itemBuilder,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFBDBDBD)),
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFFF5F5F5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: const Color(0xFFF5F5F5),
          focusColor: Colors.transparent,
          value: value,
          hint: Text(hint, style: const TextStyle(color: Colors.black38)),
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          onChanged: onChanged,
          items:
              items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
        ),
      ),
    );
  }
}
