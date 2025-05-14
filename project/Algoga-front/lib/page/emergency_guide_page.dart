import 'package:algoga/page/member_info_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:algoga/widgets/app_bottom_nav_bar.dart';
import 'package:algoga/page/mainpage.dart';
import 'package:algoga/page/medicine_finder_page.dart';
import 'package:algoga/providers/auth_provider.dart';
import 'package:algoga/page/formpage.dart';

class EmergencyGuidePage extends ConsumerWidget {
  const EmergencyGuidePage({super.key});

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

    return _EmergencyGuidePageBody(memberId: memberId);
  }
}

class _EmergencyGuidePageBody extends ConsumerStatefulWidget {
  final int memberId;
  const _EmergencyGuidePageBody({super.key, required this.memberId});

  @override
  ConsumerState<_EmergencyGuidePageBody> createState() =>
      _EmergencyGuidePageBodyState();
}

class _EmergencyGuidePageBodyState
    extends ConsumerState<_EmergencyGuidePageBody> {
  int _currentIndex = 2;
  final List<bool> _expanded = List<bool>.filled(6, false);

  void _onNavTap(int index) {
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MainPage()),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MedicineFinderPage(destination: ''),
          //TODO: 현재 위치 전달
        ),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EmergencyGuidePage()),
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
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상단 로고 & 위치
                Row(
                  children: [
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.location_on,
                              color: Colors.grey,
                              size: 20,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Seoul, Korea',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // 제목
                const Text(
                  'Emergency Response Guide',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Quick guide for emergency situations',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 20),
                // 주요 응급 상황
                const Text(
                  'Main Emergency Situations',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                // 응급처치 가이드
                const Text(
                  'Emergency Treatment Guide',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),

                // ... existing code ...
                ExpansionPanelList(
                  elevation: 1,
                  expandedHeaderPadding: EdgeInsets.zero,
                  expansionCallback: (panelIndex, isExpanded) {
                    print(
                      'Panel $panelIndex clicked, current state: ${_expanded[panelIndex]}',
                    );
                    setState(() {
                      _expanded[panelIndex] = isExpanded;
                    });
                    print(
                      'Panel $panelIndex new state: ${_expanded[panelIndex]}',
                    );
                  },
                  children: [
                    ExpansionPanel(
                      isExpanded: _expanded[0],
                      canTapOnHeader: true,
                      headerBuilder: (context, isExpanded) {
                        return ListTile(
                          leading: const Text(
                            '🩺',
                            style: TextStyle(fontSize: 24),
                          ),
                          title: const Text(
                            'Severe Abdominal Pain',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                      body: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Abdominal pain can occur due to various causes such as indigestion, gastritis, enteritis, and overeating. Emergency treatment may be needed if the pain persists or is severe.',
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Rest Position',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Lie down in a comfortable position and rest. Observe if the pain subsides.',
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Stop Food Intake',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Stop eating for a while and drink only small amounts of water.',
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Avoid Abdominal Pressure',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Avoid tight clothing and any pressure on the abdomen.',
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Visit Medical Facility',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Visit a hospital if the pain persists for more than 2 hours or if the abdomen becomes hard.',
                            ),
                          ],
                        ),
                      ),
                    ),
                    ExpansionPanel(
                      isExpanded: _expanded[1],
                      canTapOnHeader: true,
                      headerBuilder: (context, isExpanded) {
                        return ListTile(
                          leading: const Text(
                            '🧻',
                            style: TextStyle(fontSize: 24),
                          ),
                          title: const Text(
                            'Severe Diarrhea',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                      body: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Diarrhea can occur due to various causes such as food, viruses, and stress, and may be accompanied by dehydration symptoms.',
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Hydration',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Drink water, electrolyte drinks, or ORS (Oral Rehydration Solution) frequently.',
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Avoid Irritating Foods',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Avoid oily foods, dairy products, and cold foods. Instead, consume rice porridge or soft foods.',
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Maintain Cleanliness',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Wash hands thoroughly to prevent the spread of infection.',
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Visit Hospital if Persistent',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Visit a hospital if it persists for more than a day, if there is blood in the stool, or if accompanied by high fever.',
                            ),
                          ],
                        ),
                      ),
                    ),
                    ExpansionPanel(
                      isExpanded: _expanded.length > 2 ? _expanded[2] : false,
                      canTapOnHeader: true,
                      headerBuilder: (context, isExpanded) {
                        return ListTile(
                          leading: const Text(
                            '🌡️',
                            style: TextStyle(fontSize: 24),
                          ),
                          title: const Text(
                            'When Having Fever',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                      body: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fever can occur due to various causes such as infection and inflammation. Caution is needed when body temperature is above 38°C.',
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Check Temperature',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Use a thermometer to measure your exact body temperature.',
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Hydration',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Drink fluids frequently to prevent dehydration.',
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Create Cool Environment',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Lower the room temperature and wear light clothing.',
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Use Fever Reducers',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Use common fever reducers like acetaminophen if necessary.',
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Visit Hospital for High Fever',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Visit a hospital immediately if the fever persists above 39°C or is accompanied by convulsions or decreased consciousness.',
                            ),
                          ],
                        ),
                      ),
                    ),
                    ExpansionPanel(
                      isExpanded: _expanded.length > 3 ? _expanded[3] : false,
                      canTapOnHeader: true,
                      headerBuilder: (context, isExpanded) {
                        return ListTile(
                          leading: const Text(
                            '🤕',
                            style: TextStyle(fontSize: 24),
                          ),
                          title: const Text(
                            'Severe Headache',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                      body: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Headaches can occur due to various causes such as tension, fatigue, lack of sleep, and high blood pressure.',
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Rest in Quiet, Dark Place',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('Rest your eyes and brain to reduce pain.'),
                            SizedBox(height: 8),
                            Text(
                              'Hydration',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Drink plenty of water as the headache might be due to dehydration.',
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Caffeine Intake Caution',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('Excessive caffeine can worsen headaches.'),
                            SizedBox(height: 8),
                            Text(
                              'Visit Hospital for Persistent or Severe Pain',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Immediate medical attention is needed if speech becomes slurred or if accompanied by paralysis symptoms.',
                            ),
                          ],
                        ),
                      ),
                    ),
                    ExpansionPanel(
                      isExpanded: _expanded.length > 4 ? _expanded[4] : false,
                      canTapOnHeader: true,
                      headerBuilder: (context, isExpanded) {
                        return ListTile(
                          leading: const Text(
                            '🤮',
                            style: TextStyle(fontSize: 24),
                          ),
                          title: const Text(
                            'When Vomiting',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                      body: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Vomiting can occur due to infection, food poisoning, motion sickness, etc., and repeated vomiting can lead to dehydration.',
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Rest After Vomiting',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Turn your head to the side to prevent airway obstruction and rest adequately.',
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Hydration',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Drink small amounts of water or electrolyte drinks frequently.',
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Stop Food Intake',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('Avoid eating until vomiting stops.'),
                            SizedBox(height: 8),
                            Text(
                              'Visit Hospital for Persistent Vomiting',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Medical attention is needed if vomiting persists for more than 6 hours or if blood is present.',
                            ),
                          ],
                        ),
                      ),
                    ),
                    ExpansionPanel(
                      isExpanded: _expanded.length > 5 ? _expanded[5] : false,
                      canTapOnHeader: true,
                      headerBuilder: (context, isExpanded) {
                        return ListTile(
                          leading: const Text(
                            '❗',
                            style: TextStyle(fontSize: 24),
                          ),
                          title: const Text(
                            'Other Emergency Situations',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                      body: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Other symptoms include dizziness, fainting, and difficulty breathing, which require immediate attention.',
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Secure Safe Location',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Move to a safe place where there is no risk of falling or injury.',
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Check Consciousness and Call 119',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Call 119 immediately if there is no response or abnormal breathing.',
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Attempt Basic First Aid',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('Start CPR if there is no breathing.'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // ... existing code ...
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmergencyIcon extends StatelessWidget {
  final String label;
  final IconData icon;
  const _EmergencyIcon({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: Colors.black),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
