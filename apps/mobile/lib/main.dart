import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const AcedexApp());
}

class AcedexApp extends StatelessWidget {
  const AcedexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Acedex',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3B82F6),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        useMaterial3: true,
      ),
      home: const BackendHealthCheckScreen(),
    );
  }
}

class BackendHealthCheckScreen extends StatefulWidget {
  const BackendHealthCheckScreen({super.key});

  @override
  State<BackendHealthCheckScreen> createState() =>
      _BackendHealthCheckScreenState();
}

class _BackendHealthCheckScreenState extends State<BackendHealthCheckScreen> {
  // Default to live production Render API
  static const String defaultApiUrl = 'https://acedex-api.onrender.com';

  bool _isLoading = false;
  Map<String, dynamic>? _healthData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkBackendHealth();
  }

  Future<void> _checkBackendHealth() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final uri = Uri.parse('$defaultApiUrl/health');
      final response = await http.get(uri).timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        setState(() {
          _healthData = decoded['data'] ?? decoded;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              'HTTP ${response.statusCode}: ${response.reasonPhrase}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dbConnected = _healthData?['database']?['connected'] == true;
    final status = _healthData?['status']?.toString().toUpperCase() ?? 'UNKNOWN';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'ACEDEX',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Mobile Client',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Target API Card
            Card(
              color: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFF334155)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Target Backend API',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      defaultApiUrl,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: Color(0xFF60A5FA),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Health Status Result Card
            Card(
              color: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: _healthData != null
                      ? (dbConnected
                          ? const Color(0xFF10B981)
                          : const Color(0xFFF59E0B))
                      : const Color(0xFF334155),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'System Status',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (_isLoading)
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF3B82F6),
                            ),
                          )
                        else if (_healthData != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: dbConnected
                                  ? const Color(0xFF10B981).withOpacity(0.2)
                                  : const Color(0xFFF59E0B).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: dbConnected
                                    ? const Color(0xFF34D399)
                                    : const Color(0xFFFBBF24),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const Divider(color: Color(0xFF334155), height: 30),

                    if (_errorMessage != null)
                      Text(
                        'Error: $_errorMessage',
                        style: const TextStyle(color: Color(0xFFF87171)),
                      )
                    else if (_healthData != null) ...[
                      _buildMetricRow(
                        'Database',
                        dbConnected
                            ? 'Connected (${_healthData!['database']?['name'] ?? 'acedex'})'
                            : 'Disconnected',
                        dbConnected
                            ? const Color(0xFF34D399)
                            : const Color(0xFFF87171),
                      ),
                      const SizedBox(height: 12),
                      _buildMetricRow(
                        'Database Host',
                        _healthData!['database']?['host'] ?? 'N/A',
                        Colors.white70,
                      ),
                      const SizedBox(height: 12),
                      _buildMetricRow(
                        'Environment',
                        _healthData!['environment'] ?? 'N/A',
                        Colors.white,
                      ),
                      const SizedBox(height: 12),
                      _buildMetricRow(
                        'Server Uptime',
                        '${_healthData!['uptimeSeconds'] ?? 0} seconds',
                        Colors.white,
                      ),
                      const SizedBox(height: 12),
                      _buildMetricRow(
                        'API Version',
                        _healthData!['version'] ?? '1.0.0',
                        Colors.white,
                      ),
                    ] else
                      const Text(
                        'Waiting for probe...',
                        style: TextStyle(color: Colors.grey),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Probe Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _checkBackendHealth,
              icon: const Icon(Icons.refresh),
              label: Text(_isLoading ? 'Probing...' : 'Re-probe Backend & Database'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
