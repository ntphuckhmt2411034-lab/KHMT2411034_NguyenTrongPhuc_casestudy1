import 'dart:math' as math;
import 'package:flutter/material.dart';
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
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const Spacer(flex: 3),
              Container(
                height: 110,
                width: 110,
                decoration: BoxDecoration(
                  color: const Color(0xFFE9F2FF),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(Icons.account_balance_wallet_rounded,
                    size: 72, color: AppColors.blue),
              ),
              const SizedBox(height: 26),
              const Text('Expense Manager',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800,
                      color: AppColors.ink)),
              const SizedBox(height: 13),
              const Text('Quản lý thu chi cá nhân\nđơn giản và hiệu quả',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: AppColors.muted,
                      height: 1.6)),
              const Spacer(flex: 4),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomePage()),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Bắt đầu',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 25),
            ],
          ),
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
    if (result != null && mounted) setState(() => activeFilter = result);
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
          ? FloatingActionButton(
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

  Widget dashboardPage() {
    final recent = transactions.take(5).toList();
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: refreshAll,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF3187FF), AppColors.darkBlue],
                    begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 35),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Xin chào!', style: TextStyle(color: Colors.white,
                          fontWeight: FontWeight.w800, fontSize: 23)),
                      SizedBox(height: 3),
                      Text('Hôm nay là một ngày tuyệt vời!',
                          style: TextStyle(color: Color(0xFFE6F1FF), fontSize: 12)),
                    ],
                  )),
                  IconButton(
                    onPressed: () => setState(() => currentIndex = 3),
                    icon: const CircleAvatar(
                      backgroundColor: Color(0xFF73B2FF),
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                  ),
                ]),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white,
                      borderRadius: BorderRadius.circular(17)),
                  child: Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Số dư hiện tại',
                              style: TextStyle(color: AppColors.muted, fontSize: 13)),
                          const SizedBox(height: 8),
                          FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft,
                              child: Text(formatMoney(balance),
                                  style: const TextStyle(fontSize: 25,
                                      color: AppColors.ink, fontWeight: FontWeight.w800))),
                        ])),
                    Container(width: 48, height: 48,
                        decoration: BoxDecoration(color: const Color(0xFFEAF2FF),
                            borderRadius: BorderRadius.circular(14)),
                        child: const Icon(Icons.account_balance_wallet,
                            color: AppColors.blue, size: 27)),
                  ]),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: summaryCard('Thu nhập', totalIncome,
                      Icons.arrow_upward, AppColors.income, const Color(0xFFE3F9ED))),
                  const SizedBox(width: 12),
                  Expanded(child: summaryCard('Chi tiêu', totalExpense,
                      Icons.arrow_downward, AppColors.expense, const Color(0xFFFFE9EC))),
                ]),
                if (monthlyBudget > 0) ...[
                  const SizedBox(height: 18),
                  budgetCard(),
                ],
                const SizedBox(height: 26),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Chi tiêu gần đây', style: TextStyle(fontSize: 19,
                      fontWeight: FontWeight.w800, color: AppColors.ink)),
                  TextButton(onPressed: () => setState(() => currentIndex = 1),
                      child: const Text('Xem tất cả')),
                ]),
                const SizedBox(height: 7),
                if (recent.isEmpty)
                  emptyState('Chưa có giao dịch', 'Bấm + để thêm khoản thu hoặc chi đầu tiên')
                else
                  ...recent.map((t) => TransactionTile(
                    transaction: t,
                    onTap: () => editTransaction(t),
                    onDelete: () => deleteTransaction(t),
                  )),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget summaryCard(String label, double amount, IconData icon,
      Color accent, Color bg) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(17)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CircleAvatar(radius: 18, backgroundColor: Colors.white.withOpacity(0.8),
            child: Icon(icon, size: 20, color: accent)),
        const SizedBox(height: 12),
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.ink)),
        const SizedBox(height: 6),
        FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft,
            child: Text(formatMoney(amount),
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: accent))),
      ]),
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

  Widget transactionPage() {
    final list = filteredTransactions;
    return SafeArea(child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Giao dịch', style: TextStyle(fontSize: 27,
            fontWeight: FontWeight.w800, color: AppColors.ink)),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(child: TextField(
            controller: searchController,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Tìm kiếm giao dịch...',
              hintStyle: TextStyle(fontSize: 13),
            ),
          )),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            onPressed: openFilters,
            icon: const Icon(Icons.tune),
            tooltip: 'Bộ lọc',
          ),
        ]),
        const SizedBox(height: 13),
        Row(children: [
          Expanded(child: typePill('all', 'Tất cả')),
          const SizedBox(width: 7),
          Expanded(child: typePill('income', 'Thu nhập')),
          const SizedBox(width: 7),
          Expanded(child: typePill('expense', 'Chi tiêu')),
        ]),
        const SizedBox(height: 12),
        Text('${list.length} giao dịch',
            style: const TextStyle(color: AppColors.muted, fontSize: 12)),
        const SizedBox(height: 8),
        Expanded(child: list.isEmpty
            ? emptyState('Không có giao dịch phù hợp',
            'Thử đổi từ khóa, bộ lọc hoặc thêm giao dịch mới')
            : RefreshIndicator(
          onRefresh: refreshAll,
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 90),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final t = list[index];
              return TransactionTile(
                transaction: t,
                onTap: () => editTransaction(t),
                onDelete: () => deleteTransaction(t),
              );
            },
          ),
        )),
      ]),
    ));
  }

  Widget typePill(String type, String text) {
    final isSelected = quickType == type;
    return OutlinedButton(
      onPressed: () => setState(() => quickType = type),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 4),
        backgroundColor: isSelected ? AppColors.blue : Colors.white,
        foregroundColor: isSelected ? Colors.white : AppColors.muted,
        side: BorderSide(color: isSelected ? AppColors.blue : AppColors.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12,
          fontWeight: FontWeight.w600)),
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

  Widget statisticsPage() {
    final periodTransactions = transactions.where((t) => inSelectedPeriod(t.date)).toList();
    final income = periodTransactions.where((t) => t.type == 'income')
        .fold<double>(0, (sum, t) => sum + t.amount);
    final expense = periodTransactions.where((t) => t.type == 'expense')
        .fold<double>(0, (sum, t) => sum + t.amount);
    final byCategory = <String, double>{};
    for (final t in periodTransactions.where((t) => t.type == 'expense')) {
      byCategory.update(t.category, (old) => old + t.amount,
          ifAbsent: () => t.amount);
    }
    final sorted = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final slices = sorted.map((e) => DonutSlice(
        e.value, categoryInfo(e.key, 'expense').color)).toList();

    return SafeArea(child: ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
      children: [
        const Text('Thống kê', style: TextStyle(fontSize: 27,
            fontWeight: FontWeight.w800, color: AppColors.ink)),
        const SizedBox(height: 17),
        Row(children: [
          Expanded(child: periodPill('month', 'Tháng này')),
          const SizedBox(width: 7),
          Expanded(child: periodPill('previous', 'Tháng trước')),
          const SizedBox(width: 7),
          Expanded(child: periodPill('year', 'Năm nay')),
        ]),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.line)),
          child: Column(children: [
            const Text('Phân bổ chi tiêu',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 20),
            SizedBox(height: 208, child: Center(child: SizedBox(
              width: 202, height: 202,
              child: Stack(alignment: Alignment.center, children: [
                CustomPaint(size: const Size(202, 202),
                    painter: DonutPainter(slices)),
                Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text('Tổng chi tiêu',
                      style: TextStyle(fontSize: 12, color: AppColors.muted)),
                  const SizedBox(height: 6),
                  FittedBox(fit: BoxFit.scaleDown,
                      child: Text(formatMoney(expense),
                          style: const TextStyle(fontSize: 18,
                              fontWeight: FontWeight.w800, color: AppColors.ink))),
                ]),
              ]),
            ))),
            const SizedBox(height: 19),
            if (sorted.isEmpty)
              const Text('Chưa có khoản chi trong khoảng thời gian này',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted, fontSize: 13))
            else
              ...sorted.map((entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(children: [
                  Container(width: 11, height: 11,
                      decoration: BoxDecoration(shape: BoxShape.circle,
                          color: categoryInfo(entry.key, 'expense').color)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(entry.key,
                      style: const TextStyle(fontSize: 13))),
                  Text('${(entry.value / expense * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                  const SizedBox(width: 10),
                  Text(formatMoney(entry.value),
                      style: const TextStyle(fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ]),
              )),
          ]),
        ),
        const SizedBox(height: 17),
        Row(children: [
          Expanded(child: summaryCard('Tổng thu', income,
              Icons.arrow_upward, AppColors.income, const Color(0xFFE3F9ED))),
          const SizedBox(width: 10),
          Expanded(child: summaryCard('Tổng chi', expense,
              Icons.arrow_downward, AppColors.expense, const Color(0xFFFFE9EC))),
        ]),
        const SizedBox(height: 17),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.line)),
          child: Row(children: [
            const Icon(Icons.account_balance_wallet_outlined,
                color: AppColors.blue),
            const SizedBox(width: 11),
            const Expanded(child: Text('Chênh lệch thu chi',
                style: TextStyle(fontWeight: FontWeight.w600))),
            Flexible(child: Text(formatMoney(income - expense),
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.w800,
                    color: AppColors.blue))),
          ]),
        ),
      ],
    ));
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

  Widget profilePage() {
    return SafeArea(child: ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
      children: [
        const Text('Cá nhân', style: TextStyle(fontSize: 27,
            fontWeight: FontWeight.w800, color: AppColors.ink)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 24),
          decoration: BoxDecoration(color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.line)),
          child: Row(children: [
            const CircleAvatar(radius: 32,
                backgroundColor: Color(0xFFCEE2FF),
                child: Icon(Icons.person, color: AppColors.blue, size: 40)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(userName, style: const TextStyle(fontSize: 18,
                      fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(userEmail.isEmpty ? 'Chưa cập nhật email' : userEmail,
                      style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                ])),
            IconButton(onPressed: editProfile, tooltip: 'Sửa thông tin',
                icon: const Icon(Icons.edit_outlined, color: AppColors.blue)),
          ]),
        ),
        const SizedBox(height: 20),
        profileAction(Icons.person_outline, 'Thông tin cá nhân', editProfile),
        profileAction(Icons.account_balance_wallet_outlined,
            'Cài đặt ngân sách', editBudget),
        profileAction(Icons.refresh, 'Làm mới dữ liệu', refreshAll),
        const SizedBox(height: 19),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.line)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Tổng quan tài khoản',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            Text('Số giao dịch: ${transactions.length}',
                style: const TextStyle(color: AppColors.muted)),
            const SizedBox(height: 8),
            Text('Ngân sách tháng: ${monthlyBudget > 0 ? formatMoney(monthlyBudget) : 'Chưa thiết lập'}',
                style: const TextStyle(color: AppColors.muted)),
            const SizedBox(height: 8),
            const Text('Dữ liệu được lưu cục bộ bằng SQLite.',
                style: TextStyle(color: AppColors.muted, fontSize: 12)),
          ]),
        ),
      ],
    ));
  }

  Widget profileAction(IconData icon, String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Material(color: Colors.white, borderRadius: BorderRadius.circular(14),
        child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(14),
          child: Container(padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(border: Border.all(color: AppColors.line),
                borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              Icon(icon, color: AppColors.blue, size: 22),
              const SizedBox(width: 14),
              Expanded(child: Text(title, style: const TextStyle(
                  fontWeight: FontWeight.w600))),
              const Icon(Icons.chevron_right, color: AppColors.muted),
            ]),
          ),
        ),
      ),
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

  const TransactionFilter({
    this.type = 'all', this.category = 'all', this.fromDate, this.toDate,
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
  DateTime? fromDate;
  DateTime? toDate;

  @override
  void initState() {
    super.initState();
    type = widget.initial.type;
    category = widget.initial.category;
    fromDate = widget.initial.fromDate;
    toDate = widget.initial.toDate;
  }

  Future<void> selectRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: fromDate != null && toDate != null
          ? DateTimeRange(start: fromDate!, end: toDate!) : null,
    );
    if (range != null && mounted) {
      setState(() {
        fromDate = range.start;
        toDate = range.end;
      });
    }
  }

  void apply() {
    Navigator.pop(context, TransactionFilter(
      type: type, category: category, fromDate: fromDate, toDate: toDate,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Bộ lọc',
          style: TextStyle(fontWeight: FontWeight.w800))),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Loại giao dịch',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          filterChoice('all', 'Tất cả'),
          filterChoice('income', 'Thu nhập'),
          filterChoice('expense', 'Chi tiêu'),
          const SizedBox(height: 20),
          const Text('Danh mục',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: category,
            items: ['all', ...expenseCategories, 'Thu nhập']
                .map((value) => DropdownMenuItem(value: value,
                child: Text(value == 'all' ? 'Tất cả danh mục' : value)))
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => category = value);
            },
          ),
          const SizedBox(height: 20),
          const Text('Khoảng ngày',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: selectRange,
            icon: const Icon(Icons.date_range_outlined),
            label: Text(fromDate == null || toDate == null
                ? 'Chọn khoảng ngày' : '${formatDate(fromDate!)} – ${formatDate(toDate!)}'),
          ),
          if (fromDate != null)
            TextButton(onPressed: () => setState(() {
              fromDate = null;
              toDate = null;
            }), child: const Text('Bỏ lọc ngày')),
          const Spacer(),
          Row(children: [
            Expanded(child: OutlinedButton(
              onPressed: () => Navigator.pop(context, const TransactionFilter()),
              child: const Text('Đặt lại'),
            )),
            const SizedBox(width: 12),
            Expanded(child: FilledButton(
              onPressed: apply,
              style: FilledButton.styleFrom(backgroundColor: AppColors.blue),
              child: const Text('Áp dụng'),
            )),
          ]),
          const SizedBox(height: 15),
        ]),
      ),
    );
  }

  Widget filterChoice(String value, String label) {
    return InkWell(
      onTap: () => setState(() {
        type = value;
        if (type == 'income') category = 'all';
      }),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(children: [
          Checkbox(value: type == value, onChanged: (_) => setState(() {
            type = value;
            if (type == 'income') category = 'all';
          })),
          Text(label, style: const TextStyle(fontSize: 14)),
        ]),
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
