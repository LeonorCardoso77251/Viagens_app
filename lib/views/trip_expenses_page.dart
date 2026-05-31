import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/database/app_database.dart';
import '../data/database/database_provider.dart';
import '../data/database/dao/expenses_dao.dart';

import 'create_expense_page.dart';

class TripExpensesPage extends StatefulWidget {
  final Trip trip;

  const TripExpensesPage({super.key, required this.trip});

  @override
  State<TripExpensesPage> createState() => _TripExpensesPageState();
}

class _TripExpensesPageState extends State<TripExpensesPage> {
  ExpensesDao get expensesDao => appDatabase.expensesDao;

  Future<void> abrirCriarDespesa() async {
    final participantes = await appDatabase.tripsDao.getUsersForTrip(
      widget.trip.id,
    );

    if (participantes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Esta viagem não tem participantes.')),
      );
      return;
    }

    final novaDespesa = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => CreateExpensePage(
          participants: participantes,
        ),
      ),
    );

    if (novaDespesa == null) {
      return;
    }

    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Utilizador não autenticado.')),
      );
      return;
    }

    final user = await appDatabase.usersDao.getUserByFirebaseUid(
      firebaseUser.uid,
    );

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar utilizador.')),
      );
      return;
    }

    final amountCents = novaDespesa['amountCents'] as int;
    final title = novaDespesa['title'] as String;
    final description = novaDespesa['description'] as String?;
    final splitUserIds = novaDespesa['splitUserIds'] as List<int>;

    final baseAmount = amountCents ~/ splitUserIds.length;
    final remainder = amountCents % splitUserIds.length;

    final splits = <ExpenseSplitInput>[];

    for (var i = 0; i < splitUserIds.length; i++) {
      splits.add(
        ExpenseSplitInput(
          userId: splitUserIds[i],
          amountCents: baseAmount + (i < remainder ? 1 : 0),
        ),
      );
    }

    await expensesDao.createExpense(
      tripId: widget.trip.id,
      paidBy: user.id,
      title: title,
      description: description,
      amountCents: amountCents,
      splits: splits,
    );
  }

  String eurosFromCents(int cents) {
    return '€${(cents / 100).toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final tripId = widget.trip.id;

    return Scaffold(
      appBar: AppBar(title: Text('Despesas - ${widget.trip.name}')),
      body: Column(
        children: [
          StreamBuilder<int>(
            stream: expensesDao.watchTotalExpensesForTrip(tripId),
            builder: (context, snapshot) {
              final totalCents = snapshot.data ?? 0;

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.blue.shade50,
                child: Text(
                  'Total: ${eurosFromCents(totalCents)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
          Expanded(
            child: StreamBuilder<List<ExpenseWithPayer>>(
              stream: expensesDao.watchExpensesWithPayerForTrip(tripId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final despesas = snapshot.data ?? [];

                if (despesas.isEmpty) {
                  return const Center(
                    child: Text('Nenhuma despesa registada.'),
                  );
                }

                return ListView.builder(
                  itemCount: despesas.length,
                  itemBuilder: (context, index) {
                    final items = despesas[index];
                    final despesa = items.expense;
                    final payer = items.payer;

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(despesa.title),
                        subtitle: Text(
                          [
                            if (despesa.description != null &&
                                despesa.description!.isNotEmpty)
                              despesa.description!,
                            'Pago por: ${payer.name}',
                          ].join('\n'),
                        ),
                        trailing: Text(
                          eurosFromCents(despesa.amountCents),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: abrirCriarDespesa,
        child: const Icon(Icons.add),
      ),
    );
  }
}