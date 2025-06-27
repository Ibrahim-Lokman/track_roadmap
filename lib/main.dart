import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:ui';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Learning Roadmap',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      home: const RoadmapScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class RoadmapScreen extends StatefulWidget {
  const RoadmapScreen({super.key});

  @override
  State<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends State<RoadmapScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? roadmapData;
  bool isLoading = true;
  int selectedMissionIndex = 0;
  Set<String> expandedCycles = {};
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    loadRoadmapData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> loadRoadmapData() async {
    try {
      final String response =
          await rootBundle.loadString('assets/data/roadmap.json');
      final data = await json.decode(response);
      setState(() {
        roadmapData = data['roadmap'];
        isLoading = false;
      });
    } catch (e) {
      print('Error loading roadmap data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A0E27),
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: const CircularProgressIndicator(
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    if (roadmapData == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0E27),
        body: Center(
          child: Text(
            'Error loading roadmap data',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF0A0E27),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 768;
          final isTablet =
              constraints.maxWidth >= 768 && constraints.maxWidth < 1024;

          return Stack(
            children: [
              // Background gradient
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0A0E27),
                      Color(0xFF1A1F3A),
                      Color(0xFF0F172A),
                    ],
                  ),
                ),
              ),
              // Floating orbs for glassmorphism effect
              ...List.generate(5, (index) => _buildFloatingOrb(index)),
              // Main content
              if (isMobile)
                _buildMobileLayout()
              else
                _buildDesktopLayout(isTablet),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFloatingOrb(int index) {
    final colors = [
      Colors.blue.withOpacity(0.3),
      Colors.purple.withOpacity(0.3),
      Colors.pink.withOpacity(0.3),
      Colors.cyan.withOpacity(0.3),
      Colors.teal.withOpacity(0.3),
    ];

    final positions = [
      const Alignment(-0.8, -0.8),
      const Alignment(0.8, -0.6),
      const Alignment(-0.6, 0.8),
      const Alignment(0.7, 0.7),
      const Alignment(0.0, 0.0),
    ];

    final sizes = [200.0, 150.0, 180.0, 160.0, 220.0];

    return Positioned.fill(
      child: Align(
        alignment: positions[index],
        child: Container(
          width: sizes[index],
          height: sizes[index],
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                colors[index],
                colors[index].withOpacity(0.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      drawer: _buildMobileDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          roadmapData?['title'] ?? 'Roadmap',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      body: _buildMainContent(isMobile: true),
    );
  }

  Widget _buildMobileDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF0A0E27).withOpacity(0.95),
      child: Column(
        children: [
          _buildHeader(isMobile: true),
          _buildOverview(isMobile: true),
          Expanded(child: _buildMissionsList(isMobile: true)),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(bool isTablet) {
    final sidebarWidth = isTablet ? 280.0 : 320.0;

    return Row(
      children: [
        // Sidebar with glassmorphism
        ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: sidebarWidth,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                border: Border(
                  right: BorderSide(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  _buildHeader(),
                  _buildOverview(),
                  Expanded(child: _buildMissionsList()),
                ],
              ),
            ),
          ),
        ),
        // Main content
        Expanded(
          child: _buildMainContent(),
        ),
      ],
    );
  }

  Widget _buildHeader({bool isMobile = false}) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF3B82F6).withOpacity(0.8),
            const Color(0xFF1E40AF).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            roadmapData?['title'] ?? 'Loading...',
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'by ${roadmapData?['author'] ?? 'Unknown'}',
            style: TextStyle(
              color: Colors.white70,
              fontSize: isMobile ? 12 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverview({bool isMobile = false}) {
    final overview = roadmapData?['overview'];
    if (overview == null) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overview',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          _buildOverviewItem(Icons.calendar_today, 'Duration',
              overview['duration'] ?? 'N/A', isMobile),
          _buildOverviewItem(Icons.access_time, 'Weekly Hours',
              '${overview['weeklyHours'] ?? 0}h', isMobile),
          _buildOverviewItem(Icons.timer, 'Total Hours',
              overview['totalHours'] ?? 'N/A', isMobile),
          _buildOverviewItem(
              Icons.assignment,
              'Missions',
              '${overview['totalMissions'] ?? 0} + ${overview['bufferMissions'] ?? 0} buffer',
              isMobile),
        ],
      ),
    );
  }

  Widget _buildOverviewItem(
      IconData icon, String label, String value, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: isMobile ? 14 : 16, color: Colors.white60),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label: $value',
              style: TextStyle(
                fontSize: isMobile ? 11 : 12,
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionsList({bool isMobile = false}) {
    final missions = roadmapData?['missions'] as List?;
    if (missions == null) return const SizedBox.shrink();

    return ListView.builder(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      itemCount: missions.length,
      itemBuilder: (context, index) {
        final mission = missions[index];
        final isSelected = selectedMissionIndex == index;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedMissionIndex = index;
              print('Selected mission: ${index + 1}');
            });
            if (isMobile) {
              Navigator.pop(context);
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: EdgeInsets.all(isMobile ? 10 : 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF3B82F6).withOpacity(0.8)
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF3B82F6)
                    : Colors.white.withOpacity(0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mission ${mission['id'] ?? index + 1}',
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.white60,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  mission['title'] ?? 'Untitled Mission',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 13,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainContent({bool isMobile = false}) {
    final missions = roadmapData?['missions'] as List?;
    if (missions == null || missions.isEmpty) {
      return const Center(
        child: Text(
          'No missions available',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    if (selectedMissionIndex >= missions.length) {
      selectedMissionIndex = 0;
    }

    final selectedMission = missions[selectedMissionIndex];

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile) _buildMobileMissionSelector(missions),
          _buildMissionHeader(selectedMission, isMobile),
          const SizedBox(height: 24),
          _buildCyclesList(selectedMission, isMobile),
          const SizedBox(height: 24),
          _buildDeliverables(selectedMission, isMobile),
        ],
      ),
    );
  }

  Widget _buildMobileMissionSelector(List missions) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: selectedMissionIndex > 0
                ? () {
                    setState(() {
                      selectedMissionIndex--;
                    });
                  }
                : null,
            icon: Icon(
              Icons.arrow_back_ios,
              color: selectedMissionIndex > 0 ? Colors.white : Colors.white30,
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Mission ${selectedMissionIndex + 1} of ${missions.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: selectedMissionIndex < missions.length - 1
                ? () {
                    setState(() {
                      selectedMissionIndex++;
                    });
                  }
                : null,
            icon: Icon(
              Icons.arrow_forward_ios,
              color: selectedMissionIndex < missions.length - 1
                  ? Colors.white
                  : Colors.white30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionHeader(Map<String, dynamic> mission, bool isMobile) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 10 : 12,
                        vertical: isMobile ? 4 : 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Mission ${mission['id'] ?? ''}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobile ? 11 : 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                mission['title'] ?? 'Untitled Mission',
                style: TextStyle(
                  fontSize: isMobile ? 20 : 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                mission['theme'] ?? '',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCyclesList(Map<String, dynamic> mission, bool isMobile) {
    final cycles = mission['cycles'] as List?;
    if (cycles == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Learning Cycles',
          style: TextStyle(
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        ...cycles.map((cycle) => _buildCycleCard(cycle, isMobile)).toList(),
      ],
    );
  }

  Widget _buildCycleCard(Map<String, dynamic> cycle, bool isMobile) {
    final cycleKey = '${cycle['cycleNumber']}-${cycle['title']}';
    final isExpanded = expandedCycles.contains(cycleKey);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isExpanded) {
                        expandedCycles.remove(cycleKey);
                      } else {
                        expandedCycles.add(cycleKey);
                      }
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(isMobile ? 16 : 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cycle ${cycle['cycleNumber'] ?? ''}',
                                style: TextStyle(
                                  fontSize: isMobile ? 12 : 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white60,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                cycle['title'] ?? 'Untitled Cycle',
                                style: TextStyle(
                                  fontSize: isMobile ? 16 : 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.access_time,
                                      size: isMobile ? 14 : 16,
                                      color: Colors.white60),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${cycle['totalHours'] ?? 0} hours',
                                    style: TextStyle(
                                      fontSize: isMobile ? 12 : 14,
                                      color: Colors.white60,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Colors.white60,
                        ),
                      ],
                    ),
                  ),
                ),
                if (isExpanded) _buildTopicsList(cycle['topics'], isMobile),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopicsList(List? topics, bool isMobile) {
    if (topics == null) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.fromLTRB(
          isMobile ? 16 : 20, 0, isMobile ? 16 : 20, isMobile ? 16 : 20),
      child: Column(
        children: topics
            .map<Widget>((topic) => _buildTopicCard(topic, isMobile))
            .toList(),
      ),
    );
  }

  Widget _buildTopicCard(Map<String, dynamic> topic, bool isMobile) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  topic['name'] ?? 'Untitled Topic',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 6 : 8, vertical: isMobile ? 3 : 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${topic['hours'] ?? 0}h',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 11 : 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (topic['what'] != null)
            _buildTopicSection('What', topic['what'], isMobile),
          if (topic['why'] != null)
            _buildTopicSection('Why', topic['why'], isMobile),
          if (topic['how'] != null)
            _buildTopicSection('How', topic['how'], isMobile),
          if (topic['keyPoints'] != null)
            _buildKeyPoints(topic['keyPoints'], isMobile),
        ],
      ),
    );
  }

  Widget _buildTopicSection(String title, String content, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title:',
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              color: Colors.white70,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyPoints(List keyPoints, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Points:',
          style: TextStyle(
            fontSize: isMobile ? 12 : 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        ...keyPoints
            .map((point) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• ',
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 14,
                          color: const Color(0xFF3B82F6),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          point ?? '',
                          style: TextStyle(
                            fontSize: isMobile ? 12 : 14,
                            color: Colors.white70,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ],
    );
  }

  Widget _buildDeliverables(Map<String, dynamic> mission, bool isMobile) {
    final deliverables = mission['deliverables'] as List?;
    if (deliverables == null) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mission Deliverables',
                style: TextStyle(
                  fontSize: isMobile ? 18 : 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              ...deliverables
                  .map((deliverable) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: isMobile ? 18 : 20,
                              color: const Color(0xFF10B981),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                deliverable ?? '',
                                style: TextStyle(
                                  fontSize: isMobile ? 14 : 16,
                                  color: Colors.white,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ],
          ),
        ),
      ),
    );
  }
}
