import 'package:flutter/material.dart';
import '../services/astrology_calendar_service.dart';
import '../models/celestial_event.dart';
import 'package:intl/intl.dart';

class TransitScreen extends StatefulWidget {
  final DateTime? birthDate;
  final String? sunSign;

  const TransitScreen({
    super.key,
    this.birthDate,
    this.sunSign,
  });

  @override
  State<TransitScreen> createState() => _TransitScreenState();
}

class _TransitScreenState extends State<TransitScreen>
    with TickerProviderStateMixin {
  List<CelestialEvent> _events = [];
  bool _isLoading = true;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTransitData();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadTransitData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final events = await AstrologyCalendarService.getEventsInRange(
        DateTime(now.year, now.month, 1),
        DateTime(now.year, now.month + 3, 0), // Next 3 months
      );

      setState(() {
        _events = events;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transit Analizi'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.today), text: 'Bu Ay'),
            Tab(icon: Icon(Icons.calendar_month), text: 'Gelecek Ay'),
            Tab(icon: Icon(Icons.timeline), text: 'Önemli Geçişler'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCurrentMonthView(),
                _buildNextMonthView(),
                _buildImportantTransitsView(),
              ],
            ),
    );
  }

  Widget _buildCurrentMonthView() {
    final now = DateTime.now();
    final currentMonthEvents = _events
        .where((event) =>
            event.dateTime.month == now.month &&
            event.dateTime.year == now.year)
        .toList();

    if (currentMonthEvents.isEmpty) {
      return _buildEmptyState('Bu ay için özel transit yok');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: currentMonthEvents.length,
      itemBuilder: (context, index) {
        final event = currentMonthEvents[index];
        return _buildEventCard(event);
      },
    );
  }

  Widget _buildNextMonthView() {
    final nextMonth = DateTime.now().add(const Duration(days: 30));
    final nextMonthEvents = _events
        .where((event) =>
            event.dateTime.month == nextMonth.month &&
            event.dateTime.year == nextMonth.year)
        .toList();

    if (nextMonthEvents.isEmpty) {
      return _buildEmptyState('Gelecek ay için özel transit yok');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: nextMonthEvents.length,
      itemBuilder: (context, index) {
        final event = nextMonthEvents[index];
        return _buildEventCard(event);
      },
    );
  }

  Widget _buildImportantTransitsView() {
    final importantEvents =
        _events.where((event) => event.isImportant).toList();

    if (importantEvents.isEmpty) {
      return _buildEmptyState('Önemli transit bulunamadı');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: importantEvents.length,
      itemBuilder: (context, index) {
        final event = importantEvents[index];
        return _buildEventCard(event, isImportant: true);
      },
    );
  }

  Widget _buildEventCard(CelestialEvent event, {bool isImportant = false}) {
    return Card(
      elevation: isImportant ? 4 : 2,
      margin: const EdgeInsets.only(bottom: 12),
      color: isImportant ? Colors.deepPurple.shade50 : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getEventIcon(event.type),
                  color: isImportant ? Colors.deepPurple : Colors.grey[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    event.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          isImportant ? FontWeight.bold : FontWeight.w500,
                      color: isImportant ? Colors.deepPurple : null,
                    ),
                  ),
                ),
                if (isImportant)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'ÖNEMLİ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('dd MMMM yyyy', 'tr_TR').format(event.dateTime),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              event.description,
              style: const TextStyle(fontSize: 14),
            ),
            if (event.impactDescription != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Colors.blue.shade700, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        event.impactDescription!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (widget.sunSign != null &&
                _isRelevantForSign(event, widget.sunSign!)) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star, color: Colors.green.shade700, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      '${widget.sunSign} burcu için özel',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timeline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Yeni transitler için daha sonra tekrar kontrol edin.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getEventIcon(String type) {
    switch (type) {
      case 'new_moon':
        return Icons.brightness_2;
      case 'full_moon':
        return Icons.brightness_1;
      case 'retrograde':
        return Icons.refresh;
      case 'eclipse':
        return Icons.brightness_3;
      case 'ingress':
        return Icons.arrow_forward;
      case 'aspect':
        return Icons.timeline;
      default:
        return Icons.event;
    }
  }

  bool _isRelevantForSign(CelestialEvent event, String sunSign) {
    // Bu basit bir örnektir. Gerçek astroloji uygulamasında
    // daha karmaşık hesaplamalar gerekebilir
    if (event.signInvolved == sunSign) return true;
    if (event.planetInvolved == 'Sun') return true;
    return false;
  }
}
