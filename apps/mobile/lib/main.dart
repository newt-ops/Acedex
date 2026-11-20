import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';

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
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dbConnected = _healthData?['database']?['connected'] == true;
    final status = _healthData?['status']?.toString().toUpperCase() ?? 'UNKNOWN';

    final successColor = isDark ? AppColors.darkSuccess : AppColors.success;
    final warningColor = isDark ? AppColors.darkWarning : AppColors.warning;
    final errorColor = isDark ? AppColors.darkError : AppColors.error;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'ACEDEX',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: theme.colorScheme.onPrimary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Mobile Platform',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
              ),
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
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TARGET BACKEND API',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      defaultApiUrl,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Health Status Result Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: _healthData != null
                      ? (dbConnected ? successColor.withValues(alpha: 0.5) : warningColor.withValues(alpha: 0.5))
                      : theme.colorScheme.outline,
                  width: 1.2,
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
                        Text(
                          'System Health',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        if (_isLoading)
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.primary,
                            ),
                          )
                        else if (_healthData != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: dbConnected
                                  ? successColor.withValues(alpha: 0.15)
                                  : warningColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: dbConnected ? successColor : warningColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const Divider(height: 28),

                    if (_errorMessage != null)
                      Text(
                        'Error: $_errorMessage',
                        style: TextStyle(color: errorColor, fontSize: 13),
                      )
                    else if (_healthData != null) ...[
                      _buildMetricRow(
                        context,
                        'Database',
                        dbConnected
                            ? 'Connected (${_healthData!['database']?['name'] ?? 'acedex'})'
                            : 'Disconnected',
                        dbConnected ? successColor : errorColor,
                      ),
                      const SizedBox(height: 12),
                      _buildMetricRow(
                        context,
                        'Database Host',
                        _healthData!['database']?['host'] ?? 'N/A',
                        theme.colorScheme.onSurface,
                      ),
                      const SizedBox(height: 12),
                      _buildMetricRow(
                        context,
                        'Environment',
                        _healthData!['environment'] ?? 'N/A',
                        theme.colorScheme.onSurface,
                      ),
                      const SizedBox(height: 12),
                      _buildMetricRow(
                        context,
                        'Server Uptime',
                        '${_healthData!['uptimeSeconds'] ?? 0}s',
                        theme.colorScheme.onSurface,
                      ),
                      const SizedBox(height: 12),
                      _buildMetricRow(
                        context,
                        'API Version',
                        _healthData!['version'] ?? '1.4.0',
                        theme.colorScheme.onSurface,
                      ),
                    ] else
                      Text(
                        'Waiting for probe...',
                        style: TextStyle(
                          color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Probe Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _checkBackendHealth,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(_isLoading ? 'Probing...' : 'Re-probe Backend & Database'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(BuildContext context, String label, String value, Color valueColor) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
            fontSize: 13,
          ),
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
