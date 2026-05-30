import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../data/database/app_database.dart';
import '../data/database/database_provider.dart';
import '../services/google_places_service.dart';
import 'create_activity_page.dart';

class TripItineraryPage extends StatefulWidget {
  final Trip trip;

  const TripItineraryPage({
    super.key,
    required this.trip,
  });

  @override
  State<TripItineraryPage> createState() =>
      _TripItineraryPageState();
}

class _TripItineraryPageState
    extends State<TripItineraryPage> {
  LatLng? destinoInicial;
  bool carregandoDestino = true;

  Set<Marker> marcadores = {};
  Set<Marker> todosMarcadores = {};

  int _ultimaQuantidadeAtividades = -1;

  GoogleMapController? mapController;

  int? atividadeSelecionada;

  bool mostrarApenasSelecionado = false;

  @override
  void initState() {
    super.initState();
    carregarDestino();
  }

  Future<void> carregarDestino() async {
    if (widget.trip.destination == null ||
        widget.trip.destination!.isEmpty) {
      setState(() {
        carregandoDestino = false;
      });
      return;
    }

    final coords =
    await GooglePlacesService.getCoordinates(
      widget.trip.destination!,
    );

    if (!mounted) return;

    setState(() {
      if (coords != null) {
        destinoInicial = LatLng(
          coords['lat']!,
          coords['lng']!,
        );
      }

      carregandoDestino = false;
    });
  }

  Future<void> atualizarMarcadores(
      List<Activity> atividades) async {
    final Set<Marker> novosMarcadores = {};

    for (final atividade in atividades) {
      final coords =
      await GooglePlacesService.getCoordinates(
        atividade.local,
      );

      if (coords == null) continue;

      novosMarcadores.add(
        Marker(
          markerId: MarkerId(
            atividade.id.toString(),
          ),
          position: LatLng(
            coords['lat']!,
            coords['lng']!,
          ),
          infoWindow: InfoWindow(
            title: atividade.nome,
            snippet: atividade.local,
          ),
        ),
      );
    }

    if (!mounted) return;

    setState(() {
      todosMarcadores = novosMarcadores;

      if (!mostrarApenasSelecionado) {
        marcadores = novosMarcadores;
      }
    });
  }

  Future<void> focarAtividade(
      Activity atividade) async {
    final coords =
    await GooglePlacesService.getCoordinates(
      atividade.local,
    );

    if (coords == null ||
        mapController == null) {
      return;
    }

    await mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(
          coords['lat']!,
          coords['lng']!,
        ),
        17,
      ),
    );

    final marker = Marker(
      markerId: MarkerId(
        atividade.id.toString(),
      ),
      position: LatLng(
        coords['lat']!,
        coords['lng']!,
      ),
      infoWindow: InfoWindow(
        title: atividade.nome,
        snippet: atividade.local,
      ),
    );

    if (!mounted) return;

    setState(() {
      atividadeSelecionada =
          atividade.id;

      mostrarApenasSelecionado = true;

      marcadores = {marker};
    });
  }

  void mostrarTodosMarcadores() {
    setState(() {
      atividadeSelecionada = null;

      mostrarApenasSelecionado = false;

      marcadores = todosMarcadores;
    });
  }

  Future<void> abrirCriarAtividade() async {
    final novaAtividade =
    await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) =>
        const CreateActivityPage(),
      ),
    );

    if (novaAtividade == null) {
      return;
    }

    try {
      await appDatabase.activitiesDao.insertActivity(
        ActivitiesCompanion.insert(
          tripId: widget.trip.id,
          nome: novaAtividade['nome'],
          dataHora: novaAtividade['dataHora'],
          local: novaAtividade['local'],
        ),
      );
    } catch (e) {
      debugPrint(
        'ERRO AO INSERIR ATIVIDADE: $e',
      );
    }
  }

  String formatarData(DateTime data) {
    final dia =
    data.day.toString().padLeft(2, '0');
    final mes =
    data.month.toString().padLeft(2, '0');
    final ano = data.year.toString();

    return '$dia/$mes/$ano';
  }

  String formatarHora(DateTime data) {
    final hora =
    data.hour.toString().padLeft(2, '0');
    final minuto =
    data.minute.toString().padLeft(2, '0');

    return '$hora:$minuto';
  }

  @override
  Widget build(BuildContext context) {
    final tripId = widget.trip.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Itinerário - ${widget.trip.name}',
        ),
      ),
      body: carregandoDestino
          ? const Center(
        child:
        CircularProgressIndicator(),
      )
          : StreamBuilder<List<Activity>>(
        stream: appDatabase
            .activitiesDao
            .watchActivitiesForTrip(
          tripId,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
              CircularProgressIndicator(),
            );
          }

          final atividades =
              snapshot.data ?? [];

          if (_ultimaQuantidadeAtividades !=
              atividades.length) {
            _ultimaQuantidadeAtividades =
                atividades.length;

            Future.microtask(() {
              atualizarMarcadores(
                atividades,
              );
            });
          }

          return Column(
            children: [
              SizedBox(
                height: 300,
                child: GoogleMap(
                  onMapCreated:
                      (controller) {
                    mapController =
                        controller;
                  },
                  initialCameraPosition:
                  CameraPosition(
                    target:
                    destinoInicial ??
                        const LatLng(
                          48.8566,
                          2.3522,
                        ),
                    zoom: 12,
                  ),
                  markers: marcadores,
                ),
              ),

              if (mostrarApenasSelecionado)
                Padding(
                  padding:
                  const EdgeInsets.all(8),
                  child:
                  ElevatedButton.icon(
                    onPressed:
                    mostrarTodosMarcadores,
                    icon: const Icon(
                      Icons.map,
                    ),
                    label: const Text(
                      'Mostrar todos os pontos',
                    ),
                  ),
                ),

              Expanded(
                child: atividades.isEmpty
                    ? Center(
                  child: Text(
                    widget.trip
                        .destination !=
                        null
                        ? 'Destino da viagem: ${widget.trip.destination}'
                        : 'Nenhuma atividade adicionada.',
                  ),
                )
                    : ListView.builder(
                  itemCount:
                  atividades.length,
                  itemBuilder:
                      (context, index) {
                    final atividade =
                    atividades[
                    index];

                    return Card(
                      color:
                      atividadeSelecionada ==
                          atividade.id
                          ? Colors.blue
                          .withAlpha(
                          25)
                          : null,
                      margin:
                      const EdgeInsets
                          .symmetric(
                        horizontal:
                        12,
                        vertical: 8,
                      ),
                      child:
                      ListTile(
                        onTap: () {
                          focarAtividade(
                            atividade,
                          );
                        },
                        leading:
                        const Icon(
                          Icons
                              .location_on,
                        ),
                        title: Text(
                          atividade
                              .nome,
                        ),
                        subtitle:
                        Text(
                          '${formatarData(atividade.dataHora)} às ${formatarHora(atividade.dataHora)}\nLocal: ${atividade.local}',
                        ),
                        isThreeLine:
                        true,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton:
      FloatingActionButton(
        onPressed:
        abrirCriarAtividade,
        child: const Icon(Icons.add),
      ),
    );
  }
}