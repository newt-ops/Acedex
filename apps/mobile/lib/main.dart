import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/ui/ui.dart';

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
      scrollBehavior: const AcedexScrollBehavior(),
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
            AcedexCard(
              variant: AcedexCardVariant.flat,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TARGET BACKEND API',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkSubtext
                          : AppColors.lightSubtext,
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
            const SizedBox(height: 16),

            // Health Status Result Card
            AcedexCard(
              variant: AcedexCardVariant.flat,
              customBorderColor: _healthData != null
                  ? (dbConnected
                        ? successColor.withValues(alpha: 0.5)
                        : warningColor.withValues(alpha: 0.5))
                  : theme.colorScheme.outline,
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
                            horizontal: 10,
                            vertical: 4,
                          ),
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
                              color: dbConnected
                                  ? successColor
                                  : warningColor,
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
                        color: isDark
                            ? AppColors.darkSubtext
                            : AppColors.lightSubtext,
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Probe Button (AcedexButton)
            AcedexButton(
              label: _isLoading ? 'Probing...' : 'Re-probe Backend & Database',
              leadingIcon: const Icon(Icons.refresh_rounded),
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _checkBackendHealth,
            ),

            const SizedBox(height: 36),

            // --- Apple-Style Component Gallery Showcase ---
            Row(
              children: [
                Icon(
                  Icons.apple_rounded,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'APPLE UI COMPONENT SHOWCASE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Tactile Interactive Card Showcase
            AcedexCard(
              variant: AcedexCardVariant.raised,
              onTap: () {
                AcedexToast.show(
                  context,
                  title: 'Squircle Card',
                  message: 'Elastic spring depression scale 0.97 triggered!',
                  type: AcedexToastType.info,
                );
              },
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.touch_app_rounded,
                      color: theme.colorScheme.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Interactive Tactile Card',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Tap to feel spring haptics & trigger toast',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: theme.colorScheme.outline,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Button Variants Showcase
            Row(
              children: [
                Expanded(
                  child: AcedexButton(
                    label: 'Soft Accent',
                    variant: AcedexButtonVariant.soft,
                    size: AcedexButtonSize.md,
                    onPressed: () {
                      AcedexToast.show(
                        context,
                        title: 'Success Toast',
                        message: 'Dynamic island floating pill with spring bounce',
                        type: AcedexToastType.success,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AcedexButton(
                    label: 'Frosted Dialog',
                    variant: AcedexButtonVariant.surface,
                    size: AcedexButtonSize.md,
                    onPressed: () {
                      showAcedexDialog(
                        context,
                        title: 'Confirm Assessment',
                        message: 'Are you ready to submit your 15 questions for Grade 10 Physics?',
                        confirmLabel: 'Submit Now',
                        cancelLabel: 'Keep Reviewing',
                        onConfirm: () {
                          AcedexToast.show(
                            context,
                            message: 'Assessment submitted successfully!',
                            type: AcedexToastType.success,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: AcedexButton(
                    label: 'Bottom Sheet',
                    variant: AcedexButtonVariant.outline,
                    size: AcedexButtonSize.md,
                    onPressed: () {
                      showAcedexBottomSheet(
                        context,
                        title: 'Subject Curriculum Filter',
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Smooth spring drag-to-dismiss presentation with Gaussian backdrop blur.'),
                              const SizedBox(height: 20),
                              AcedexButton(
                                label: 'Done',
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AcedexButton(
                    label: 'Destructive',
                    variant: AcedexButtonVariant.destructive,
                    size: AcedexButtonSize.md,
                    onPressed: () {
                      AcedexToast.show(
                        context,
                        title: 'Error Notification',
                        message: 'Network connection interrupted',
                        type: AcedexToastType.error,
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Badges & Progress Showcase
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                const AcedexBadge(label: 'Grade 10', variant: AcedexBadgeVariant.primary),
                const AcedexBadge(label: 'Natural Science', variant: AcedexBadgeVariant.success),
                const AcedexBadge(label: '15 Questions', variant: AcedexBadgeVariant.neutral),
                const AcedexBadge(label: 'High Score', variant: AcedexBadgeVariant.warning),
              ],
            ),
            const SizedBox(height: 18),

            // Progress bar
            const Text(
              'Study Completion Progress (82%)',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const AcedexProgressBar(progress: 0.82, height: 9),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(
    BuildContext context,
    String label,
    String value,
    Color valueColor,
  ) {
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
