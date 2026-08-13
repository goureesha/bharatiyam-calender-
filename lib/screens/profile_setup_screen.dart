/// Profile Setup Screen — Shown on first launch. User must fill name & mobile.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/profile_service.dart';
import '../widgets/common.dart';

class ProfileSetupScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const ProfileSetupScreen({super.key, required this.onComplete});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController(text: ProfileService.name);
  final _addressCtrl = TextEditingController(text: ProfileService.address);
  final _mobileCtrl = TextEditingController(text: ProfileService.mobile);
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _mobileCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await ProfileService.save(
      name: _nameCtrl.text,
      address: _addressCtrl.text,
      mobile: _mobileCtrl.text,
    );
    setState(() => _saving = false);
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo / Title
                  Text('✦', style: TextStyle(fontSize: 40, color: kGold)),
                  const SizedBox(height: 8),
                  Text('ಭಾರತೀಯಮ್ ಪಂಚಾಂಗ',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kGold)),
                  const SizedBox(height: 4),
                  Text('ನಿಮ್ಮ ಪ್ರೊಫೈಲ್ ಮಾಹಿತಿ ನಮೂದಿಸಿ',
                    style: TextStyle(fontSize: 13, color: kMuted)),
                  const SizedBox(height: 32),

                  // Name field
                  _buildField(
                    controller: _nameCtrl,
                    label: 'ಹೆಸರು / Name',
                    icon: Icons.person_rounded,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'ಹೆಸರು ಅಗತ್ಯ' : null,
                  ),
                  const SizedBox(height: 16),

                  // Address field
                  _buildField(
                    controller: _addressCtrl,
                    label: 'ವಿಳಾಸ / Address',
                    icon: Icons.location_on_rounded,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),

                  // Mobile field (optional)
                  _buildField(
                    controller: _mobileCtrl,
                    label: 'ಮೊಬೈಲ್ ನಂಬರ್ / Mobile (optional)',
                    icon: Icons.phone_rounded,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                  ),
                  const SizedBox(height: 32),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kGold,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _saving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('ಮುಂದುವರಿಸಿ / Continue',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      style: TextStyle(color: kText, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: kMuted),
        prefixIcon: Icon(icon, color: kGold, size: 20),
        filled: true,
        fillColor: kCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: kBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: kGold, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}
