import 'package:flutter/material.dart';

class ThemeScreen extends StatefulWidget {
  const ThemeScreen({super.key});

  @override
  State<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  bool _isDarkMode = false;
  int _selectedColorScheme = 0;
  double _fontSize = 14.0;
  bool _useCustomFonts = false;
  bool _showAnimations = true;

  final List<Map<String, dynamic>> _colorSchemes = [
    {
      'name': 'Ocean Blue',
      'primary': const Color(0xFF667EEA),
      'secondary': const Color(0xFF764BA2),
      'accent': const Color(0xFF4CAF50),
    },
    {
      'name': 'Sunset Orange',
      'primary': const Color(0xFFFF6B6B),
      'secondary': const Color(0xFFFFE66D),
      'accent': const Color(0xFF4ECDC4),
    },
    {
      'name': 'Forest Green',
      'primary': const Color(0xFF2ECC71),
      'secondary': const Color(0xFF27AE60),
      'accent': const Color(0xFFF39C12),
    },
    {
      'name': 'Royal Purple',
      'primary': const Color(0xFF9B59B6),
      'secondary': const Color(0xFF8E44AD),
      'accent': const Color(0xFFE74C3C),
    },
    {
      'name': 'Midnight Dark',
      'primary': const Color(0xFF2C3E50),
      'secondary': const Color(0xFF34495E),
      'accent': const Color(0xFF3498DB),
    },
    {
      'name': 'Coral Pink',
      'primary': const Color(0xFFE91E63),
      'secondary': const Color(0xFFAD1457),
      'accent': const Color(0xFF00BCD4),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          _isDarkMode ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Theme & Customization',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: _colorSchemes[_selectedColorScheme]['primary'],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _saveTheme(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPreviewCard(),
            const SizedBox(height: 30),
            _buildColorSchemes(),
            const SizedBox(height: 30),
            _buildDarkModeToggle(),
            const SizedBox(height: 30),
            _buildTypographySettings(),
            const SizedBox(height: 30),
            _buildAnimationSettings(),
            const SizedBox(height: 30),
            _buildCustomWidgets(),
            const SizedBox(height: 30),
            _buildAdvancedSettings(),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard() {
    final scheme = _colorSchemes[_selectedColorScheme];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scheme['primary'], scheme['secondary']],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: scheme['primary'].withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.palette,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Theme Preview',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildPreviewStat(
                  'Primary',
                  scheme['primary'],
                ),
              ),
              Expanded(
                child: _buildPreviewStat(
                  'Secondary',
                  scheme['secondary'],
                ),
              ),
              Expanded(
                child: _buildPreviewStat(
                  'Accent',
                  scheme['accent'],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewStat(String label, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildColorSchemes() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Color Schemes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2.0,
            ),
            itemCount: _colorSchemes.length,
            itemBuilder: (context, index) {
              final scheme = _colorSchemes[index];
              final isSelected = index == _selectedColorScheme;

              return _buildColorSchemeCard(scheme, index, isSelected);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildColorSchemeCard(
      Map<String, dynamic> scheme, int index, bool isSelected) {
    return InkWell(
      onTap: () => setState(() => _selectedColorScheme = index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: _isDarkMode ? const Color(0xFF2A2A2A) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? scheme['primary'] : Colors.grey[300]!,
            width: isSelected ? 3 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 20,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [scheme['primary'], scheme['secondary']],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              scheme['name'],
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: scheme['primary'],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: scheme['secondary'],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: scheme['accent'],
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDarkModeToggle() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Appearance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: Text(
              'Dark Mode',
              style: TextStyle(
                color: _isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            subtitle: Text(
              'Switch between light and dark themes',
              style: TextStyle(
                color: _isDarkMode ? Colors.white70 : Colors.grey[600],
              ),
            ),
            value: _isDarkMode,
            onChanged: (value) => setState(() => _isDarkMode = value),
            secondary: Icon(
              _isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: _colorSchemes[_selectedColorScheme]['primary'],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypographySettings() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Typography',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Font Size',
            style: TextStyle(
              fontSize: 14,
              color: _isDarkMode ? Colors.white70 : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: _fontSize,
            min: 12.0,
            max: 20.0,
            divisions: 8,
            activeColor: _colorSchemes[_selectedColorScheme]['primary'],
            onChanged: (value) => setState(() => _fontSize = value),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Small',
                style: TextStyle(
                  fontSize: 12,
                  color: _isDarkMode ? Colors.white70 : Colors.grey[600],
                ),
              ),
              Text(
                'Large',
                style: TextStyle(
                  fontSize: 16,
                  color: _isDarkMode ? Colors.white70 : Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: Text(
              'Custom Fonts',
              style: TextStyle(
                color: _isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            subtitle: Text(
              'Use custom font families',
              style: TextStyle(
                color: _isDarkMode ? Colors.white70 : Colors.grey[600],
              ),
            ),
            value: _useCustomFonts,
            onChanged: (value) => setState(() => _useCustomFonts = value),
            secondary: Icon(
              Icons.font_download,
              color: _colorSchemes[_selectedColorScheme]['primary'],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimationSettings() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Animations',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: Text(
              'Enable Animations',
              style: TextStyle(
                color: _isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            subtitle: Text(
              'Show smooth transitions and effects',
              style: TextStyle(
                color: _isDarkMode ? Colors.white70 : Colors.grey[600],
              ),
            ),
            value: _showAnimations,
            onChanged: (value) => setState(() => _showAnimations = value),
            secondary: Icon(
              Icons.animation,
              color: _colorSchemes[_selectedColorScheme]['primary'],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomWidgets() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Custom Widgets',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildWidgetOption(
            'Dashboard Layout',
            'Customize dashboard arrangement',
            Icons.dashboard,
          ),
          _buildWidgetOption(
            'Quick Actions',
            'Add custom quick action buttons',
            Icons.flash_on,
          ),
          _buildWidgetOption(
            'Notification Style',
            'Customize notification appearance',
            Icons.notifications,
          ),
        ],
      ),
    );
  }

  Widget _buildWidgetOption(String title, String subtitle, IconData icon) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: _isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: _isDarkMode ? Colors.white70 : Colors.grey[600],
        ),
      ),
      leading: Icon(
        icon,
        color: _colorSchemes[_selectedColorScheme]['primary'],
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: _isDarkMode ? Colors.white70 : Colors.grey[600],
      ),
      onTap: () => _showWidgetCustomization(title),
    );
  }

  Widget _buildAdvancedSettings() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Advanced Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildAdvancedOption(
            'Export Theme',
            'Save your custom theme',
            Icons.upload,
            () => _exportTheme(),
          ),
          _buildAdvancedOption(
            'Import Theme',
            'Load a saved theme',
            Icons.download,
            () => _importTheme(),
          ),
          _buildAdvancedOption(
            'Reset to Default',
            'Restore original settings',
            Icons.restore,
            () => _resetTheme(),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedOption(
      String title, String subtitle, IconData icon, VoidCallback onTap) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: _isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: _isDarkMode ? Colors.white70 : Colors.grey[600],
        ),
      ),
      leading: Icon(
        icon,
        color: _colorSchemes[_selectedColorScheme]['primary'],
      ),
      onTap: onTap,
    );
  }

  void _showWidgetCustomization(String widgetName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Customize $widgetName'),
        content: Text('Widget customization coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _saveTheme() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Theme saved successfully!'),
        backgroundColor: _colorSchemes[_selectedColorScheme]['primary'],
      ),
    );
  }

  void _exportTheme() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Theme export coming soon!'),
        backgroundColor: Color(0xFF667EEA),
      ),
    );
  }

  void _importTheme() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Theme import coming soon!'),
        backgroundColor: Color(0xFF667EEA),
      ),
    );
  }

  void _resetTheme() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Theme'),
        content: const Text(
            'Are you sure you want to reset all theme settings to default?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedColorScheme = 0;
                _isDarkMode = false;
                _fontSize = 14.0;
                _useCustomFonts = false;
                _showAnimations = true;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Theme reset to default!'),
                  backgroundColor: Color(0xFF4CAF50),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
