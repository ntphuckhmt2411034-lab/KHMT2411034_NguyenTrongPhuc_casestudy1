import 'dart:math' as math;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'database/database_helper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ExpenseManagerApp());
}

class AppColors {
  static const blue = Color(0xFF1769E0);
  static const darkBlue = Color(0xFF0C55C6);
  static const background = Color(0xFFF6F8FC);
  static const ink = Color(0xFF172338);
  static const muted = Color(0xFF718096);
  static const line = Color(0xFFE8ECF2);
  static const income = Color(0xFF24B264);
  static const expense = Color(0xFFF34F5E);
}

class ExpenseManagerApp extends StatelessWidget {
  const ExpenseManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quản lý thu chi',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.blue),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.ink,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF8FAFD),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.line),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.line),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        ),
      ),
      home: const WelcomePage(),
    );
  }
}

String formatMoney(double amount) {
  final rounded = amount.round().abs().toString();
  final grouped = rounded.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => '.',
  );
  return '${amount < 0 ? '-' : ''}$grouped đ';
}

String formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}

class CategoryInfo {
  final IconData icon;
  final Color color;
  const CategoryInfo(this.icon, this.color);
}

const expenseCategories = <String>[
  'Ăn uống', 'Di chuyển', 'Mua sắm', 'Giáo dục', 'Giải trí', 'Khác',
];

CategoryInfo categoryInfo(String category, String type) {
  if (type == 'income') {
    return const CategoryInfo(Icons.account_balance_wallet, AppColors.income);
  }
  switch (category) {
    case 'Ăn uống':
      return const CategoryInfo(Icons.restaurant, Color(0xFFFF606A));
    case 'Di chuyển':
      return const CategoryInfo(Icons.directions_bus, Color(0xFF23B7EC));
    case 'Mua sắm':
      return const CategoryInfo(Icons.shopping_bag, Color(0xFF8B67F8));
    case 'Giáo dục':
      return const CategoryInfo(Icons.menu_book, Color(0xFF7964E6));
    case 'Giải trí':
      return const CategoryInfo(Icons.sports_esports, Color(0xFFF6A241));
    default:
      return const CategoryInfo(Icons.more_horiz, Color(0xFF7C90A5));
  }
}

class TransactionData {
  final int id;
  final String title;
  final String category;
  final DateTime date;
  final double amount;
  final String type;
  final String note;

  const TransactionData({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.amount,
    required this.type,
    this.note = '',
  });

  Map<String, Object?> toMap() => {
    'title': title,
    'category': category,
    'date': date.toIso8601String(),
    'amount': amount,
    'type': type,
    'note': note,
  };

  factory TransactionData.fromMap(Map<String, Object?> map) {
    return TransactionData(
      id: map['id'] as int,
      title: map['title'] as String,
      category: map['category'] as String,
      date: DateTime.parse(map['date'] as String),
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] as String,
      note: (map['note'] as String?) ?? '',
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(26, 18, 26, 22),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: math.max(0, constraints.maxHeight - 40),
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 9,
                            height: 9,
                            decoration: const BoxDecoration(
                              color: AppColors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'EXPENSE MANAGER',
                            style: TextStyle(
                              fontSize: 11,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkBlue,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(flex: 5),
                      Center(
                        child: SizedBox(
                          height: 190,
                          width: 235,
                          child: Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                height: 177,
                                width: 177,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFF0F6FF),
                                ),
                              ),
                              Positioned(
                                top: 16,
                                left: 38,
                                child: Container(
                                  width: 37,
                                  height: 37,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE1F5EB),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.trending_up_rounded,
                                    size: 20,
                                    color: AppColors.income,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 14,
                                bottom: 20,
                                child: Container(
                                  height: 33,
                                  width: 33,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF0DD),
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                  child: const Icon(
                                    Icons.savings_rounded,
                                    size: 19,
                                    color: Color(0xFFE0A146),
                                  ),
                                ),
                              ),
                              Transform.rotate(
                                angle: -0.08,
                                child: Container(
                                  width: 122,
                                  height: 99,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFECF7F0),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: const Align(
                                    alignment: Alignment.topCenter,
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 5),
                                      child: Icon(
                                        Icons.payments_outlined,
                                        size: 65,
                                        color: Color(0xFF22A668),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                height: 103,
                                width: 129,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF318CFA), Color(0xFF1358CE)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x2B1769E0),
                                      blurRadius: 24,
                                      offset: Offset(0, 14),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.account_balance_wallet_rounded,
                                  size: 70,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      const Text(
                        'Expense Manager',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 29,
                          letterSpacing: -0.8,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Quản lý thu chi cá nhân\nđơn giản và hiệu quả',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 14,
                          height: 1.65,
                        ),
                      ),
                      const Spacer(flex: 6),
                      SizedBox(
                        height: 56,
                        child: FilledButton(
                          onPressed: () => Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const HomePage()),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.blue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(17),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Bắt đầu',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(width: 10),
                              Icon(Icons.arrow_forward_rounded, size: 20),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 13),
                      const Text(
                        'Theo dõi chi tiêu • Chủ động tài chính',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9AA7B9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;
  List<TransactionData> transactions = [];
  String userName = 'Người dùng';
  String userEmail = '';
  double monthlyBudget = 0;
  bool isLoading = true;
  String? loadError;
  String quickType = 'all';
  String statsPeriod = 'month';
  TransactionFilter activeFilter = const TransactionFilter();
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    refreshAll();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> refreshAll() async {
    try {
      final db = DatabaseHelper.instance;
      final rows = await db.getTransactions();
      final name = await db.getSetting('profile_name');
      final email = await db.getSetting('profile_email');
      final budget = await db.getSetting('monthly_budget');
      if (!mounted) return;
      setState(() {
        transactions = rows.map(TransactionData.fromMap).toList();
        userName = (name == null || name.trim().isEmpty) ? 'Người dùng' : name;
        userEmail = email ?? '';
        monthlyBudget = double.tryParse(budget ?? '') ?? 0;
        isLoading = false;
        loadError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        loadError = 'Không tải được dữ liệu SQLite: $e';
      });
    }
  }

  double get totalIncome => transactions
      .where((t) => t.type == 'income').fold<double>(0, (sum, t) => sum + t.amount);
  double get totalExpense => transactions
      .where((t) => t.type == 'expense').fold<double>(0, (sum, t) => sum + t.amount);
  double get balance => totalIncome - totalExpense;

  void showError(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Có lỗi: $error')),
    );
  }

  Future<void> addTransaction() async {
    final created = await Navigator.push<TransactionData>(
      context,
      MaterialPageRoute(builder: (_) => const TransactionFormPage()),
    );
    if (created == null) return;
    try {
      await DatabaseHelper.instance.insertTransaction(created.toMap());
      await refreshAll();
    } catch (e) {
      showError(e);
    }
  }

  Future<void> editTransaction(TransactionData oldTransaction) async {
    final updated = await Navigator.push<TransactionData>(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionFormPage(transaction: oldTransaction),
      ),
    );
    if (updated == null) return;
    try {
      await DatabaseHelper.instance.updateTransaction(
          oldTransaction.id, updated.toMap());
      await refreshAll();
    } catch (e) {
      showError(e);
    }
  }

  Future<void> deleteTransaction(TransactionData t) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa giao dịch?'),
        content: Text('Bạn muốn xóa "${t.title}"? Thao tác này không thể hoàn tác.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Xóa',
                  style: TextStyle(color: AppColors.expense))),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await DatabaseHelper.instance.deleteTransaction(t.id);
      await refreshAll();
    } catch (e) {
      showError(e);
    }
  }

  List<TransactionData> get filteredTransactions {
    final text = searchController.text.trim().toLowerCase();
    return transactions.where((t) {
      if (quickType != 'all' && t.type != quickType) return false;
      if (activeFilter.type != 'all' && t.type != activeFilter.type) return false;
      if (activeFilter.category != 'all' && t.category != activeFilter.category) {
        return false;
      }
      if (activeFilter.fromDate != null &&
          DateUtils.dateOnly(t.date).isBefore(activeFilter.fromDate!)) {
        return false;
      }
      if (activeFilter.toDate != null &&
          DateUtils.dateOnly(t.date).isAfter(activeFilter.toDate!)) {
        return false;
      }
      return text.isEmpty || t.title.toLowerCase().contains(text) ||
          t.category.toLowerCase().contains(text) ||
          t.note.toLowerCase().contains(text);
    }).toList();
  }

  Future<void> openFilters() async {
    final result = await Navigator.push<TransactionFilter>(
      context,
      MaterialPageRoute(builder: (_) => FilterPage(initial: activeFilter)),
    );
    if (result != null && mounted) {
      setState(() {
        activeFilter = result;
        quickType = 'all'; // Tranh xung dot voi bo loc nang cao.
      });
    }
  }

  Future<void> editProfile() async {
    final nameController = TextEditingController(text: userName == 'Người dùng' ? '' : userName);
    final emailController = TextEditingController(text: userEmail);
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Thông tin cá nhân'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameController, maxLength: 60,
              decoration: const InputDecoration(labelText: 'Họ và tên')),
          const SizedBox(height: 10),
          TextField(controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email (không bắt buộc)')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Hủy')),
          FilledButton(onPressed: () {
            Navigator.pop(dialogContext, {
              'name': nameController.text.trim(),
              'email': emailController.text.trim(),
            });
          }, child: const Text('Lưu')),
        ],
      ),
    );
    // Các controller không được dispose ngay khi pop vì dialog còn chạy animation.
    if (result == null) return;
    try {
      await DatabaseHelper.instance.setSetting('profile_name', result['name']!);
      await DatabaseHelper.instance.setSetting('profile_email', result['email']!);
      await refreshAll();
    } catch (e) {
      showError(e);
    }
  }

  Future<void> editBudget() async {
    final controller = TextEditingController(
      text: monthlyBudget > 0 ? monthlyBudget.toStringAsFixed(0) : '',
    );
    final input = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ngân sách tháng'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Ngân sách (VNĐ)',
            helperText: 'Nhập 0 để bỏ giới hạn ngân sách',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Hủy')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, controller.text.trim()),
              child: const Text('Lưu')),
        ],
      ),
    );
    if (input == null) return;
    final amount = double.tryParse(input.replaceAll('.', '').replaceAll(',', ''));
    if (amount == null || amount < 0 || !amount.isFinite) {
      showError('Ngân sách không hợp lệ');
      return;
    }
    try {
      await DatabaseHelper.instance.setSetting('monthly_budget', amount.toString());
      await refreshAll();
    } catch (e) {
      showError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : loadError != null
          ? Center(child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(loadError!, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton(onPressed: refreshAll, child: const Text('Thử lại')),
        ]),
      ))
          : IndexedStack(index: currentIndex, children: [
        dashboardPage(),
        transactionPage(),
        statisticsPage(),
        profilePage(),
      ]),
      floatingActionButton: !isLoading && loadError == null && currentIndex <= 1
          ? currentIndex == 1
              ? FloatingActionButton.extended(
                  onPressed: addTransaction,
                  backgroundColor: AppColors.blue,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Thêm giao dịch',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                )
              : FloatingActionButton(
                  backgroundColor: AppColors.blue,
                  foregroundColor: Colors.white,
                  onPressed: addTransaction,
                  shape: const CircleBorder(),
                  child: const Icon(Icons.add, size: 30),
                )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.blue,
        unselectedItemColor: AppColors.muted,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long), label: 'Giao dịch'),
          BottomNavigationBarItem(icon: Icon(Icons.donut_large_outlined),
              activeIcon: Icon(Icons.donut_large), label: 'Thống kê'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person), label: 'Cá nhân'),
        ],
      ),
    );
  }

  // Trang chu: thay doi giao dien, giu nguyen du lieu SQLite va xu ly giao dich.
  Widget dashboardPage() {
    final recent = transactions.take(5).toList();
    final greetingName = userName.trim() == 'Người dùng' || userName.trim().isEmpty
        ? 'bạn'
        : userName.trim().split(RegExp(r'\s+')).last;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: refreshAll,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(18, 21, 18, 27),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3585F6), Color(0xFF135ACB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(27),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'EXPENSE MANAGER',
                              style: TextStyle(
                                color: Color(0xFFCDE4FF),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.6,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Xin chào, $greetingName!',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 23,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              'Quản lý tài chính của bạn',
                              style: TextStyle(
                                color: Color(0xFFE1EEFF),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Material(
                        color: Colors.white.withValues(alpha: 0.17),
                        shape: const CircleBorder(),
                        child: IconButton(
                          tooltip: 'Trang cá nhân',
                          onPressed: () => setState(() => currentIndex = 3),
                          icon: const Icon(
                            Icons.person_outline_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x17032B69),
                          blurRadius: 20,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Số dư hiện tại',
                                style: TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 9),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  formatMoney(balance),
                                  style: const TextStyle(
                                    color: AppColors.ink,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.6,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 9),
                              const Text(
                                'Tổng thu nhập − Tổng chi tiêu',
                                style: TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          height: 49,
                          width: 49,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF2FF),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 25,
                            color: AppColors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 18, 15, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: summaryCard(
                          'Tổng thu nhập',
                          totalIncome,
                          Icons.south_west_rounded,
                          AppColors.income,
                          const Color(0xFFE6F8EF),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: summaryCard(
                          'Tổng chi tiêu',
                          totalExpense,
                          Icons.north_east_rounded,
                          AppColors.expense,
                          const Color(0xFFFFEAED),
                        ),
                      ),
                    ],
                  ),
                  if (monthlyBudget > 0) ...[
                    const SizedBox(height: 17),
                    budgetCard(),
                  ],
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Giao dịch gần đây',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(() => currentIndex = 1),
                        child: const Text('Xem tất cả'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (recent.isEmpty)
                    emptyState(
                      'Chưa có giao dịch',
                      'Bấm + để thêm khoản thu hoặc chi đầu tiên',
                    )
                  else
                    Container(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(19),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: Column(
                        children: [
                          for (var index = 0; index < recent.length; index++) ...[
                            if (index != 0)
                              const Divider(
                                height: 15,
                                thickness: 1,
                                color: AppColors.line,
                              ),
                            TransactionTile(
                              transaction: recent[index],
                              onTap: () => editTransaction(recent[index]),
                              onDelete: () => deleteTransaction(recent[index]),
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget summaryCard(
    String label,
    double amount,
    IconData icon,
    Color accent,
    Color bg,
  ) {
    return Container(
      constraints: const BoxConstraints(minHeight: 128),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(19),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 34,
            width: 34,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Icon(icon, color: accent, size: 19),
          ),
          const SizedBox(height: 11),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 7),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatMoney(amount),
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double get thisMonthExpense {
    final now = DateTime.now();
    return transactions.where((t) => t.type == 'expense' &&
        t.date.year == now.year && t.date.month == now.month)
        .fold<double>(0, (sum, t) => sum + t.amount);
  }

  Widget budgetCard() {
    final spent = thisMonthExpense;
    final ratio = (spent / monthlyBudget).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: AppColors.line)),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Ngân sách tháng này',
              style: TextStyle(fontWeight: FontWeight.w700)),
          InkWell(onTap: editBudget,
              child: const Icon(Icons.edit_outlined, color: AppColors.blue, size: 18)),
        ]),
        const SizedBox(height: 12),
        LinearProgressIndicator(value: ratio,
            backgroundColor: AppColors.line,
            color: spent > monthlyBudget ? AppColors.expense : AppColors.blue,
            minHeight: 8, borderRadius: BorderRadius.circular(8)),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Đã chi: ${formatMoney(spent)}',
              style: const TextStyle(fontSize: 12, color: AppColors.muted)),
          Flexible(child: Text('Mục tiêu: ${formatMoney(monthlyBudget)}',
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 12, color: AppColors.muted))),
        ]),
      ]),
    );
  }

  // Giao dich V4: tong quan tu SQLite, tim kiem, loc, nhom theo thang.
  Widget transactionPage() {
    final list = filteredTransactions;
    final income = list.where((t) => t.type == 'income')
        .fold<double>(0, (sum, t) => sum + t.amount);
    final expense = list.where((t) => t.type == 'expense')
        .fold<double>(0, (sum, t) => sum + t.amount);
    final sorted = [...list]..sort((a, b) {
      final order = b.date.compareTo(a.date);
      return order != 0 ? order : b.id.compareTo(a.id);
    });

    final grouped = <String, List<TransactionData>>{};
    for (final item in sorted) {
      final monthKey = '${item.date.month.toString().padLeft(2, '0')}/${item.date.year}';
      grouped.putIfAbsent(monthKey, () => <TransactionData>[]).add(item);
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Giao dịch', style: TextStyle(
                        fontSize: 26, fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      )),
                      SizedBox(height: 3),
                      Text('Theo dõi các khoản thu và chi của bạn',
                        style: TextStyle(color: AppColors.muted, fontSize: 11)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F0FF),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(Icons.receipt_long_outlined,
                    color: AppColors.blue, size: 23),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.line),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tổng quan giao dịch', style: TextStyle(
                        color: AppColors.muted, fontSize: 12,
                        fontWeight: FontWeight.w600)),
                      Text(
                        searchController.text.trim().isNotEmpty ||
                            quickType != 'all' ||
                            activeFilter.type != 'all' ||
                            activeFilter.category != 'all' ||
                            activeFilter.fromDate != null ||
                            activeFilter.toDate != null
                          ? 'Theo bộ lọc' : 'Tất cả dữ liệu',
                        style: const TextStyle(color: AppColors.blue, fontSize: 10),
                      ),
                    ],
                  ),
                  const SizedBox(height: 13),
                  Row(children: [
                    Expanded(child: _transactionSummary(
                      'Thu nhập', income, Icons.south_west_rounded,
                      AppColors.income,
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: _transactionSummary(
                      'Chi tiêu', expense, Icons.north_east_rounded,
                      AppColors.expense,
                    )),
                  ]),
                  const SizedBox(height: 11),
                  const Divider(height: 1, color: AppColors.line),
                  const SizedBox(height: 11),
                  Row(children: [
                    const Expanded(child: Text('Chênh lệch thu chi',
                      style: TextStyle(color: AppColors.muted, fontSize: 11))),
                    Flexible(child: Text(formatMoney(income - expense),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13,
                        color: income - expense >= 0
                          ? AppColors.ink : AppColors.expense))),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 13),
            Row(children: [
              Expanded(child: SizedBox(
                height: 46,
                child: TextField(
                  controller: searchController,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, size: 20),
                    hintText: 'Tìm giao dịch...',
                    hintStyle: const TextStyle(fontSize: 12),
                    contentPadding: const EdgeInsets.symmetric(vertical: 11),
                    fillColor: Colors.white,
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            tooltip: 'Xóa từ khóa',
                            onPressed: () => setState(searchController.clear),
                            icon: const Icon(Icons.close, size: 18),
                          ) : null,
                  ),
                ),
              )),
              const SizedBox(width: 9),
              Material(
                color: const Color(0xFFE8F0FF),
                borderRadius: BorderRadius.circular(13),
                child: IconButton(
                  onPressed: openFilters,
                  icon: const Icon(Icons.tune_rounded),
                  color: AppColors.blue,
                  tooltip: 'Bộ lọc nâng cao',
                ),
              ),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: typePill('all', 'Tất cả')),
              const SizedBox(width: 7),
              Expanded(child: typePill('income', 'Thu nhập')),
              const SizedBox(width: 7),
              Expanded(child: typePill('expense', 'Chi tiêu')),
            ]),
            const SizedBox(height: 13),
            Row(children: [
              const Expanded(child: Text('Danh sách giao dịch',
                style: TextStyle(fontWeight: FontWeight.w800,
                  fontSize: 15, color: AppColors.ink))),
              Text('${list.length} giao dịch',
                style: const TextStyle(color: AppColors.muted, fontSize: 11)),
            ]),
            const SizedBox(height: 9),
            Expanded(
              child: list.isEmpty
                ? ListView(children: [emptyState(
                    'Không có giao dịch phù hợp',
                    'Thử thay đổi từ khóa hoặc bộ lọc',
                  )])
                : RefreshIndicator(
                    onRefresh: refreshAll,
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 100),
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.line),
                          ),
                          child: Column(
                            children: [
                              for (final entry in grouped.entries) ...[
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(13, 14, 13, 7),
                                  child: Row(children: [
                                    const Icon(Icons.calendar_month_outlined,
                                      size: 15, color: AppColors.blue),
                                    const SizedBox(width: 6),
                                    Text('Tháng ${entry.key}',
                                      style: const TextStyle(
                                        fontSize: 12, fontWeight: FontWeight.w800,
                                        color: AppColors.ink,
                                      )),
                                    const Spacer(),
                                    Text('${entry.value.length} giao dịch',
                                      style: const TextStyle(fontSize: 10,
                                        color: AppColors.muted)),
                                  ]),
                                ),
                                for (var i = 0; i < entry.value.length; i++) ...[
                                  _compactTransactionTile(entry.value[i]),
                                  if (i < entry.value.length - 1)
                                    const Divider(height: 1, indent: 66,
                                      endIndent: 14, color: AppColors.line),
                                ],
                                if (entry.key != grouped.keys.last)
                                  const Divider(height: 12,
                                    thickness: 6, color: AppColors.background),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _transactionSummary(String label, double amount,
      IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 4),
          Flexible(child: Text(label, style: const TextStyle(
            color: AppColors.muted, fontSize: 11))),
        ]),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(formatMoney(amount),
            style: TextStyle(color: color, fontSize: 17,
              fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }

  Widget _compactTransactionTile(TransactionData item) {
    final isIncome = item.type == 'income';
    final info = categoryInfo(item.category, item.type);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => editTransaction(item),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(children: [
            Container(
              height: 42, width: 42,
              decoration: BoxDecoration(
                color: info.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(info.icon, color: info.color, size: 21),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.ink,
                    fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 4),
                Text('${item.category} · ${formatDate(item.date)}',
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.muted, fontSize: 10)),
              ],
            )),
            const SizedBox(width: 5),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${isIncome ? '+' : '-'}${formatMoney(item.amount)}',
                style: TextStyle(color: isIncome
                  ? AppColors.income : AppColors.expense,
                  fontWeight: FontWeight.w800, fontSize: 11)),
              SizedBox(height: 24, width: 30,
                child: PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.more_horiz,
                    color: AppColors.muted, size: 19),
                  tooltip: 'Tùy chọn giao dịch',
                  onSelected: (action) {
                    if (action == 'edit') editTransaction(item);
                    if (action == 'delete') deleteTransaction(item);
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Chỉnh sửa')),
                    PopupMenuItem(value: 'delete', child: Text('Xóa')),
                  ],
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget typePill(String type, String text) {
    final selected = quickType == type;
    return OutlinedButton(
      onPressed: () => setState(() => quickType = type),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 4),
        backgroundColor: selected ? AppColors.blue : Colors.white,
        foregroundColor: selected ? Colors.white : AppColors.muted,
        side: BorderSide(color: selected ? AppColors.blue : AppColors.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(text, style: const TextStyle(
        fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }

  bool inSelectedPeriod(DateTime date) {
    final now = DateTime.now();
    if (statsPeriod == 'year') return date.year == now.year;
    if (statsPeriod == 'previous') {
      final previous = DateTime(now.year, now.month - 1);
      return date.year == previous.year && date.month == previous.month;
    }
    return date.year == now.year && date.month == now.month;
  }

  // Thong ke V6: tat ca so lieu tinh truc tiep tu du lieu SQLite.
  Widget statisticsPage() {
    final periodTransactions = transactions
        .where((t) => inSelectedPeriod(t.date)).toList();
    final income = periodTransactions
        .where((t) => t.type == 'income')
        .fold<double>(0, (sum, t) => sum + t.amount);
    final expense = periodTransactions
        .where((t) => t.type == 'expense')
        .fold<double>(0, (sum, t) => sum + t.amount);
    final difference = income - expense;
    final byCategory = <String, double>{};
    for (final t in periodTransactions.where((t) => t.type == 'expense')) {
      byCategory.update(t.category, (old) => old + t.amount,
          ifAbsent: () => t.amount);
    }
    final sorted = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final slices = sorted.map((e) => DonutSlice(
        e.value, categoryInfo(e.key, 'expense').color)).toList();
    final current = DateTime.now();
    final selectedMonth = statsPeriod == 'previous'
        ? DateTime(current.year, current.month - 1)
        : current;
    final periodLabel = statsPeriod == 'year'
        ? 'Năm ${current.year}'
        : 'Tháng ${selectedMonth.month}/${selectedMonth.year}';

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: refreshAll,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
          children: [
            const Text('Thống kê', style: TextStyle(
                fontSize: 27, fontWeight: FontWeight.w800,
                color: AppColors.ink)),
            const SizedBox(height: 5),
            const Text('Phân tích dòng tiền và thói quen chi tiêu',
                style: TextStyle(fontSize: 12, color: AppColors.muted)),
            const SizedBox(height: 17),
            Row(children: [
              Expanded(child: periodPill('month', 'Tháng này')),
              const SizedBox(width: 7),
              Expanded(child: periodPill('previous', 'Tháng trước')),
              const SizedBox(width: 7),
              Expanded(child: periodPill('year', 'Năm nay')),
            ]),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2780EF), Color(0xFF1356BC)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(periodLabel.toUpperCase(), style: const TextStyle(
                    color: Color(0xFFD8E8FF), fontSize: 11,
                    fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                const SizedBox(height: 8),
                const Text('Chênh lệch thu chi', style: TextStyle(
                    color: Colors.white, fontSize: 13)),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(formatMoney(difference),
                      style: const TextStyle(color: Colors.white,
                          fontWeight: FontWeight.w800, fontSize: 29)),
                ),
                const SizedBox(height: 11),
                Text('${periodTransactions.length} giao dịch trong kỳ',
                    style: const TextStyle(color: Color(0xFFD8E8FF),
                        fontSize: 12)),
              ]),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: summaryCard('Tổng thu', income,
                  Icons.south_west_rounded, AppColors.income,
                  const Color(0xFFE3F9ED))),
              const SizedBox(width: 10),
              Expanded(child: summaryCard('Tổng chi', expense,
                  Icons.north_east_rounded, AppColors.expense,
                  const Color(0xFFFFE9EC))),
            ]),
            const SizedBox(height: 16),
            _statisticsTrendCard(periodTransactions, selectedMonth, current),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Cơ cấu chi tiêu', style: TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 17,
                      color: AppColors.ink)),
                  const SizedBox(height: 4),
                  const Text('Tỷ trọng chi theo từng danh mục',
                      style: TextStyle(fontSize: 11,
                          color: AppColors.muted)),
                  const SizedBox(height: 18),
                  Center(child: SizedBox(
                    width: 188,
                    height: 188,
                    child: Stack(alignment: Alignment.center, children: [
                      CustomPaint(size: const Size(188, 188),
                          painter: DonutPainter(slices)),
                      Column(mainAxisSize: MainAxisSize.min, children: [
                        const Text('Tổng chi', style: TextStyle(
                            color: AppColors.muted, fontSize: 12)),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(formatMoney(expense),
                                style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.ink)),
                          ),
                        ),
                      ]),
                    ]),
                  )),
                  const SizedBox(height: 19),
                  if (sorted.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Center(child: Text(
                          'Chưa có khoản chi trong khoảng thời gian này',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: AppColors.muted, fontSize: 12))),
                    )
                  else
                    for (final entry in sorted) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(children: [
                          Container(
                            width: 10, height: 10,
                            decoration: BoxDecoration(
                              color: categoryInfo(entry.key, 'expense').color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 9),
                          Expanded(child: Text(entry.key,
                              style: const TextStyle(fontSize: 12,
                                  color: AppColors.ink,
                                  fontWeight: FontWeight.w600))),
                          Text('${(entry.value / expense * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.muted)),
                          const SizedBox(width: 11),
                          Text(formatMoney(entry.value),
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink)),
                        ]),
                      ),
                    ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statisticsTrendCard(
    List<TransactionData> periodTransactions,
    DateTime monthDate,
    DateTime now,
  ) {
    final isYear = statsPeriod == 'year';
    final periods = isYear ? 12 : 5;
    final incomes = List<double>.filled(periods, 0);
    final expenses = List<double>.filled(periods, 0);
    final labels = List<String>.generate(periods,
        (index) => isYear ? 'T${index + 1}' : 'T${index + 1}');

    for (final transaction in periodTransactions) {
      final slot = isYear
          ? transaction.date.month - 1
          : math.min(4, (transaction.date.day - 1) ~/ 7);
      if (transaction.type == 'income') {
        incomes[slot] += transaction.amount;
      } else if (transaction.type == 'expense') {
        expenses[slot] += transaction.amount;
      }
    }
    final maxValue = [...incomes, ...expenses]
        .fold<double>(0, (max, value) => math.max(max, value));

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 17, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Xu hướng thu và chi',
            style: TextStyle(fontSize: 17,
                fontWeight: FontWeight.w800, color: AppColors.ink)),
        const SizedBox(height: 5),
        Text(isYear
            ? 'Theo từng tháng trong năm ${now.year}'
            : 'Theo từng tuần trong tháng ${monthDate.month}/${monthDate.year}',
            style: const TextStyle(fontSize: 11, color: AppColors.muted)),
        const SizedBox(height: 13),
        Row(children: [
          _trendLegend(AppColors.income, 'Thu nhập'),
          const SizedBox(width: 18),
          _trendLegend(AppColors.expense, 'Chi tiêu'),
        ]),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(periods, (i) => SizedBox(
              width: isYear ? 45 : 56,
              child: Column(children: [
                SizedBox(
                  height: 128,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _trendBar(incomes[i], maxValue, AppColors.income),
                      const SizedBox(width: 4),
                      _trendBar(expenses[i], maxValue, AppColors.expense),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(labels[i], style: const TextStyle(
                    fontSize: 11, color: AppColors.muted,
                    fontWeight: FontWeight.w600)),
              ]),
            )),
          ),
        ),
        if (maxValue == 0) ...[
          const SizedBox(height: 9),
          const Center(child: Text('Chưa có dữ liệu trong kỳ',
              style: TextStyle(fontSize: 11, color: AppColors.muted))),
        ],
        const SizedBox(height: 8),
        const Text('Cột thể hiện tổng số tiền trong từng khoảng thời gian.',
            style: TextStyle(fontSize: 10, color: AppColors.muted)),
      ]),
    );
  }

  Widget _trendLegend(Color color, String label) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 9, height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(
          fontSize: 11, color: AppColors.muted)),
    ]);
  }

  Widget _trendBar(double value, double maxValue, Color color) {
    final height = maxValue <= 0 || value <= 0
        ? 0.0
        : math.max(3.0, value / maxValue * 118.0);
    return Tooltip(
      message: formatMoney(value),
      child: Container(
        width: 15,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
        ),
      ),
    );
  }

  Widget periodPill(String key, String text) {
    final selected = statsPeriod == key;
    return OutlinedButton(
      onPressed: () => setState(() => statsPeriod = key),
      style: OutlinedButton.styleFrom(
        backgroundColor: selected ? AppColors.blue : Colors.white,
        foregroundColor: selected ? Colors.white : AppColors.muted,
        side: BorderSide(color: selected ? AppColors.blue : AppColors.line),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 11),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12,
          fontWeight: FontWeight.w600)),
    );
  }

  // Danh muc da duoc su dung trong SQLite, khong tao/sua bang du lieu.
  Future<void> _openCategories() async {
    final expenseItems = transactions.where((t) => t.type == 'expense').toList();
    final names = <String>{...expenseCategories, ...expenseItems.map((t) => t.category)}.toList();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Danh mục chi tiêu', style: TextStyle(
                  color: AppColors.ink, fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 5),
              const Text('Các danh mục đang được sử dụng trong ứng dụng.',
                  style: TextStyle(color: AppColors.muted, fontSize: 12)),
              const SizedBox(height: 15),
              Flexible(child: ListView.separated(
                shrinkWrap: true,
                itemCount: names.length,
                separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.line),
                itemBuilder: (_, index) {
                  final name = names[index];
                  final items = expenseItems.where((t) => t.category == name).toList();
                  final sum = items.fold<double>(0, (v, t) => v + t.amount);
                  final info = categoryInfo(name, 'expense');
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: info.color.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(12)),
                      child: Icon(info.icon, color: info.color, size: 21),
                    ),
                    title: Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text('${items.length} giao dịch',
                        style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                    trailing: Text(formatMoney(sum),
                        style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700)),
                  );
                },
              )),
            ],
          ),
        ),
      ),
    );
  }

  // Xuat ban sao JSON qua clipboard. Khong tu nhan la da luu thanh file.
  Future<void> _copyBackup() async {
    try {
      final rows = await DatabaseHelper.instance.getTransactions();
      final data = {
        'app': 'Expense Manager',
        'version': 1,
        'exportedAt': DateTime.now().toIso8601String(),
        'profile': {
          'name': await DatabaseHelper.instance.getSetting('profile_name') ?? '',
          'email': await DatabaseHelper.instance.getSetting('profile_email') ?? '',
        },
        'monthlyBudget': await DatabaseHelper.instance.getSetting('monthly_budget') ?? '0',
        'transactions': rows,
      };
      if (!mounted) return;
      final agree = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Sao chép dữ liệu'),
          content: const Text(
            'Ứng dụng sẽ sao chép dữ liệu thu chi và hồ sơ dưới dạng JSON vào bộ nhớ tạm. '
            'Bạn cần dán vào một tệp và lưu ở nơi an toàn để tạo bản sao lưu. '
            'Chức năng nhập/khôi phục dữ liệu chưa được hỗ trợ. '
            'Không dán dữ liệu vào nơi công khai.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Hủy')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Sao chép JSON')),
          ],
        ),
      );
      if (agree != true || !mounted) return;
      await Clipboard.setData(ClipboardData(text: const JsonEncoder.withIndent('  ').convert(data)));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Đã sao chép JSON. Hãy dán và lưu thành tệp để sao lưu.'),
        behavior: SnackBarBehavior.floating,
      ));
    } catch (e) {
      showError(e);
    }
  }

  Widget profilePage() {
    final name = userName.trim().isEmpty ? 'Người dùng' : userName;
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: refreshAll,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 36),
          children: [
            const Text('Cá nhân', style: TextStyle(fontSize: 27,
                fontWeight: FontWeight.w800, color: AppColors.ink)),
            const SizedBox(height: 5),
            const Text('Thông tin và cài đặt của bạn',
                style: TextStyle(color: AppColors.muted, fontSize: 13)),
            const SizedBox(height: 20),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              child: InkWell(
                onTap: editProfile,
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.line),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(children: [
                    Row(children: [
                      Container(
                        height: 62, width: 62,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE6F0FF), shape: BoxShape.circle),
                        child: const Icon(Icons.person_rounded, color: AppColors.blue, size: 33),
                      ),
                      const SizedBox(width: 14),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 17,
                                  fontWeight: FontWeight.w800, color: AppColors.ink)),
                          const SizedBox(height: 5),
                          Text(userEmail.isEmpty ? 'Chưa cập nhật email' : userEmail,
                              maxLines: 2, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                        ],
                      )),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(color: const Color(0xFFF0F5FF),
                            borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.edit_outlined, color: AppColors.blue, size: 19),
                      ),
                    ]),
                    const SizedBox(height: 15),
                    const Divider(height: 1, color: AppColors.line),
                    const SizedBox(height: 12),
                    const Row(children: [
                      Icon(Icons.storage_outlined, color: AppColors.income, size: 17),
                      SizedBox(width: 8),
                      Expanded(child: Text('Dữ liệu được lưu cục bộ bằng SQLite',
                          style: TextStyle(color: AppColors.muted, fontSize: 11))),
                    ]),
                  ]),
                ),
              ),
            ),
            const SizedBox(height: 26),
            const Text('Quản lý tài khoản', style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.ink)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(color: Colors.white,
                  border: Border.all(color: AppColors.line),
                  borderRadius: BorderRadius.circular(20)),
              child: Column(children: [
                _profileMenuItem(Icons.person_outline_rounded, 'Thông tin cá nhân',
                    'Cập nhật họ tên và email', editProfile),
                const Divider(height: 1, indent: 66, endIndent: 16, color: AppColors.line),
                _profileMenuItem(Icons.account_balance_wallet_outlined, 'Cài đặt ngân sách',
                    'Quản lý giới hạn chi tiêu theo tháng', editBudget),
                const Divider(height: 1, indent: 66, endIndent: 16, color: AppColors.line),
                _profileMenuItem(Icons.category_outlined, 'Danh mục chi tiêu',
                    'Xem danh mục và tổng tiền đã chi', _openCategories),
                const Divider(height: 1, indent: 66, endIndent: 16, color: AppColors.line),
                _profileMenuItem(Icons.content_copy_outlined, 'Sao chép dữ liệu',
                    'Xuất bản sao JSON để lưu thủ công', _copyBackup),
                const Divider(height: 1, indent: 66, endIndent: 16, color: AppColors.line),
                _profileMenuItem(Icons.refresh_rounded, 'Làm mới dữ liệu',
                    'Tải lại dữ liệu từ SQLite', refreshAll),
              ]),
            ),
            const SizedBox(height: 25),
            const Text('Tổng quan tài khoản', style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.ink)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _profileOverview(Icons.receipt_long_outlined,
                  '${transactions.length}', 'Tổng giao dịch')),
              const SizedBox(width: 12),
              Expanded(child: _profileOverview(Icons.savings_outlined,
                  monthlyBudget > 0 ? formatMoney(monthlyBudget) : 'Chưa đặt',
                  'Ngân sách tháng')),
            ]),
            const SizedBox(height: 25),
            const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.storage_outlined, color: AppColors.muted, size: 15),
              SizedBox(width: 7),
              Text('Expense Manager  •  SQLite', style: TextStyle(
                  fontSize: 11, color: AppColors.muted)),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _profileMenuItem(IconData icon, String title, String subtitle,
      VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          child: Row(children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(color: const Color(0xFFEDF4FF),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: AppColors.blue, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13,
                    fontWeight: FontWeight.w700, color: AppColors.ink)),
                const SizedBox(height: 3),
                Text(subtitle, style: const TextStyle(
                    fontSize: 11, color: AppColors.muted)),
              ],
            )),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF97A5BB), size: 20),
          ]),
        ),
      ),
    );
  }

  Widget _profileOverview(IconData icon, String value, String label) {
    return Container(
      constraints: const BoxConstraints(minHeight: 125),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: AppColors.blue, size: 21),
        const SizedBox(height: 12),
        FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft,
          child: Text(value, style: const TextStyle(fontWeight: FontWeight.w800,
              fontSize: 20, color: AppColors.ink))),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
      ]),
    );
  }

}

Widget emptyState(String heading, String detail) {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.symmetric(vertical: 8),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 36),
    decoration: BoxDecoration(color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppColors.line)),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.receipt_long_outlined, color: AppColors.muted, size: 43),
      const SizedBox(height: 12),
      Text(heading, textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w700,
              color: AppColors.ink)),
      const SizedBox(height: 6),
      Text(detail, textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: AppColors.muted)),
    ]),
  );
}

class TransactionTile extends StatelessWidget {
  final TransactionData transaction;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TransactionTile({super.key, required this.transaction,
    required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final category = categoryInfo(transaction.category, transaction.type);
    final isIncome = transaction.type == 'income';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.line)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 11),
          child: Row(children: [
            Container(width: 43, height: 43,
                decoration: BoxDecoration(color: category.color.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(category.icon, color: category.color, size: 23)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(transaction.title, maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14,
                          fontWeight: FontWeight.w800, color: AppColors.ink)),
                  const SizedBox(height: 3),
                  Text('${transaction.category} • ${formatDate(transaction.date)}',
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                ])),
            const SizedBox(width: 7),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${isIncome ? '+' : '-'}${formatMoney(transaction.amount)}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
                      color: isIncome ? AppColors.income : AppColors.expense)),
              const SizedBox(height: 3),
              SizedBox(height: 26, width: 30, child: PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.more_horiz, size: 20, color: AppColors.muted),
                tooltip: 'Tùy chọn giao dịch',
                onSelected: (value) {
                  if (value == 'edit') onTap();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Chỉnh sửa')),
                  PopupMenuItem(value: 'delete', child: Text('Xóa')),
                ],
              )),
            ]),
          ]),
        ),
      ),
    );
  }
}

class TransactionFormPage extends StatefulWidget {
  final TransactionData? transaction;
  const TransactionFormPage({super.key, this.transaction});

  @override
  State<TransactionFormPage> createState() => _TransactionFormPageState();
}

class _TransactionFormPageState extends State<TransactionFormPage> {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final noteController = TextEditingController();
  String type = 'expense';
  String category = 'Ăn uống';
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    final original = widget.transaction;
    if (original != null) {
      titleController.text = original.title;
      amountController.text = original.amount.toStringAsFixed(0);
      noteController.text = original.note;
      type = original.type;
      category = expenseCategories.contains(original.category)
          ? original.category : 'Khác';
      selectedDate = original.date;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) setState(() => selectedDate = picked);
  }

  void save() {
    if (!formKey.currentState!.validate()) return;
    final raw = amountController.text.trim();
    final amount = double.tryParse(raw);
    if (amount == null || amount <= 0 || !amount.isFinite) return;
    Navigator.pop(context, TransactionData(
      id: widget.transaction?.id ?? 0,
      title: titleController.text.trim(),
      category: type == 'income' ? 'Thu nhập' : category,
      date: selectedDate,
      amount: amount,
      type: type,
      note: noteController.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.transaction != null;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(isEdit ? 'Sửa giao dịch' : 'Thêm giao dịch',
          style: const TextStyle(fontWeight: FontWeight.w800))),
      body: Form(key: formKey, child: ListView(
        padding: const EdgeInsets.all(17),
        children: [
          const Text('Loại giao dịch', style: TextStyle(
              fontWeight: FontWeight.w800, color: AppColors.ink)),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: formTypeButton('expense', 'Chi tiêu')),
            const SizedBox(width: 9),
            Expanded(child: formTypeButton('income', 'Thu nhập')),
          ]),
          const SizedBox(height: 22),
          const Text('Tên giao dịch', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextFormField(
            controller: titleController,
            maxLength: 80,
            decoration: const InputDecoration(hintText: 'Ví dụ: Ăn trưa, Lương tháng...',
                counterText: ''),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Vui lòng nhập tên giao dịch' : null,
          ),
          const SizedBox(height: 19),
          const Text('Danh mục', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          if (type == 'expense')
            DropdownButtonFormField<String>(
              value: category,
              decoration: const InputDecoration(),
              items: expenseCategories.map((c) => DropdownMenuItem(
                value: c, child: Row(children: [
                Icon(categoryInfo(c, 'expense').icon,
                    color: categoryInfo(c, 'expense').color, size: 20),
                const SizedBox(width: 9),
                Text(c),
              ]),
              )).toList(),
              onChanged: (value) {
                if (value != null) setState(() => category = value);
              },
            )
          else
            const InputDecorator(
              decoration: InputDecoration(),
              child: Text('Thu nhập'),
            ),
          const SizedBox(height: 19),
          const Text('Số tiền', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextFormField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(hintText: 'Nhập số tiền', suffixText: 'đ'),
            validator: (value) {
              final amount = double.tryParse(value?.trim() ?? '');
              return amount == null || amount <= 0 || !amount.isFinite
                  ? 'Số tiền phải lớn hơn 0' : null;
            },
          ),
          const SizedBox(height: 19),
          const Text('Ngày giao dịch', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          InkWell(onTap: pickDate, borderRadius: BorderRadius.circular(14),
            child: InputDecorator(
              decoration: const InputDecoration(suffixIcon: Icon(Icons.calendar_today)),
              child: Text(formatDate(selectedDate)),
            ),
          ),
          const SizedBox(height: 19),
          const Text('Ghi chú', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextFormField(
            controller: noteController,
            maxLength: 500,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'Nhập ghi chú (tùy chọn)',
                alignLabelWithHint: true),
          ),
          const SizedBox(height: 19),
          SizedBox(height: 52, child: FilledButton(
            onPressed: save,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
            ),
            child: Text(isEdit ? 'Cập nhật giao dịch' : 'Lưu giao dịch',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          )),
          const SizedBox(height: 25),
        ],
      )),
    );
  }

  Widget formTypeButton(String key, String text) {
    final selected = type == key;
    final accent = key == 'expense' ? AppColors.expense : AppColors.income;
    return OutlinedButton(
      onPressed: () => setState(() => type = key),
      style: OutlinedButton.styleFrom(
        backgroundColor: selected ? accent : Colors.white,
        foregroundColor: selected ? Colors.white : AppColors.muted,
        side: BorderSide(color: selected ? accent : AppColors.line),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}

class TransactionFilter {
  final String type;
  final String category;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String period;

  const TransactionFilter({
    this.type = 'all',
    this.category = 'all',
    this.fromDate,
    this.toDate,
    this.period = 'all',
  });
}

class FilterPage extends StatefulWidget {
  final TransactionFilter initial;
  const FilterPage({super.key, required this.initial});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  late String type;
  late String category;
  late String period;
  DateTime? fromDate;
  DateTime? toDate;

  @override
  void initState() {
    super.initState();
    type = widget.initial.type;
    category = widget.initial.category;
    period = widget.initial.period;
    fromDate = widget.initial.fromDate;
    toDate = widget.initial.toDate;
  }

  void _changeType(String next) {
    setState(() {
      type = next;
      if (next == 'income') {
        category = 'all';
      } else if (category == 'Thu nhập') {
        category = 'all';
      }
    });
  }

  void _changePeriod(String next) {
    setState(() {
      period = next;
      if (next != 'custom') {
        fromDate = null;
        toDate = null;
      }
    });
  }

  Future<void> _selectRange() async {
    final now = DateUtils.dateOnly(DateTime.now());
    final earliest = DateTime(2020);
    final latest = DateTime(2100);
    final validInitial = fromDate != null && toDate != null &&
        !fromDate!.isBefore(earliest) && !toDate!.isAfter(latest) &&
        !fromDate!.isAfter(toDate!);
    final range = await showDateRangePicker(
      context: context,
      firstDate: earliest,
      lastDate: latest,
      initialDateRange: validInitial
          ? DateTimeRange(start: fromDate!, end: toDate!)
          : null,
      currentDate: now,
      helpText: 'CHỌN KHOẢNG THỜI GIAN',
      saveText: 'XONG',
    );
    if (range != null && mounted) {
      setState(() {
        period = 'custom';
        fromDate = range.start;
        toDate = range.end;
      });
    }
  }

  void _reset() {
    setState(() {
      type = 'all';
      category = 'all';
      period = 'all';
      fromDate = null;
      toDate = null;
    });
  }

  void _apply() {
    final today = DateUtils.dateOnly(DateTime.now());
    DateTime? start;
    DateTime? end;
    switch (period) {
      case 'today':
        start = today;
        end = today;
        break;
      case 'week':
        start = today.subtract(const Duration(days: 6));
        end = today;
        break;
      case 'month':
        start = DateTime(today.year, today.month);
        end = today;
        break;
      case 'previous':
        start = DateTime(today.year, today.month - 1);
        end = DateTime(today.year, today.month, 0);
        break;
      case 'custom':
        start = fromDate;
        end = toDate;
        if (start == null || end == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vui lòng chọn khoảng ngày.')),
          );
          return;
        }
        if (start.isAfter(end)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ngày bắt đầu phải trước ngày kết thúc.')),
          );
          return;
        }
        break;
    }
    Navigator.pop(context, TransactionFilter(
      type: type,
      category: category,
      period: period,
      fromDate: start,
      toDate: end,
    ));
  }

  Widget _section({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              height: 34,
              width: 34,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF2FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.blue, size: 19),
            ),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(
              color: AppColors.ink,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            )),
          ]),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _choice({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: selected ? const Color(0xFFEAF2FF) : const Color(0xFFF9FAFD),
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Container(
          constraints: const BoxConstraints(minHeight: 45),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: selected ? AppColors.blue : AppColors.line),
          ),
          child: Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              color: selected ? AppColors.blue : AppColors.muted,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = type == 'income'
        ? const <String>['all', 'Thu nhập']
        : type == 'expense'
            ? <String>['all', ...expenseCategories]
            : <String>['all', ...expenseCategories, 'Thu nhập'];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Bộ lọc giao dịch', style: TextStyle(
          fontSize: 19, fontWeight: FontWeight.w800,
        )),
        actions: [
          TextButton(onPressed: _reset, child: const Text('Đặt lại')),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            const Text('Lọc theo loại, danh mục và thời gian',
              style: TextStyle(fontSize: 12, color: AppColors.muted)),
            const SizedBox(height: 16),
            _section(
              icon: Icons.swap_horiz_rounded,
              title: 'Loại giao dịch',
              child: Row(children: [
                for (final item in const [
                  ('all', 'Tất cả'),
                  ('income', 'Thu nhập'),
                  ('expense', 'Chi tiêu'),
                ]) ...[
                  if (item.$1 != 'all') const SizedBox(width: 8),
                  Expanded(child: _choice(
                    label: item.$2,
                    selected: type == item.$1,
                    onTap: () => _changeType(item.$1),
                  )),
                ],
              ]),
            ),
            const SizedBox(height: 12),
            _section(
              icon: Icons.category_outlined,
              title: 'Danh mục',
              child: DropdownButtonFormField<String>(
                key: ValueKey(type),
                initialValue: categories.contains(category) ? category : 'all',
                isExpanded: true,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.sell_outlined, color: AppColors.blue),
                ),
                items: categories.map((value) => DropdownMenuItem<String>(
                  value: value,
                  child: Text(value == 'all' ? 'Tất cả danh mục' : value),
                )).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => category = value);
                },
              ),
            ),
            const SizedBox(height: 12),
            _section(
              icon: Icons.calendar_month_outlined,
              title: 'Khoảng thời gian',
              child: Column(children: [
                Row(children: [
                  Expanded(child: _choice(
                    label: 'Tất cả', selected: period == 'all',
                    onTap: () => _changePeriod('all'),
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: _choice(
                    label: 'Hôm nay', selected: period == 'today',
                    onTap: () => _changePeriod('today'),
                  )),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: _choice(
                    label: '7 ngày qua', selected: period == 'week',
                    onTap: () => _changePeriod('week'),
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: _choice(
                    label: 'Tháng này', selected: period == 'month',
                    onTap: () => _changePeriod('month'),
                  )),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: _choice(
                    label: 'Tháng trước', selected: period == 'previous',
                    onTap: () => _changePeriod('previous'),
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: _choice(
                    label: 'Tùy chỉnh', selected: period == 'custom',
                    onTap: () => _changePeriod('custom'),
                  )),
                ]),
                if (period == 'custom') ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _selectRange,
                    icon: const Icon(Icons.date_range_outlined, size: 20),
                    label: Text(fromDate == null || toDate == null
                        ? 'Chọn ngày bắt đầu và kết thúc'
                        : '${formatDate(fromDate!)} – ${formatDate(toDate!)}'),
                  ),
                ],
              ]),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          decoration: const BoxDecoration(color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.line))),
          child: SizedBox(
            height: 50,
            child: FilledButton.icon(
              onPressed: _apply,
              icon: const Icon(Icons.check_rounded),
              label: const Text('Áp dụng bộ lọc'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DonutSlice {
  final double value;
  final Color color;
  const DonutSlice(this.value, this.color);
}

class DonutPainter extends CustomPainter {
  final List<DonutSlice> slices;
  const DonutPainter(this.slices);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 15;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()..style = PaintingStyle.stroke
      ..strokeWidth = 25 ..strokeCap = StrokeCap.butt;
    final total = slices.fold<double>(0, (sum, s) => sum + s.value);
    if (total <= 0) {
      paint.color = AppColors.line;
      canvas.drawArc(rect, 0, math.pi * 2, false, paint);
      return;
    }
    double angle = -math.pi / 2;
    for (final slice in slices) {
      if (slice.value <= 0) continue;
      final sweep = slice.value / total * math.pi * 2;
      paint.color = slice.color;
      canvas.drawArc(rect, angle, sweep, false, paint);
      angle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant DonutPainter oldDelegate) => true;
}
