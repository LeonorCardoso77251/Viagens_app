import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/database/app_database.dart';
import '../data/database/database_provider.dart';
import '../data/database/dao/expenses_dao.dart';

import 'create_expense_page.dart';

class TripExpensesPage extends StatefulWidget {
  final Trip trip;

  const TripExpensesPage({
    super.key,
    required this.trip,
  });

  @override
  State<TripExpensesPage> createState() =>
      _TripExpensesPageState();
}

class _TripExpensesPageState
    extends State<TripExpensesPage> {

  ExpensesDao get expensesDao =>
      appDatabase.expensesDao;

  Future<void> abrirCriarDespesa() async {

    final novaDespesa =
    await Navigator.push<
        Map<String, dynamic>
    >(
      context,

      MaterialPageRoute(
        builder: (context) =>
        const CreateExpensePage(),
      ),
    );

    if (novaDespesa == null) {
      return;
    }

    // UTILIZADOR FIREBASE
    final firebaseUser =
        FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Utilizador não autenticado.',
          ),
        ),
      );

      return;
    }

    // UTILIZADOR SQLITE
    final user =
    await appDatabase.usersDao
        .getUserByFirebaseUid(
      firebaseUser.uid,
    );

    if (user == null) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Erro ao carregar utilizador.',
          ),
        ),
      );

      return;
    }

    final amountCents =
    novaDespesa['amountCents'] as int;

    final title =
    novaDespesa['title'] as String;

    final description =
    novaDespesa['description']
    as String?;

    // CRIAR DESPESA
    await expensesDao.createExpense(

      tripId: widget.trip.id,

      paidBy: user.id,

      title: title,

      description: description,

      amountCents: amountCents,

      splits: [

        ExpenseSplitInput(
          userId: user.id,

          amountCents:
          amountCents,
        ),
      ],
    );
  }

  String eurosFromCents(int cents) {

    return
      '€${(cents / 100).toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {

    final tripId = widget.trip.id;

    return Scaffold(

      appBar: AppBar(
        title: Text(
          'Despesas - ${widget.trip.name}',
        ),
      ),

      body: Column(
        children: [

          // TOTAL
          StreamBuilder<int>(

            stream: expensesDao
                .watchTotalExpensesForTrip(
              tripId,
            ),

            builder: (
                context,
                snapshot,
                ) {

              final totalCents =
                  snapshot.data ?? 0;

              return Container(

                width: double.infinity,

                padding:
                const EdgeInsets.all(
                  16,
                ),

                color:
                Colors.blue.shade50,

                child: Text(
                  'Total: ${eurosFromCents(totalCents)}',

                  style:
                  const TextStyle(
                    fontSize: 18,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              );
            },
          ),

          // LISTA DESPESAS
          Expanded(

            child:
            StreamBuilder<List<Expense>>(

              stream: expensesDao
                  .watchExpensesForTrip(
                tripId,
              ),

              builder: (
                  context,
                  snapshot,
                  ) {

                // LOADING
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {

                  return const Center(
                    child:
                    CircularProgressIndicator(),
                  );
                }

                final despesas =
                    snapshot.data ?? [];

                // SEM DESPESAS
                if (despesas.isEmpty) {

                  return const Center(
                    child: Text(
                      'Nenhuma despesa registada.',
                    ),
                  );
                }

                // LISTA
                return ListView.builder(

                  itemCount:
                  despesas.length,

                  itemBuilder: (
                      context,
                      index,
                      ) {

                    final despesa =
                    despesas[index];

                    return Card(

                      margin:
                      const EdgeInsets.all(
                        10,
                      ),

                      child: ListTile(

                        title:
                        Text(despesa.title),

                        subtitle: Text(

                          [
                            if (despesa.description !=
                                null &&
                                despesa.description!
                                    .isNotEmpty)
                              despesa.description!,

                            'Pago por: ${despesa.paidBy}',
                          ].join('\n'),
                        ),

                        trailing: Text(

                          eurosFromCents(
                            despesa.amountCents,
                          ),

                          style:
                          const TextStyle(
                            fontWeight:
                            FontWeight.bold,
                          ),
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

      floatingActionButton:
      FloatingActionButton(

        onPressed:
        abrirCriarDespesa,

        child:
        const Icon(Icons.add),
      ),
    );
  }
}