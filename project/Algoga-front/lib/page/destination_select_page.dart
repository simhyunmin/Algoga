import 'package:flutter/material.dart';

class DestinationSelectPage extends StatefulWidget {
  final int memberId;
  final String defaultDestination;
  final List<String> recentDestinations;
  final void Function(String) onDestinationSelected;

  const DestinationSelectPage({
    super.key,
    required this.memberId,
    required this.defaultDestination,
    required this.recentDestinations,
    required this.onDestinationSelected,
  });

  @override
  State<DestinationSelectPage> createState() => _DestinationSelectPageState();
}

class _DestinationSelectPageState extends State<DestinationSelectPage> {
  late TextEditingController _controller;
  String? _selectedRecent;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.defaultDestination);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Destination'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter Destination',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Enter your destination',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            if (widget.recentDestinations.isNotEmpty) ...[
              const Text(
                'Recently Used Destinations',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children:
                    widget.recentDestinations
                        .map(
                          (loc) => ChoiceChip(
                            label: Text(loc),
                            selected: _selectedRecent == loc,
                            onSelected: (selected) {
                              setState(() {
                                _selectedRecent = selected ? loc : null;
                                _controller.text = loc;
                              });
                            },
                          ),
                        )
                        .toList(),
              ),
              const SizedBox(height: 24),
            ],
            const Spacer(),
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
                    _controller.text.trim().isEmpty
                        ? null
                        : () {
                          widget.onDestinationSelected(_controller.text.trim());
                        },
                child: const Text(
                  'Next',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
