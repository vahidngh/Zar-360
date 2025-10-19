import 'package:flutter/material.dart';

class InputsPage extends StatefulWidget {
  const InputsPage({super.key});

  @override
  State<InputsPage> createState() => _InputsPageState();
}

class _InputsPageState extends State<InputsPage> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  String _selectedGender = '';
  String _selectedCity = '';
  double _sliderValue = 50.0;
  bool _switchValue = false;
  List<String> _selectedHobbies = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ورودی‌ها'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text Fields
            _buildSectionTitle('فیلدهای متنی'),
            const SizedBox(height: 16),
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _textController,
                    style: const TextStyle(
                      fontFamily: 'Iranyekan',
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      labelText: 'نام کامل',
                      hintText: 'نام و نام خانوادگی خود را وارد کنید',
                      prefixIcon: const Icon(Icons.person, color: Color(0xFF6B7280)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      labelStyle: const TextStyle(
                        fontFamily: 'Iranyekan',
                        color: Color(0xFF6B7280),
                      ),
                      hintStyle: const TextStyle(
                        fontFamily: 'Iranyekan',
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(
                      fontFamily: 'Iranyekan',
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      labelText: 'ایمیل',
                      hintText: 'مثال@ایمیل.کام',
                      prefixIcon: const Icon(Icons.email, color: Color(0xFF6B7280)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      labelStyle: const TextStyle(
                        fontFamily: 'Iranyekan',
                        color: Color(0xFF6B7280),
                      ),
                      hintStyle: const TextStyle(
                        fontFamily: 'Iranyekan',
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    style: const TextStyle(
                      fontFamily: 'Iranyekan',
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      labelText: 'رمز عبور',
                      hintText: 'رمز عبور خود را وارد کنید',
                      prefixIcon: const Icon(Icons.lock, color: Color(0xFF6B7280)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: const Color(0xFF6B7280),
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      labelStyle: const TextStyle(
                        fontFamily: 'Iranyekan',
                        color: Color(0xFF6B7280),
                      ),
                      hintStyle: const TextStyle(
                        fontFamily: 'Iranyekan',
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(
                      fontFamily: 'Iranyekan',
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      labelText: 'شماره تلفن',
                      hintText: '09123456789',
                      prefixIcon: const Icon(Icons.phone, color: Color(0xFF6B7280)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      labelStyle: const TextStyle(
                        fontFamily: 'Iranyekan',
                        color: Color(0xFF6B7280),
                      ),
                      hintStyle: const TextStyle(
                        fontFamily: 'Iranyekan',
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Modern Checkboxes
            _buildSectionTitle('چک باکس‌های مدرن'),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildModernCheckbox(
                    'مرا به خاطر بسپار',
                    _rememberMe,
                    (value) {
                      setState(() {
                        _rememberMe = value ?? false;
                      });
                    },
                  ),
                  const Divider(height: 1),
                  _buildModernCheckbox(
                    'قوانین و مقررات را می‌پذیرم',
                    false,
                    (value) {},
                    subtitle: 'برای ادامه باید قوانین را بپذیرید',
                  ),
                  const Divider(height: 1),
                  _buildModernCheckbox(
                    'اعلان‌ها را دریافت کنم',
                    true,
                    (value) {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Modern Radio Buttons
            _buildSectionTitle('رادیو باتن‌های مدرن'),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildModernRadio('مرد', 'مرد'),
                  const Divider(height: 1),
                  _buildModernRadio('زن', 'زن'),
                  const Divider(height: 1),
                  _buildModernRadio('سایر', 'سایر'),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Modern Dropdown
            _buildSectionTitle('لیست کشویی مدرن'),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedCity.isEmpty ? null : _selectedCity,
                style: const TextStyle(
                  fontFamily: 'Iranyekan',
                  fontSize: 16,
                  color: Color(0xFF111827),
                ),
                decoration: InputDecoration(
                  labelText: 'شهر',
                  prefixIcon: const Icon(Icons.location_city, color: Color(0xFF6B7280)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  labelStyle: const TextStyle(
                    fontFamily: 'Iranyekan',
                    color: Color(0xFF6B7280),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'تهران',
                    child: Text(
                      'تهران',
                      style: TextStyle(
                        fontFamily: 'Iranyekan',
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'مشهد',
                    child: Text(
                      'مشهد',
                      style: TextStyle(
                        fontFamily: 'Iranyekan',
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'اصفهان',
                    child: Text(
                      'اصفهان',
                      style: TextStyle(
                        fontFamily: 'Iranyekan',
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'شیراز',
                    child: Text(
                      'شیراز',
                      style: TextStyle(
                        fontFamily: 'Iranyekan',
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'تبریز',
                    child: Text(
                      'تبریز',
                      style: TextStyle(
                        fontFamily: 'Iranyekan',
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCity = value ?? '';
                  });
                },
              ),
            ),

            const SizedBox(height: 32),

            // Slider
            _buildSectionTitle('اسلایدر'),
            const SizedBox(height: 16),
            Column(
              children: [
                Text('مقدار: ${_sliderValue.round()}'),
                Slider(
                  value: _sliderValue,
                  min: 0,
                  max: 100,
                  divisions: 10,
                  label: _sliderValue.round().toString(),
                  onChanged: (value) {
                    setState(() {
                      _sliderValue = value;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Switch
            _buildSectionTitle('سوئیچ'),
            const SizedBox(height: 16),
            Column(
              children: [
                SwitchListTile(
                  title: const Text('اعلان‌ها'),
                  subtitle: const Text('دریافت اعلان‌های جدید'),
                  value: _switchValue,
                  onChanged: (value) {
                    setState(() {
                      _switchValue = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('حالت شب'),
                  subtitle: const Text('استفاده از تم تاریک'),
                  value: false,
                  onChanged: (value) {},
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Multi-select Checkboxes
            _buildSectionTitle('انتخاب چندگانه'),
            const SizedBox(height: 16),
            Column(
              children: [
                CheckboxListTile(
                  title: const Text('ورزش'),
                  value: _selectedHobbies.contains('ورزش'),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedHobbies.add('ورزش');
                      } else {
                        _selectedHobbies.remove('ورزش');
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('موسیقی'),
                  value: _selectedHobbies.contains('موسیقی'),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedHobbies.add('موسیقی');
                      } else {
                        _selectedHobbies.remove('موسیقی');
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('کتاب خوانی'),
                  value: _selectedHobbies.contains('کتاب خوانی'),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedHobbies.add('کتاب خوانی');
                      } else {
                        _selectedHobbies.remove('کتاب خوانی');
                      }
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Modern Date Picker
            _buildSectionTitle('انتخاب تاریخ'),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2030),
                  );
                  if (date != null) {
                    // Handle selected date
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.transparent),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.calendar_today, color: Color(0xFF6B7280)),
                      SizedBox(width: 12),
                      Text(
                        'انتخاب تاریخ تولد',
                        style: TextStyle(
                          fontFamily: 'Iranyekan',
                          fontSize: 16,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                      Spacer(),
                      Icon(Icons.arrow_drop_down, color: Color(0xFF6B7280)),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Handle form submission
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('فرم با موفقیت ارسال شد'),
                    ),
                  );
                },
                child: const Text('ارسال فرم'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernRadio(String title, String value) {
    final isSelected = _selectedGender == value;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD4AF37) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFFD1D5DB),
            width: 2,
          ),
          shape: BoxShape.circle,
        ),
        child: isSelected
            ? const Icon(
                Icons.circle,
                color: Colors.white,
                size: 12,
              )
            : null,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Iranyekan',
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: Color(0xFF111827),
        ),
      ),
      onTap: () {
        setState(() {
          _selectedGender = value;
        });
      },
    );
  }

  Widget _buildModernCheckbox(String title, bool value, ValueChanged<bool?> onChanged, {String? subtitle}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: value ? const Color(0xFFD4AF37) : Colors.white,
          border: Border.all(
            color: value ? const Color(0xFFD4AF37) : const Color(0xFFD1D5DB),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: value
            ? const Icon(
                Icons.check,
                color: Colors.white,
                size: 16,
              )
            : null,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Iranyekan',
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: Color(0xFF111827),
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(
                fontFamily: 'Iranyekan',
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            )
          : null,
      onTap: () => onChanged(!value),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Iranyekan',
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF111827),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
