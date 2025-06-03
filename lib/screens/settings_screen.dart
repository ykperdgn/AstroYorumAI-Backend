import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/cloud_sync_service.dart';
import '../services/localization_service.dart';
import 'auth_screen.dart';
import 'package:intl/intl.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = false;
  DateTime? _lastSyncTime;
  String _selectedLanguage = 'tr';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  Future<void> _loadSettings() async {
    final lastSync = await CloudSyncService.instance.getLastSyncTime();
    final currentLocale = await LocalizationService.getCurrentLocale();
    
    setState(() {
      _lastSyncTime = lastSync;
      _selectedLanguage = currentLocale.languageCode;
    });
  }
  Future<void> _signIn() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AuthScreen()),
    );
    
    if (result == true) {
      setState(() {});
      _loadSettings();
    }
  }

  Future<void> _signOut() async {    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Hesabınızdan çıkış yapmak istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Çıkış Yap'),
          ),
        ],
      ),
    );    if (confirmed == true) {
      try {
        await AuthService.instance.signOut();
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Başarıyla çıkış yapıldı'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Çıkış yapılırken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _syncToCloud() async {
    setState(() {
      _isLoading = true;
    });    try {
      await CloudSyncService.instance.syncToCloud();
      await _loadSettings();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veriler buluta yedeklendi'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Yedekleme başarısız: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _syncFromCloud() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Veriyi Geri Yükle'),
        content: Text('Buluttaki veriler mevcut verilerin üzerine yazılacak. Devam etmek istiyor musunuz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: Text('Geri Yükle'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {      await CloudSyncService.instance.syncFromCloud();
      await _loadSettings();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veriler buluttan geri yüklendi'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Geri yükleme başarısız: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _changeLanguage() async {
    final languages = LocalizationService.getAvailableLanguages();
    
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Dil Seçin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.entries.map((entry) {
            return RadioListTile<String>(
              title: Text(entry.value),
              value: entry.key,
              groupValue: _selectedLanguage,
              onChanged: (value) {
                Navigator.of(context).pop(value);
              },
            );
          }).toList(),
        ),
      ),
    );

    if (selected != null && selected != _selectedLanguage) {
      await LocalizationService.setLocale(selected);
      setState(() {
        _selectedLanguage = selected;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dil değiştirildi. Uygulamayı yeniden başlatın.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override  Widget build(BuildContext context) {
    final isSignedIn = AuthService.instance.isSignedIn;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Ayarlar'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Language Settings
          Card(
            child: ListTile(
              leading: Icon(Icons.language, color: Colors.deepPurple),
              title: Text('Dil'),
              subtitle: Text(LocalizationService.getLanguageName(_selectedLanguage)),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: _changeLanguage,
            ),
          ),
          
          SizedBox(height: 16),
          
          // Cloud Sync Section
          Text(
            'Bulut Senkronizasyonu',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 8),
          
          if (!isSignedIn) ...[
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.cloud_off, color: Colors.grey),
                        SizedBox(width: 8),
                        Text('Giriş Yapılmamış'),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Verilerinizi bulutta saklamak ve cihazlar arası senkronize etmek için giriş yapın.',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.login),
                        label: Text('Giriş Yap'),
                        onPressed: _signIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.cloud_done, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Giriş Yapıldı'),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text('E-posta: ${AuthService.instance.currentUser?.email}'),
                    if (_lastSyncTime != null) ...[
                      SizedBox(height: 4),
                      Text(
                        'Son senkronizasyon: ${DateFormat('dd.MM.yyyy HH:mm').format(_lastSyncTime!)}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.cloud_upload),
                            label: Text('Yedekle'),
                            onPressed: _isLoading ? null : _syncToCloud,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.cloud_download),
                            label: Text('Geri Yükle'),
                            onPressed: _isLoading ? null : _syncFromCloud,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: Icon(Icons.logout),
                        label: Text('Çıkış Yap'),
                        onPressed: _signOut,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          
          if (_isLoading) ...[
            SizedBox(height: 16),
            Center(child: CircularProgressIndicator()),
          ],
          
          SizedBox(height: 24),
          
          // Info Section
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Bulut Senkronizasyonu',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Verileriniz güvenli Firebase sunucularında saklanır\n'
                    '• Otomatik yedekleme günde bir kez yapılır\n'
                    '• Cihaz değiştirdiğinizde verileriniz kaybolmaz\n'
                    '• İstediğiniz zaman manual yedekleme yapabilirsiniz',
                    style: TextStyle(color: Colors.blue.shade700),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
