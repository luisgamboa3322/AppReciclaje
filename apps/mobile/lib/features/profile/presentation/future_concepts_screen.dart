import 'package:flutter/material.dart';
import '../../../core/theme/pecox_theme.dart';

class FutureConceptsScreen extends StatefulWidget {
  const FutureConceptsScreen({super.key});

  @override
  State<FutureConceptsScreen> createState() => _FutureConceptsScreenState();
}

class _FutureConceptsScreenState extends State<FutureConceptsScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conceptos futuros · V3')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: PecoxColors.forest900,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lock_outline, color: Color(0xFF85E8C4), size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CONCEPTO FUTURO (V3) · NO IMPLEMENTADO EN MVP',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF85E8C4),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Estas pantallas ilustran la ampliación futura con máquinas recicladoras físicas e IoT. Ningún valor aquí es telemetría real.',
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.45,
                            color: Color(0xFFD6EBE3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('A. Recompensas')),
                ButtonSegment(value: 1, label: Text('B. Máquinas IoT')),
              ],
              selected: {_tab},
              onSelectionChanged: (sel) => setState(() => _tab = sel.first),
            ),
            const SizedBox(height: 16),
            if (_tab == 0) ...[
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [PecoxColors.mint100, Colors.white],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFBCEBD8)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CONCEPTO FUTURO',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: PecoxColors.emerald700,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Puntos por depósitos verificados',
                      style: TextStyle(fontSize: 12, color: PecoxColors.textMuted),
                    ),
                    Text(
                      '0 pts',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: PecoxColors.forest900,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Regla central: los escaneos con cámara NO otorgan puntos. Las recompensas dependerán exclusivamente de depósitos confirmados por sensores físicos.',
                      style: TextStyle(fontSize: 12, height: 1.5),
                    ),
                  ],
                ),
              ),
            ] else ...[
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Máquinas inteligentes (Ejemplo ilustrativo)',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: PecoxColors.forest900,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Las ubicaciones, niveles de llenado y alertas son ilustrativas; no hay dispositivos conectados.',
                        style: TextStyle(fontSize: 12, color: PecoxColors.textMuted),
                      ),
                      SizedBox(height: 14),
                      _MachineTile(
                        name: 'Módulo Campus Ingeniería (Ejemplo)',
                        status: 'En línea (simulado)',
                        fillPercent: 68,
                        accepted: 'Plástico · Metal',
                      ),
                      SizedBox(height: 10),
                      _MachineTile(
                        name: 'Módulo Biblioteca Central (Ejemplo)',
                        status: 'Mantenimiento requerido',
                        fillPercent: 92,
                        accepted: 'Papel · Cartón',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MachineTile extends StatelessWidget {
  const _MachineTile({
    required this.name,
    required this.status,
    required this.fillPercent,
    required this.accepted,
  });

  final String name;
  final String status;
  final int fillPercent;
  final String accepted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFCFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PecoxColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                status,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: PecoxColors.emerald700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: fillPercent / 100,
            minHeight: 8,
            borderRadius: BorderRadius.circular(999),
            backgroundColor: const Color(0xFFEDF5F1),
            color: fillPercent > 85 ? PecoxColors.error : PecoxColors.emerald500,
          ),
          const SizedBox(height: 6),
          Text(
            'Llenado ilustrativo: $fillPercent% · Acepta: $accepted',
            style: const TextStyle(fontSize: 11, color: PecoxColors.textMuted),
          ),
        ],
      ),
    );
  }
}
