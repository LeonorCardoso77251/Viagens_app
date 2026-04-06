import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../models/trip.dart';
import 'create_expense_page.dart';

class TripExpensesPage extends StatefulWidget {
  final Trip trip;

  const TripExpensesPage({super.key, required this.trip});

  @override
  State<TripExpensesPage> createState() => _TripExpensesPageState();
}

class _TripExpensesPageState extends State<TripExpensesPage> {
  final List<Expense> despesas = [];

  Future<void> abrirCriarDespesa() async {
    final Expense? novaDespesa = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateExpensePage(),
      ),
    );

    if (novaDespesa != null) {
      setState(() {
        despesas.add(novaDespesa);
      });
    }
  }

  double get total =>
      despesas.fold(0, (sum, item) => sum + item.valor);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Despesas - ${widget.trip.nome}'),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Text(
              'Total: €${total.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: despesas.isEmpty
                ? const Center(
                    child: Text('Nenhuma despesa registada.'),
                  )
                : ListView.builder(
                    itemCount: despesas.length,
                    itemBuilder: (context, index) {
                      final despesa = despesas[index];

                      return Card(
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          title: Text(despesa.descricao),
                          subtitle: Text('Pago por: ${despesa.pagoPor}'),
                          trailing: Text(
                            '€${despesa.valor.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
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