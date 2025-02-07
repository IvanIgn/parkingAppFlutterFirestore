import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // For BLoC
import 'package:parkingapp_user/blocs/parking/parking_bloc.dart';
import 'package:shared/shared.dart';
import 'package:intl/intl.dart';

class OverviewView extends StatefulWidget {
  const OverviewView({super.key});

  @override
  _OverviewViewState createState() => _OverviewViewState();
}

class _OverviewViewState extends State<OverviewView> {
  Parking? parkingInstance;

  @override
  void initState() {
    super.initState();
    _loadParkingData();
    // _refreshParkings();
  }

  Future<void> _loadParkingData() async {
    context.read<ParkingBloc>().add(LoadActiveParkings());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Översikt"),
      ),
      body: BlocBuilder<ParkingBloc, ParkingState>(
        builder: (context, state) {
          if (state is ParkingsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ActiveParkingsLoaded) {
            final parkingInstance =
                state.parkings.isNotEmpty ? state.parkings.first : null;

            return parkingInstance == null
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline, size: 50, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Inga aktiva parkeringar tillgängliga.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildSectionTitle(context, 'Parkeringsinformation:'),
                        const SizedBox(height: 8),
                        buildKeyValue(
                            'Parkerings ID', parkingInstance.id.toString()),
                        buildKeyValue(
                            'Starttid',
                            DateFormat('yyyy-MM-dd HH:mm')
                                .format(parkingInstance.startTime)),
                        buildKeyValue(
                            'Sluttid',
                            DateFormat('yyyy-MM-dd HH:mm')
                                .format(parkingInstance.endTime)),
                        const SizedBox(height: 16),
                        buildSectionTitle(context, 'Fordonsinformation:'),
                        const SizedBox(height: 8),
                        buildKeyValue('Fordons ID',
                            parkingInstance.vehicle!.id.toString()),
                        buildKeyValue(
                            'Reg.nummer', parkingInstance.vehicle!.regNumber),
                        buildKeyValue(
                            'Fordonstyp', parkingInstance.vehicle!.vehicleType),
                        const SizedBox(height: 16),
                        buildSectionTitle(context, 'Ägareinformation:'),
                        const SizedBox(height: 8),
                        if (parkingInstance.vehicle!.owner != null) ...[
                          buildKeyValue('Ägarens namn',
                              parkingInstance.vehicle!.owner!.name),
                          buildKeyValue('Ägarens personnummer',
                              parkingInstance.vehicle!.owner!.personNumber),
                        ] else
                          const Text('Ägarens informaion är inte tillgänglig.'),
                        const SizedBox(height: 16),
                        buildSectionTitle(
                            context, 'Parkeringsplatsinformation:'),
                        const SizedBox(height: 8),
                        buildKeyValue('Parkeringsplats ID',
                            parkingInstance.parkingSpace!.id.toString()),
                        buildKeyValue(
                            'Address', parkingInstance.parkingSpace!.address),
                        buildKeyValue('Pris per timme',
                            '${parkingInstance.parkingSpace!.pricePerHour} SEK'),
                      ],
                    ),
                  );
          } else if (state is ParkingsError) {
            return Center(
              child: Text(
                'Error loading parking data: ${state.message}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          return const Center(child: Text('Unknown state'));
        },
      ),
    );
  }

  // void _refreshParkings() {
  //   // if (parkingInstance?.vehicle?.owner != null) {
  //   BlocProvider.of<ParkingBloc>(context).add(
  //       LoadActiveParkings()); // Dispatch event to load active parkings from ParkingBloc
  //   //s }
  // }

  Widget buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge,
    );
  }

  Widget buildKeyValue(String key, String value) {
    return Text('$key: $value');
  }
}
