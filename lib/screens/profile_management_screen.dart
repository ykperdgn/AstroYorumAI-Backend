import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user_profile.dart';
import '../services/profile_management_service.dart';
import '../screens/birth_info_screen.dart';
import '../screens/natal_chart_screen.dart';

class ProfileManagementScreen extends StatefulWidget {
  const ProfileManagementScreen({super.key});
  @override
  State<ProfileManagementScreen> createState() =>
      _ProfileManagementScreenState();
}

class _ProfileManagementScreenState extends State<ProfileManagementScreen> {
  List<UserProfile> _profiles = [];
  UserProfile? _activeProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final service = await ProfileManagementService.getInstance();
      final profiles = await service.getAllProfiles();
      final activeProfile = await service.getActiveProfile();

      setState(() {
        _profiles = profiles;
        _activeProfile = activeProfile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profiller yüklenirken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteProfile(UserProfile profile) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profili Sil'),
        content: Text(
            '${profile.name} profilini silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final service = await ProfileManagementService.getInstance();
      final success = await service.deleteProfile(profile.id);
      if (success) {
        _loadProfiles();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${profile.name} profili silindi.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil silinirken hata oluştu.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _setActiveProfile(UserProfile profile) async {
    final service = await ProfileManagementService.getInstance();
    final success = await service.setActiveProfile(profile.id);
    if (success) {
      _loadProfiles();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${profile.name} aktif profil olarak ayarlandı.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil ayarlanırken hata oluştu.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addNewProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BirthInfoScreen(
          onComplete: (birthInfo) async {
            final service = await ProfileManagementService.getInstance();
            final profile = await service.importFromBirthInfo(
              name: birthInfo.name ?? 'Yeni Profil',
              birthDate: birthInfo.birthDate ?? DateTime.now(),
              birthTime: birthInfo.birthTime,
              birthPlace: birthInfo.birthPlace,
              latitude: birthInfo.latitude,
              longitude: birthInfo.longitude,
            );

            if (profile != null && mounted) {
              _loadProfiles();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${profile.name} profili oluşturuldu.'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  void _viewNatalChart(UserProfile profile) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NatalChartScreen(
          name: profile.name,
          birthDate: profile.birthDate,
          birthTime: profile.birthTime,
          birthPlace: profile.birthPlace,
          latitude: profile.latitude,
          longitude: profile.longitude,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Yönetimi'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _profiles.isEmpty
              ? _buildEmptyState()
              : _buildProfileList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewProfile,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz profil oluşturmadınız',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'İlk profilinizi oluşturmak için + butonuna tıklayın',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('İlk Profili Oluştur'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: _addNewProfile,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileList() {
    return RefreshIndicator(
      onRefresh: _loadProfiles,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _profiles.length,
        itemBuilder: (context, index) {
          final profile = _profiles[index];
          final isActive = _activeProfile?.id == profile.id;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: isActive ? 6 : 2,
            child: Container(
              decoration: isActive
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.deepPurple, width: 2),
                    )
                  : null,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      isActive ? Colors.deepPurple : Colors.grey[300],
                  child: Icon(
                    Icons.person,
                    color: isActive ? Colors.white : Colors.grey[600],
                  ),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        profile.name,
                        style: TextStyle(
                          fontWeight:
                              isActive ? FontWeight.bold : FontWeight.normal,
                          color: isActive ? Colors.deepPurple : null,
                        ),
                      ),
                    ),
                    if (isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'AKTİF',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Doğum: ${DateFormat('dd.MM.yyyy').format(profile.birthDate)}'),
                    if (profile.birthPlace != null)
                      Text('Yer: ${profile.birthPlace}'),
                    if (profile.birthTime != null)
                      Text('Saat: ${profile.birthTime}'),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'activate':
                        if (!isActive) _setActiveProfile(profile);
                        break;
                      case 'view':
                        _viewNatalChart(profile);
                        break;
                      case 'delete':
                        _deleteProfile(profile);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    if (!isActive)
                      const PopupMenuItem(
                        value: 'activate',
                        child: ListTile(
                          leading: Icon(Icons.radio_button_checked),
                          title: Text('Aktif Yap'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'view',
                      child: ListTile(
                        leading: Icon(Icons.visibility),
                        title: Text('Doğum Haritası'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete, color: Colors.red[600]),
                        title: Text('Sil',
                            style: TextStyle(color: Colors.red[600])),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
                onTap: () => _viewNatalChart(profile),
              ),
            ),
          );
        },
      ),
    );
  }
}
