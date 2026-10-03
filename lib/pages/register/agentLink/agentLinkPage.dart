import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../registerCtrl.dart';

class AgentLinkPage extends ConsumerStatefulWidget {
  const AgentLinkPage({super.key});
  @override
  ConsumerState<AgentLinkPage> createState() => _AgentLinkPageState();
}

class _AgentLinkPageState extends ConsumerState<AgentLinkPage> {
  final _code = TextEditingController();
  bool _scanning = false;
  bool _handled = false;
  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _linkCode() async {
    if (_code.text.trim().length != 12) {
      _error('Le numéro agent doit contenir 12 chiffres.');
      return;
    }
    final ok = await ref
        .read(registerControlProvider.notifier)
        .linkAgent(numericCode: _code.text.trim());
    if (ok && mounted) _done();
  }

  Future<void> _handleQr(String raw) async {
    if (_handled) return;
    final uri = Uri.tryParse(raw);
    if (uri == null) return;
    final id = int.tryParse(uri.queryParameters['agent_id'] ?? '');
    final agentCode = uri.queryParameters['agent_code'];
    final token = uri.queryParameters['token'];
    if (id == null || agentCode == null || token == null) return;
    _handled = true;
    setState(() => _scanning = false);
    final ok = await ref
        .read(registerControlProvider.notifier)
        .linkAgent(agentId: id, agentCode: agentCode, qrToken: token);
    if (ok && mounted)
      _done();
    else
      _handled = false;
  }

  void _done() {
    context.go('/public/login');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Inscription terminée. Votre dossier est en attente de validation. Vous recevrez la décision par e-mail.',
        ),
        duration: Duration(seconds: 6),
      ),
    );
  }

  void _error(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registerControlProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Lier votre agent',
          style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dernière étape',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Saisissez le numéro d’identification à 12 chiffres de votre agent ou scannez le QR code de sa carte.',
              style: TextStyle(color: cs.onSurface.withOpacity(.7)),
            ),
            const SizedBox(height: 30),
            TextFormField(
              controller: _code,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(12),
              ],
              decoration: const InputDecoration(
                labelText: 'Numéro d’identification agent',
                hintText: '000000000000',
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: state.isLoading ? null : _linkCode,
                child: state.isLoading
                    ? CircularProgressIndicator(color: cs.onPrimary)
                    : const Text('Lier avec le numéro'),
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(child: Divider(color: cs.outline.withOpacity(.4))),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('OU'),
                ),
                Expanded(child: Divider(color: cs.outline.withOpacity(.4))),
              ],
            ),
            const SizedBox(height: 22),
            OutlinedButton.icon(
              onPressed: state.isLoading
                  ? null
                  : () => setState(() {
                      _scanning = !_scanning;
                      _handled = false;
                    }),
              icon: const Icon(Icons.qr_code_scanner),
              label: Text(
                _scanning
                    ? 'Fermer le scanner'
                    : 'Scanner le QR code de la carte agent',
              ),
            ),
            if (_scanning) ...[
              const SizedBox(height: 18),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 300,
                  child: MobileScanner(
                    onDetect: (capture) {
                      if (capture.barcodes.isNotEmpty) {
                        final raw = capture.barcodes.first.rawValue;
                        if (raw != null) _handleQr(raw);
                      }
                    },
                  ),
                ),
              ),
            ],
            if (state.error != null) ...[
              const SizedBox(height: 18),
              Text(
                state.error!,
                style: TextStyle(color: cs.error, fontWeight: FontWeight.w500),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
