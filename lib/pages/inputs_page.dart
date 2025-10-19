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
                TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'رمز عبور',
                    hintText: 'رمز عبور خود را وارد کنید',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'شماره تلفن',
                    hintText: '09123456789',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Checkboxes
            _buildSectionTitle('چک باکس‌ها'),
            const SizedBox(height: 16),
            Column(
              children: [
                CheckboxListTile(
                  title: const Text('مرا به خاطر بسپار'),
                  value: _rememberMe,
                  onChanged: (value) {
                    setState(() {
                      _rememberMe = value ?? false;
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('قوانین و مقررات را می‌پذیرم'),
                  subtitle: const Text('برای ادامه باید قوانین را بپذیرید'),
                  value: false,
                  onChanged: (value) {},
                ),
                CheckboxListTile(
                  title: const Text('اعلان‌ها را دریافت کنم'),
                  value: true,
                  onChanged: (value) {},
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Radio Buttons
            _buildSectionTitle('رادیو باتن‌ها'),
            const SizedBox(height: 16),
            Column(
              children: [
                RadioListTile<String>(
                  title: const Text('مرد'),
                  value: 'مرد',
                  groupValue: _selectedGender,
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value ?? '';
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text('زن'),
                  value: 'زن',
                  groupValue: _selectedGender,
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value ?? '';
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text('سایر'),
                  value: 'سایر',
                  groupValue: _selectedGender,
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value ?? '';
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Dropdown
            _buildSectionTitle('لیست کشویی'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCity.isEmpty ? null : _selectedCity,
              decoration: const InputDecoration(
                labelText: 'شهر',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_city),
              ),
              items: const [
                DropdownMenuItem(value: 'تهران', child: Text('تهران')),
                DropdownMenuItem(value: 'مشهد', child: Text('مشهد')),
                DropdownMenuItem(value: 'اصفهان', child: Text('اصفهان')),
                DropdownMenuItem(value: 'شیراز', child: Text('شیراز')),
                DropdownMenuItem(value: 'تبریز', child: Text('تبریز')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCity = value ?? '';
                });
              },
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

            // Date Picker
            _buildSectionTitle('انتخاب تاریخ'),
            const SizedBox(height: 16),
            InkWell(
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
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.calendar_today),
                    SizedBox(width: 12),
                    Text('انتخاب تاریخ تولد'),
                    Spacer(),
                    Icon(Icons.arrow_drop_down),
                  ],
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
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
