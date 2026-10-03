import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moto_taxi_digital_mobile/pages/user/userHome/userHomeCtrl.dart';
import 'package:moto_taxi_digital_mobile/pages/user/userHome/userHomeState.dart';

class RaceTrackingPage extends ConsumerWidget {
  const RaceTrackingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userHomeControllerProvider);
    final notifier = ref.read(userHomeControllerProvider.notifier);
    final race = state.currentRace;

    if (race == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Course terminée')),
        body: Center(
          child: FilledButton.icon(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('RETOUR À L’ACCUEIL'),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F9),
      appBar: AppBar(
        title: Text(
          "Course #${race.id}",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildStatusHeader(race.status, race.bikerId != null),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  if (race.bikerId != null)
                    _buildBikerInfoCard(state)
                  else
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Row(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(width: 16),
                            Expanded(
                              child: Text('Recherche d’un motard disponible…'),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  if (race.status == 'pending' &&
                      race.pinCode != null &&
                      race.pinCode!.trim().isNotEmpty)
                    _buildPinCodeCard(race.pinCode!),

                  const SizedBox(height: 20),

                  _buildTripDetails(race),

                  const SizedBox(height: 25),

                  _buildPriceSummary(state),

                  const SizedBox(height: 40),

                  _buildActionButton(context, ref, state, race, notifier),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(String status, bool hasBiker) {
    bool isPending = status == 'pending';
    Color statusColor = isPending ? Colors.orange : Colors.green;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: statusColor.withValues(alpha: 0.1),
      child: Center(
        child: Text(
          isPending
              ? hasBiker
                    ? "Motard trouvé : confirmation en attente"
                    : "Recherche d'un motard en cours"
              : " Course en cours vers destination",
          style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildPinCodeCard(String pin) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade100, width: 2),
      ),
      child: Column(
        children: [
          const Text(
            "CODE DE VÉRIFICATION",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            pin,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: 12,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Code de référence de la course",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildBikerInfoCard(UserHomeState state) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: Color(0xFF008E53),
              child: Icon(Icons.person, color: Colors.white, size: 35),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.selectedBiker?.name ?? 'Motard assigné',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const Text(
                    'Position mise à jour pendant la course',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripDetails(dynamic race) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildLocationRow(
            Icons.radio_button_checked,
            Colors.green,
            "Départ",
            race.startingPoint,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 11),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 2,
                height: 25,
                color: Colors.grey.shade200,
              ),
            ),
          ),
          _buildLocationRow(
            Icons.location_on,
            Colors.red,
            "Destination",
            race.destination,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow(
    IconData icon,
    Color color,
    String title,
    String address,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
              Text(
                address,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSummary(UserHomeState state) {
    final fare = state.estimatedFare;
    final fareLabel = fare == null
        ? 'Tarif indisponible'
        : '${fare.toStringAsFixed(0)} FC';
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Tarif estimé",
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
            Text(
              fareLabel,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF008E53),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Méthode de paiement",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  size: 16,
                  color: Colors.blue.shade700,
                ),
                const SizedBox(width: 5),
                const Text(
                  "Portefeuille",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    WidgetRef ref,
    UserHomeState state,
    dynamic race,
    UserHomeController notifier,
  ) {
    final isPending = race.status == 'pending';
    final isOngoing = race.status == 'ongoing';
    final isAwaitingPassenger = isPending && race.bikerId != null;

    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: state.isLoading || (!isPending && !isOngoing)
            ? null
            : () async {
                if (isPending) {
                  if (isAwaitingPassenger) {
                    await notifier.confirmAcceptedBiker();
                    if (!context.mounted) return;
                    final updatedState = ref.read(userHomeControllerProvider);
                    if (updatedState.errorMessage != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(updatedState.errorMessage!)),
                      );
                    }
                    return;
                  }
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Annuler cette course ?'),
                      content: const Text(
                        'La demande sera retirée si le serveur autorise encore son annulation.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, false),
                          child: const Text('RETOUR'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(dialogContext, true),
                          child: const Text('ANNULER'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed != true || !context.mounted) return;
                  final cancelled = await notifier.cancelRace();
                  if (!context.mounted) return;
                  if (cancelled) {
                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.pop(context);
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Course annulée.')),
                    );
                  } else {
                    final error = ref
                        .read(userHomeControllerProvider)
                        .errorMessage;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(error ?? 'Annulation impossible.'),
                      ),
                    );
                  }
                } else {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Terminer la course ?'),
                      content: const Text(
                        'Le paiement sera effectué et cette action ne pourra pas être annulée.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, false),
                          child: const Text('RETOUR'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(dialogContext, true),
                          child: const Text('TERMINER'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed != true || !context.mounted) return;

                  final completed = await notifier.completeActiveRace();
                  if (!context.mounted) return;
                  if (completed) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Course terminée avec succès.'),
                      ),
                    );
                    Navigator.pop(context);
                  } else {
                    final errorMessage = ref
                        .read(userHomeControllerProvider)
                        .errorMessage;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          errorMessage ?? 'Impossible de terminer la course.',
                        ),
                      ),
                    );
                  }
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: isPending
              ? isAwaitingPassenger
                    ? const Color(0xFF008E53)
                    : Colors.redAccent
              : const Color(0xFF008E53),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
        ),
        child: Text(
          isPending
              ? isAwaitingPassenger
                    ? "CONFIRMER LE MOTARD"
                    : "ANNULER LA COURSE"
              : isOngoing
              ? "TERMINER LA COURSE"
              : "COURSE TERMINÉE",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
