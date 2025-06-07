import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/celestial_event.dart';
import '../services/astrology_calendar_service.dart';
import '../services/notification_service.dart';
import 'package:intl/intl.dart';

class AstrologyCalendarScreen extends StatefulWidget {
  const AstrologyCalendarScreen({super.key});
  @override
  State<AstrologyCalendarScreen> createState() =>
      _AstrologyCalendarScreenState();
}

class _AstrologyCalendarScreenState extends State<AstrologyCalendarScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  List<CelestialEvent> _allEvents = [];
  List<CelestialEvent> _upcomingEvents = [];
  List<CelestialEvent> _selectedDayEvents = [];
  List<CelestialEvent> _filteredEvents = [];

  bool _isLoading = true;
  String _selectedFilter = 'all';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadEvents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);

    try {
      final allEvents = await AstrologyCalendarService.getAllEvents();
      final upcomingEvents = await AstrologyCalendarService.getUpcomingEvents();
      final selectedDayEvents = await AstrologyCalendarService.getEventsInRange(
        _selectedDay,
        _selectedDay.add(const Duration(days: 1)),
      );

      setState(() {
        _allEvents = allEvents;
        _upcomingEvents = upcomingEvents;
        _selectedDayEvents = selectedDayEvents;
        _filteredEvents = allEvents;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Etkinlikler yüklenirken hata oluştu: $e')),
      );
    }
  }

  Future<void> _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    final dayEvents = await AstrologyCalendarService.getEventsInRange(
      selectedDay,
      selectedDay.add(const Duration(days: 1)),
    );

    setState(() {
      _selectedDayEvents = dayEvents;
    });
  }

  List<CelestialEvent> _getEventsForDay(DateTime day) {
    return _allEvents.where((event) {
      return event.dateTime.year == day.year &&
          event.dateTime.month == day.month &&
          event.dateTime.day == day.day;
    }).toList();
  }

  void _filterEvents(String filter) {
    setState(() {
      _selectedFilter = filter;
      if (filter == 'all') {
        _filteredEvents = _allEvents;
      } else {
        _filteredEvents =
            _allEvents.where((event) => event.type == filter).toList();
      }
    });
  }

  void _searchEvents(String query) {
    if (query.isEmpty) {
      _filterEvents(_selectedFilter);
      return;
    }

    setState(() {
      _filteredEvents = _allEvents.where((event) {
        return event.title.toLowerCase().contains(query.toLowerCase()) ||
            event.description.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Astroloji Takvimi')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Astroloji Takvimi'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.calendar_month), text: 'Takvim'),
            Tab(icon: Icon(Icons.upcoming), text: 'Yaklaşan'),
            Tab(icon: Icon(Icons.search), text: 'Ara'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCalendarView(),
          _buildUpcomingView(),
          _buildSearchView(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('addEventButton'),
        onPressed: () => _showAddEventDialog(),
        tooltip: 'Etkinlik Ekle',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCalendarView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Date range selection button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              key: const Key('dateRangeButton'),
              icon: const Icon(Icons.date_range),
              label: const Text('Tarih Aralığı Seç'),
              onPressed: () => _showDateRangePicker(),
            ),
          ),
          TableCalendar<CelestialEvent>(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: _getEventsForDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            locale: 'tr_TR',
            headerStyle: HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              formatButtonShowsNext: false,
              formatButtonDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(12.0),
              ),
              formatButtonTextStyle: const TextStyle(color: Colors.white),
            ),
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              markersMaxCount: 3,
              markerDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              todayDecoration: const BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
            ),
            onDaySelected: _onDaySelected,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          const Divider(),
          SizedBox(
            height: 300, // Fixed height for the events list
            child: _selectedDayEvents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.event_busy,
                            size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'Seçilen günde etkinlik yok',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _selectedDayEvents.length,
                    itemBuilder: (context, index) {
                      return _buildEventCard(_selectedDayEvents[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.upcoming, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                'Önümüzdeki 30 Gün',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
        Expanded(
          child: _upcomingEvents.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.event_available,
                          size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'Yaklaşan etkinlik yok',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: _upcomingEvents.length,
                  itemBuilder: (context, index) {
                    return _buildEventCard(_upcomingEvents[index],
                        showDate: true);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSearchView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Etkinlik ara...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: _searchEvents,
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('all', 'Tümü'),
                    _buildFilterChip('new_moon', 'Yeni Ay'),
                    _buildFilterChip('full_moon', 'Dolunay'),
                    _buildFilterChip('eclipse', 'Tutulma'),
                    _buildFilterChip('retrograde', 'Retro'),
                    _buildFilterChip('ingress', 'Geçiş'),
                    _buildFilterChip('aspect', 'Açı'),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _filteredEvents.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off,
                          size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'Sonuç bulunamadı',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: _filteredEvents.length,
                  itemBuilder: (context, index) {
                    return _buildEventCard(_filteredEvents[index],
                        showDate: true);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String value, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: _selectedFilter == value,
        onSelected: (selected) {
          if (selected) _filterEvents(value);
        },
      ),
    );
  }

  Widget _buildEventCard(CelestialEvent event, {bool showDate = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () => _showEventDetails(event),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: event.getEventColor(),
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                    ),
                    child: Text(
                      event.getEventIcon(),
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (event.planetInvolved != null)
                              Text(
                                event.getPlanetEmoji(),
                                style: const TextStyle(fontSize: 16),
                              ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                event.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (event.isImportant)
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 20),
                          ],
                        ),
                        if (showDate)
                          Text(
                            DateFormat('d MMMM yyyy, HH:mm', 'tr_TR')
                                .format(event.dateTime),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                event.description,
                style: TextStyle(color: Colors.grey[700]),
              ),
              if (event.impactDescription != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: event.getEventColor().withOpacity(0.1),
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 16,
                        color: event.getEventColor(),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          event.impactDescription!,
                          style: TextStyle(
                            fontSize: 12,
                            color: event.getEventColor().withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showEventDetails(CelestialEvent event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(event.getEventIcon(), style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Expanded(child: Text(event.title)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.schedule, size: 16),
                const SizedBox(width: 8),
                Text(
                  DateFormat('d MMMM yyyy, HH:mm', 'tr_TR')
                      .format(event.dateTime),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(event.description),
            if (event.planetInvolved != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Gezegen: '),
                  Text(
                    '${event.getPlanetEmoji()} ${event.planetInvolved}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
            if (event.signInvolved != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Burç: '),
                  Text(
                    event.signInvolved!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
            if (event.impactDescription != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: event.getEventColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: 16,
                          color: event.getEventColor(),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Etki',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: event.getEventColor(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(event.impactDescription!),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
          if (event.dateTime.isAfter(DateTime.now()))
            ElevatedButton(
              onPressed: () => _scheduleNotification(event),
              child: const Text('Hatırlat'),
            ),
        ],
      ),
    );
  }

  Future<void> _scheduleNotification(CelestialEvent event) async {
    try {
      // Schedule notification 1 day before the event
      final notificationTime = event.dateTime.subtract(const Duration(days: 1));

      if (notificationTime.isAfter(DateTime.now())) {
        await NotificationService.scheduleCelestialEvent(
          title: '${event.getEventIcon()} ${event.title}',
          description: 'Yarın: ${event.description}',
          eventTime: notificationTime,
        );
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Etkinlik için hatırlatıcı ayarlandı!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Bu etkinlik için hatırlatıcı ayarlanamaz (çok yakın)'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hatırlatıcı ayarlanırken hata oluştu'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(
        start: DateTime.now(),
        end: DateTime.now().add(const Duration(days: 7)),
      ),
    );

    if (picked != null) {
      final events = await AstrologyCalendarService.getEventsInRange(
        picked.start,
        picked.end,
      );
      setState(() {
        _filteredEvents = events;
      });
    }
  }

  Future<void> _showAddEventDialog() async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Etkinlik Ekle'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                key: const Key('eventTitleField'),
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Etkinlik Başlığı',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Başlık gereklidir';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Açıklama',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Tarih'),
                subtitle: Text(DateFormat('d MMMM yyyy').format(selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    selectedDate = picked;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            key: const Key('saveEventButton'),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final event = CelestialEvent(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text.trim(),
                  description: descriptionController.text.trim(),
                  dateTime: selectedDate,
                  type: 'custom',
                  isImportant: false,
                  impactDescription: null,
                );
                await AstrologyCalendarService.addCustomEvent(event);
                await _loadEvents();
                if (!mounted) return;
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Etkinlik başarıyla eklendi!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }
}
