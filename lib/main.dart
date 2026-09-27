import 'package:flutter/material.dart';

void main() {
  runApp(const ExpenseManagerApp());
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1769E0),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F9FC),
      ),
      home: const WelcomePage(),
    );
  }
}


class TransactionData {
  final int id;
  final String title;
  final String category;
  final DateTime date;
  final double amount;
  final String type;
  final IconData icon;
  final Color color;

  const TransactionData({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.amount,
    required this.type,
    required this.icon,
    required this.color,
  });
}

// =====================================================
// BUỔI 2 - WELCOME
// =====================================================

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF2FF),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    size: 65,
                    color: Color(0xFF1769E0),
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  'Expense Manager',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Ứng dụng quản lý thu chi cá nhân',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 35),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HomePage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1769E0),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
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
              ],
            ),
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


  final List<TransactionData> transactions = [
    TransactionData(
      id: 1,
      title: 'Ăn trưa',
      category: 'Ăn uống',
      date: DateTime(2024, 9, 3),
      amount: 50000,
      type: 'expense',
      icon: Icons.restaurant,
      color: const Color(0xFFFF6D00),
    ),

    TransactionData(
      id: 2,
      title: 'Xăng xe',
      category: 'Di chuyển',
      date: DateTime(2024, 9, 3),
      amount: 100000,
      type: 'expense',
      icon: Icons.directions_car,
      color: const Color(0xFF2196F3),
    ),

    TransactionData(
      id: 3,
      title: 'Lương tháng 9',
      category: 'Thu nhập',
      date: DateTime(2024, 9, 1),
      amount: 8000000,
      type: 'income',
      icon: Icons.attach_money,
      color: const Color(0xFF2EAD4B),
    ),

    TransactionData(
      id: 4,
      title: 'Mua sắm',
      category: 'Mua sắm',
      date: DateTime(2024, 8, 31),
      amount: 300000,
      type: 'expense',
      icon: Icons.shopping_cart,
      color: const Color(0xFF9C27B0),
    ),

    TransactionData(
      id: 5,
      title: 'Học phí',
      category: 'Giáo dục',
      date: DateTime(2024, 8, 30),
      amount: 500000,
      type: 'expense',
      icon: Icons.school,
      color: const Color(0xFF009688),
    ),
  ];


  double get totalIncome {
    double total = 0;

    for (final transaction in transactions) {
      if (transaction.type == 'income') {
        total += transaction.amount;
      }
    }

    return total;
  }


  double get totalExpense {
    double total = 0;

    for (final transaction in transactions) {
      if (transaction.type == 'expense') {
        total += transaction.amount;
      }
    }

    return total;
  }


  double get balance {
    return totalIncome - totalExpense;
  }


  String formatMoney(double amount) {
    final String value = amount
        .toStringAsFixed(0)
        .replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => '.',
    );

    return '$value đ';
  }



  Future<void> addTransaction() async {
    final TransactionData? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const TransactionFormPage(),
      ),
    );

    if (result != null) {
      setState(() {
        transactions.insert(0, result);
      });
    }
  }


  void deleteTransaction(int index) {
    setState(() {
      transactions.removeAt(index);
    });
  }


  Widget homeContent() {
    return SafeArea(
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              16,
              10,
              16,
              100,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Header(),

                const SizedBox(height: 20),

                BalanceCard(
                  balance: balance,
                  formatMoney: formatMoney,
                ),

                const SizedBox(height: 24),

                SummarySection(
                  totalIncome: totalIncome,
                  totalExpense: totalExpense,
                  formatMoney: formatMoney,
                ),

                const SizedBox(height: 30),

                TransactionHeader(
                  onSeeAll: () {
                    setState(() {
                      currentIndex = 1;
                    });
                  },
                ),

                const SizedBox(height: 12),

                TransactionList(
                  transactions: transactions,
                  formatMoney: formatMoney,
                  onDelete: deleteTransaction,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget transactionPage() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          16,
          20,
          16,
          10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Giao dịch',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              '${transactions.length} giao dịch',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: transactions.isEmpty
                  ? const Center(
                child: Text(
                  'Chưa có giao dịch',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              )
                  : ListView.separated(
                itemCount: transactions.length,
                separatorBuilder: (_, __) {
                  return const SizedBox(height: 8);
                },
                itemBuilder: (context, index) {
                  return TransactionItem(
                    transaction: transactions[index],
                    formatMoney: formatMoney,
                    onDelete: () {
                      deleteTransaction(index);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget statisticsPage() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thống kê',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'Tổng quan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 25),

                  statisticRow(
                    'Tổng thu nhập',
                    totalIncome,
                    Colors.green,
                    Icons.arrow_downward,
                  ),

                  const Divider(height: 30),

                  statisticRow(
                    'Tổng chi tiêu',
                    totalExpense,
                    Colors.red,
                    Icons.arrow_upward,
                  ),

                  const Divider(height: 30),

                  statisticRow(
                    'Số dư',
                    balance,
                    const Color(0xFF1769E0),
                    Icons.account_balance_wallet,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget statisticRow(
      String title,
      double amount,
      Color color,
      IconData icon,
      ) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.12),
          child: Icon(
            icon,
            color: color,
          ),
        ),

        const SizedBox(width: 15),

        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        Text(
          formatMoney(amount),
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    Widget page;

    if (currentIndex == 0) {
      page = homeContent();
    } else if (currentIndex == 1) {
      page = transactionPage();
    } else {
      page = statisticsPage();
    }

    return Scaffold(
      body: page,

      floatingActionButton: currentIndex == 0
          ? FloatingActionButton(
        backgroundColor: const Color(0xFF1769E0),
        foregroundColor: Colors.white,
        onPressed: addTransaction,
        child: const Icon(
          Icons.add,
          size: 32,
        ),
      )
          : null,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,

        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        selectedItemColor: const Color(0xFF1769E0),
        unselectedItemColor: const Color(0xFF263238),
        type: BottomNavigationBarType.fixed,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Giao dịch',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart_outline),
            activeIcon: Icon(Icons.pie_chart),
            label: 'Thống kê',
          ),
        ],
      ),
    );
  }
}


class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.menu,
            size: 30,
          ),
        ),

        const SizedBox(width: 5),

        const Expanded(
          child: Text(
            'Quản lý thu chi',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.notifications_none,
                size: 30,
              ),
            ),

            Positioned(
              right: 2,
              top: 0,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text(
                  '3',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// =====================================================
// BALANCE CARD
// =====================================================

class BalanceCard extends StatelessWidget {
  final double balance;
  final String Function(double) formatMoney;

  const BalanceCard({
    super.key,
    required this.balance,
    required this.formatMoney,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4D8CF7),
            Color(0xFF1769E0),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Text(
                      'SỐ DƯ HIỆN TẠI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(width: 8),

                    Icon(
                      Icons.visibility,
                      color: Colors.white,
                      size: 17,
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Text(
                  formatMoney(balance),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const Spacer(),

                Row(
                  children: [
                    Container(
                      width: 25,
                      height: 7,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                    ),

                    const SizedBox(width: 7),

                    ...List.generate(
                      3,
                          (_) => Padding(
                        padding:
                        const EdgeInsets.only(right: 7),
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: Colors.white
                                .withOpacity(0.4),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Positioned(
            right: 15,
            bottom: 25,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                size: 70,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// SUMMARY
// =====================================================

class SummarySection extends StatelessWidget {
  final double totalIncome;
  final double totalExpense;
  final String Function(double) formatMoney;

  const SummarySection({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
    required this.formatMoney,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SummaryCard(
            title: 'TỔNG THU NHẬP',
            amount: formatMoney(totalIncome),
            icon: Icons.arrow_downward,
            iconColor: const Color(0xFF2EAD4B),
            backgroundColor: const Color(0xFFEAF8EB),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: SummaryCard(
            title: 'TỔNG CHI TIÊU',
            amount: formatMoney(totalExpense),
            icon: Icons.arrow_upward,
            iconColor: const Color(0xFFE53935),
            backgroundColor: const Color(0xFFFFEFF0),
          ),
        ),
      ],
    );
  }
}

class SummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  const SummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Fixed height removed: it was smaller than the content needed,
      // which caused the "bottom overflowed by 9.0 pixels" warning.
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor:
            iconColor.withOpacity(0.18),
            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF374151),
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            amount,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// =====================================================
// TRANSACTION HEADER
// =====================================================

class TransactionHeader extends StatelessWidget {
  final VoidCallback onSeeAll;

  const TransactionHeader({
    super.key,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Giao dịch gần đây',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),

        const Spacer(),

        TextButton(
          onPressed: onSeeAll,
          child: const Text(
            'Xem tất cả',
            style: TextStyle(
              color: Color(0xFF1769E0),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

// =====================================================
// TRANSACTION LIST
// =====================================================

class TransactionList extends StatelessWidget {
  final List<TransactionData> transactions;
  final String Function(double) formatMoney;
  final Function(int) onDelete;

  const TransactionList({
    super.key,
    required this.transactions,
    required this.formatMoney,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics:
        const NeverScrollableScrollPhysics(),
        itemCount: transactions.length,
        separatorBuilder: (_, __) {
          return const Divider(
            height: 1,
            indent: 15,
            endIndent: 15,
          );
        },
        itemBuilder: (context, index) {
          return TransactionItem(
            transaction: transactions[index],
            formatMoney: formatMoney,
            onDelete: () {
              onDelete(index);
            },
          );
        },
      ),
    );
  }
}

// =====================================================
// TRANSACTION ITEM
// =====================================================

class TransactionItem extends StatelessWidget {
  final TransactionData transaction;
  final String Function(double) formatMoney;
  final VoidCallback onDelete;

  const TransactionItem({
    super.key,
    required this.transaction,
    required this.formatMoney,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isIncome =
        transaction.type == 'income';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: transaction.color,
            child: Icon(
              transaction.icon,
              color: Colors.white,
              size: 21,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Row(
                  children: [
                    Text(
                      transaction.category,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF667085),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Text(
                      '${transaction.date.day.toString().padLeft(2, '0')}/'
                          '${transaction.date.month.toString().padLeft(2, '0')}/'
                          '${transaction.date.year}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF667085),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 5),

          Column(
            crossAxisAlignment:
            CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+' : '-'}'
                    '${formatMoney(transaction.amount)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isIncome
                      ? const Color(0xFF2EAD4B)
                      : const Color(0xFFE53935),
                ),
              ),

              IconButton(
                padding: EdgeInsets.zero,
                constraints:
                const BoxConstraints(),
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline,
                  size: 17,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =====================================================
// FORM - KẾT HỢP BUỔI 3
// =====================================================

class TransactionFormPage extends StatefulWidget {
  const TransactionFormPage({super.key});

  @override
  State<TransactionFormPage> createState() =>
      _TransactionFormPageState();
}

class _TransactionFormPageState
    extends State<TransactionFormPage> {

  final GlobalKey<FormState> _formKey =
  GlobalKey<FormState>();

  final TextEditingController titleController =
  TextEditingController();

  final TextEditingController amountController =
  TextEditingController();

  String type = 'expense';

  String category = 'Ăn uống';

  DateTime selectedDate = DateTime.now();

  final List<String> categories = [
    'Ăn uống',
    'Di chuyển',
    'Mua sắm',
    'Giáo dục',
    'Giải trí',
    'Thu nhập',
    'Khác',
  ];

  // ===================================================
  // CHỌN NGÀY
  // ===================================================

  Future<void> selectDate() async {
    final DateTime? picked =
    await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // ===================================================
  // LƯU
  // ===================================================

  void saveTransaction() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final double amount =
    double.parse(amountController.text.trim());

    IconData icon;
    Color color;

    if (type == 'income') {
      icon = Icons.attach_money;
      color = const Color(0xFF2EAD4B);
    } else {
      switch (category) {
        case 'Ăn uống':
          icon = Icons.restaurant;
          color = const Color(0xFFFF6D00);
          break;

        case 'Di chuyển':
          icon = Icons.directions_car;
          color = const Color(0xFF2196F3);
          break;

        case 'Mua sắm':
          icon = Icons.shopping_cart;
          color = const Color(0xFF9C27B0);
          break;

        case 'Giáo dục':
          icon = Icons.school;
          color = const Color(0xFF009688);
          break;

        default:
          icon = Icons.receipt_long;
          color = const Color(0xFF607D8B);
      }
    }

    final transaction = TransactionData(
      id: DateTime.now()
          .millisecondsSinceEpoch,
      title: titleController.text.trim(),
      category: type == 'income'
          ? 'Thu nhập'
          : category,
      date: selectedDate,
      amount: amount,
      type: type,
      icon: icon,
      color: color,
    );

    Navigator.pop(
      context,
      transaction,
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    super.dispose();
  }

  // ===================================================
  // BUILD FORM
  // ===================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thêm giao dịch',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Form(
        key: _formKey,

        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // LOẠI GIAO DỊCH
            const Text(
              'Loại giao dịch',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text(
                      'Thu nhập',
                    ),
                    selected: type == 'income',
                    onSelected: (_) {
                      setState(() {
                        type = 'income';
                      });
                    },
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ChoiceChip(
                    label: const Text(
                      'Chi tiêu',
                    ),
                    selected: type == 'expense',
                    onSelected: (_) {
                      setState(() {
                        type = 'expense';
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // TÊN
            TextFormField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Tên giao dịch',
                prefixIcon: Icon(Icons.edit),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Vui lòng nhập tên giao dịch';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            // SỐ TIỀN
            TextFormField(
              controller: amountController,
              keyboardType:
              TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Số tiền',
                prefixIcon:
                Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Vui lòng nhập số tiền';
                }

                final amount =
                double.tryParse(value);

                if (amount == null ||
                    amount <= 0) {
                  return 'Số tiền không hợp lệ';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            // DANH MỤC
            if (type == 'expense')
              DropdownButtonFormField<String>(
                value: category,
                decoration:
                const InputDecoration(
                  labelText: 'Danh mục',
                  border: OutlineInputBorder(),
                ),
                items: categories
                    .where(
                      (item) =>
                  item != 'Thu nhập',
                )
                    .map(
                      (item) {
                    return DropdownMenuItem(
                      value: item,
                      child: Text(item),
                    );
                  },
                )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      category = value;
                    });
                  }
                },
              ),

            const SizedBox(height: 16),

            // NGÀY
            InkWell(
              onTap: selectDate,
              child: Container(
                padding:
                const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                  ),
                  borderRadius:
                  BorderRadius.circular(5),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_month,
                    ),

                    const SizedBox(width: 12),

                    Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ngày giao dịch',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          '${selectedDate.day}/'
                              '${selectedDate.month}/'
                              '${selectedDate.year}',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // LƯU
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: saveTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xFF1769E0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Lưu giao dịch',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}