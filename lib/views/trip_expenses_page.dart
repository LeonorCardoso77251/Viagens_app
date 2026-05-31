import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

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

    final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;

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

  Map<int, int> calcularSaldos(List<ExpenseWithDetails> despesas) {
    final saldos = <int, int>{};

    for (final item in despesas) {
      final payerId = item.expense.paidBy;

      saldos[payerId] = (saldos[payerId] ?? 0) + item.expense.amountCents;

      for (final split in item.splits) {
        saldos[split.userId] = (saldos[split.userId] ?? 0) - split.amountCents;
      }
    }

    return saldos;
  }

  List<String> calcularQuemDeveAQuem({
    required Map<int, int> saldos,
    required Map<int, User> usersById,
  }) {
    final devedores = <MapEntry<int, int>>[];
    final credores = <MapEntry<int, int>>[];

    saldos.forEach((userId, saldo) {
      if (saldo < -1) {
        devedores.add(MapEntry(userId, -saldo));
      } else if (saldo > 1) {
        credores.add(MapEntry(userId, saldo));
      }
    });

    final resultado = <String>[];

    var i = 0;
    var j = 0;

    while (i < devedores.length && j < credores.length) {
      final devedor = devedores[i];
      final credor = credores[j];

      final valor = devedor.value < credor.value
          ? devedor.value
          : credor.value;

      final nomeDevedor = usersById[devedor.key]?.name ?? 'Utilizador';
      final nomeCredor = usersById[credor.key]?.name ?? 'Utilizador';

      resultado.add(
        '$nomeDevedor deve ${eurosFromCents(valor)} a $nomeCredor',
      );

      devedores[i] = MapEntry(devedor.key, devedor.value - valor);
      credores[j] = MapEntry(credor.key, credor.value - valor);

      if (devedores[i].value <= 1) i++;
      if (credores[j].value <= 1) j++;
    }

    return resultado;
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
            child: FutureBuilder<List<User>>(
              future: appDatabase.tripsDao.getUsersForTrip(tripId),
              builder: (context, usersSnapshot) {
                final participantes = usersSnapshot.data ?? [];
                final usersById = {
                  for (final user in participantes) user.id: user,
                };

                return StreamBuilder<List<ExpenseWithDetails>>(
                  stream: expensesDao.watchExpensesWithDetailsForTrip(tripId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting ||
                        usersSnapshot.connectionState ==
                            ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final despesas = snapshot.data ?? [];

                    if (despesas.isEmpty) {
                      return const Center(
                        child: Text('Nenhuma despesa registada.'),
                      );
                    }

                    final saldos = calcularSaldos(despesas);
                    final dividas = calcularQuemDeveAQuem(
                      saldos: saldos,
                      usersById: usersById,
                    );

                    return ListView(
                      padding: const EdgeInsets.all(10),
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Saldos',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...participantes.map((user) {
                                  final saldo = saldos[user.id] ?? 0;

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: Text(
                                      '${user.name}: ${eurosFromCents(saldo)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: saldo >= 0
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Quem deve a quem',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (dividas.isEmpty)
                                  const Text('Não existem dívidas pendentes.')
                                else
                                  ...dividas.map(
                                        (linha) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      child: Text(linha),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Lista de despesas',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...despesas.map((items) {
                          final despesa = items.expense;
                          final payer = items.payer;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              title: Text(despesa.title),
                              subtitle: Text(
                                [
                                  if (despesa.description != null &&
                                      despesa.description!.isNotEmpty)
                                    despesa.description!,
                                  'Pago por: ${payer.name}',
                                  'Dividido por: ${items.splits.length} participante(s)',
                                ].join('\n'),
                              ),
                              trailing: Text(
                                eurosFromCents(despesa.amountCents),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
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