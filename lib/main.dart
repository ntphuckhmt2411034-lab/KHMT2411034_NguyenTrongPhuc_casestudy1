import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// ======================================================
// APP
// ======================================================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Manager',
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1976D2),
        ),
      ),
      home: const WelcomePage(),
    );
  }
}

// ======================================================
// MODEL - EXPENSE
// ======================================================

class Expense {
  final String id;
  final String category;
  final double amount;
  final DateTime date;
  final String note;

  Expense({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    required this.note,
  });
}

// ======================================================
// BUỔI 2 - WELCOME PAGE
// ======================================================

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 3),

              // Logo
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 60,
                    margin: const EdgeInsets.only(
                      bottom: 20,
                      left: 20,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7BC47F),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),

                  Container(
                    width: 135,
                    height: 85,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1976D2),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.only(right: 0),
                        child: Icon(
                          Icons.circle,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              const Text(
                'Expense Manager',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF10213A),
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Quản lý chi tiêu cá nhân\nđơn giản và hiệu quả',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF718096),
                  height: 1.5,
                ),
              ),

              const Spacer(flex: 4),

              // Nút bắt đầu
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ExpenseHomePage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Bắt đầu',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }
}

// ======================================================
// MÀN HÌNH DANH SÁCH CHI TIÊU
// ======================================================

class ExpenseHomePage extends StatefulWidget {
  const ExpenseHomePage({super.key});

  @override
  State<ExpenseHomePage> createState() => _ExpenseHomePageState();
}

class _ExpenseHomePageState extends State<ExpenseHomePage> {
  // STATE
  final List<Expense> expenses = [];

  // Các danh mục
  final List<String> categories = [
    'Ăn uống',
    'Di chuyển',
    'Mua sắm',
    'Học tập',
    'Khác',
  ];

  // ----------------------------------------------------
  // MỞ FORM THÊM
  // ----------------------------------------------------

  void _addExpense() async {
    final expense = await Navigator.push<Expense>(
      context,
      MaterialPageRoute(
        builder: (context) => ExpenseFormPage(
          categories: categories,
        ),
      ),
    );

    if (expense != null) {
      setState(() {
        expenses.add(expense);
      });
    }
  }

  // ----------------------------------------------------
  // MỞ FORM SỬA
  // ----------------------------------------------------

  void _editExpense(int index) async {
    final updatedExpense = await Navigator.push<Expense>(
      context,
      MaterialPageRoute(
        builder: (context) => ExpenseFormPage(
          categories: categories,
          expense: expenses[index],
        ),
      ),
    );

    if (updatedExpense != null) {
      setState(() {
        expenses[index] = updatedExpense;
      });
    }
  }

  // ----------------------------------------------------
  // XÓA
  // ----------------------------------------------------

  void _deleteExpense(int index) {
    setState(() {
      expenses.removeAt(index);
    });
  }

  // ----------------------------------------------------
  // FORMAT TIỀN
  // ----------------------------------------------------

  String formatMoney(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => '.',
    )} đ';
  }

  // ----------------------------------------------------
  // FORMAT NGÀY
  // ----------------------------------------------------

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    double total = 0;

    for (final expense in expenses) {
      total += expense.amount;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Expense Manager',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF10213A),
        elevation: 0,
      ),

      // ==================================================
      // BODY
      // ==================================================

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tổng chi
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tổng chi tiêu',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF718096),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    formatMoney(total),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Danh sách khoản chi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF10213A),
              ),
            ),

            const SizedBox(height: 12),

            // ==================================================
            // LISTVIEW
            // ==================================================

            Expanded(
              child: expenses.isEmpty
                  ? const Center(
                child: Text(
                  'Chưa có khoản chi nào',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              )
                  : ListView.builder(
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  final expense = expenses[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 0,
                    color: const Color(0xFFF7F9FC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),

                      leading: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE5E7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.restaurant,
                          color: Color(0xFFFF5B64),
                        ),
                      ),

                      title: Text(
                        expense.category,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      subtitle: Text(
                        '${expense.note.isEmpty ? 'Không có ghi chú' : expense.note}\n'
                            '${formatDate(expense.date)}',
                      ),

                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            formatMoney(expense.amount),
                            style: const TextStyle(
                              color: Color(0xFFFF5B64),
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  _editExpense(index);
                                },
                                child: const Icon(
                                  Icons.edit,
                                  size: 18,
                                  color: Colors.blue,
                                ),
                              ),

                              const SizedBox(width: 12),

                              GestureDetector(
                                onTap: () {
                                  _deleteExpense(index);
                                },
                                child: const Icon(
                                  Icons.delete,
                                  size: 18,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // ==================================================
      // NÚT THÊM
      // ==================================================

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addExpense,
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Thêm khoản chi'),
      ),
    );
  }
}

// ======================================================
// FORM THÊM / SỬA GIAO DỊCH
// ======================================================

class ExpenseFormPage extends StatefulWidget {
  final List<String> categories;
  final Expense? expense;

  const ExpenseFormPage({
    super.key,
    required this.categories,
    this.expense,
  });

  @override
  State<ExpenseFormPage> createState() => _ExpenseFormPageState();
}

class _ExpenseFormPageState extends State<ExpenseFormPage> {
  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  // CONTROLLER
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  // STATE
  late String selectedCategory;
  late DateTime selectedDate;

  bool get isEditing => widget.expense != null;

  @override
  void initState() {
    super.initState();

    // Nếu sửa thì lấy dữ liệu cũ
    if (widget.expense != null) {
      selectedCategory = widget.expense!.category;
      selectedDate = widget.expense!.date;

      _amountController.text =
          widget.expense!.amount.toStringAsFixed(0);

      _noteController.text = widget.expense!.note;
    } else {
      // Nếu thêm mới
      selectedCategory = widget.categories.first;
      selectedDate = DateTime.now();
    }
  }

  // ==================================================
  // CHỌN NGÀY
  // ==================================================

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  // ==================================================
  // FORMAT NGÀY
  // ==================================================

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  // ==================================================
  // LƯU
  // ==================================================

  void _saveExpense() {
    // VALIDATE FORM
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount = double.tryParse(_amountController.text);

    if (amount == null || amount <= 0) {
      return;
    }

    // TẠO EXPENSE
    final expense = Expense(
      id: widget.expense?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      category: selectedCategory,
      amount: amount,
      date: selectedDate,
      note: _noteController.text,
    );

    // Trả dữ liệu về màn hình trước
    Navigator.pop(context, expense);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // ==================================================
  // UI
  // ==================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: Text(
          isEditing ? 'Sửa giao dịch' : 'Thêm giao dịch',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF10213A),
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================================================
              // CHI TIÊU / THU NHẬP
              // ==================================================

              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF5B64),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          'Chi tiêu',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          'Thu nhập',
                          style: TextStyle(
                            color: Color(0xFF10213A),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // ==================================================
              // DANH MỤC
              // ==================================================

              const Text(
                'Danh mục',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.restaurant,
                    color: Color(0xFFFF5B64),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                ),
                items: widget.categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedCategory = value;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng chọn danh mục';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              // ==================================================
              // SỐ TIỀN
              // ==================================================

              const Text(
                'Số tiền',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Nhập số tiền',
                  suffixText: 'đ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                // VALIDATOR
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số tiền';
                  }

                  final amount = double.tryParse(value);

                  if (amount == null || amount <= 0) {
                    return 'Số tiền không hợp lệ';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              // ==================================================
              // NGÀY GIAO DỊCH
              // ==================================================

              const Text(
                'Ngày giao dịch',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 8),

              GestureDetector(
                onTap: _selectDate,
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFDCE3EC),
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Text(
                        formatDate(selectedDate),
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),

                      const Spacer(),

                      const Icon(
                        Icons.calendar_month,
                        color: Color(0xFF718096),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // GHI CHÚ
              // ==================================================

              const Text(
                'Ghi chú',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: _noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Nhập ghi chú (tùy chọn)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ==================================================
              // NÚT LƯU
              // ==================================================

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _saveExpense,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Lưu',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}