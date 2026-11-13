import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/pecox_models.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/pecox_theme.dart';
import '../../../core/widgets/pecox_widgets.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  MaterialKey? _filter;
  bool _searchOpen = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted && ref.read(appStateProvider).isAuthenticated) {
        ref.read(appStateProvider.notifier).refreshHistory();
      }
    });
  }

  void _openEditMaterialSheet(ClassificationRecord record) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: PecoxColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'CORREGIR REGISTRO',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w800,
                    color: PecoxColors.emerald700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Selecciona el material correcto',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: kMaterials.map((mat) {
                    return ActionChip(
                      avatar: Icon(mat.icon, size: 16, color: mat.fgColor),
                      label: Text(mat.label),
                      onPressed: () async {
                        final ok = await ref
                            .read(appStateProvider.notifier)
                            .correctSavedClassification(record.id, mat.key);
                        if (sheetCtx.mounted) {
                          Navigator.of(sheetCtx).pop();
                        }
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                ok
                                    ? 'Material actualizado a ${mat.label}.'
                                    : 'No se pudo actualizar en el servidor.',
                              ),
                            ),
                          );
                        }
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openDetailSheet(ClassificationRecord record) {
    final predicted = materialByKey(record.predictedMaterial);
    final confirmed = materialByKey(record.confirmedMaterial);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: PecoxColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'DETALLE DE REGISTRO',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w800,
                    color: PecoxColors.emerald700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  record.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: PecoxColors.forest900,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _MetaBox(label: 'Predicción original', value: predicted.label),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MetaBox(label: 'Material confirmado', value: confirmed.label),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _MetaBox(
                        label: 'Confianza del modelo',
                        value: record.confidence != null ? '${record.confidence}%' : '--',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MetaBox(label: 'Fecha', value: record.timestampLabel),
                    ),
                  ],
                ),
                if (record.notes != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    record.notes!,
                    style: const TextStyle(fontSize: 12, color: PecoxColors.textMuted),
                  ),
                ],
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(sheetCtx).pop();
                    _openEditMaterialSheet(record);
                  },
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Corregir material'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () async {
                    final ok = await ref
                        .read(appStateProvider.notifier)
                        .deleteClassification(record.id);
                    if (sheetCtx.mounted) {
                      Navigator.of(sheetCtx).pop();
                    }
                    if (mounted && !ok) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No se pudo eliminar el registro del servidor.'),
                        ),
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: PecoxColors.error,
                    side: const BorderSide(color: Color(0xFFF0DEDE)),
                  ),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Eliminar de mi historial'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final history = state.history;
    final filtered = history.where((item) {
      final matchesFilter = _filter == null || item.confirmedMaterial == _filter;
      final label = materialByKey(item.confirmedMaterial).label.toLowerCase();
      final q = _query.trim().toLowerCase();
      final matchesQuery =
          q.isEmpty || item.title.toLowerCase().contains(q) || label.contains(q);
      return matchesFilter && matchesQuery;
    }).toList();

    final correctedCount =
        history.where((e) => e.status == ClassificationStatus.corrected).length;

    return Scaffold(
      bottomNavigationBar: const PecoxBottomNav(currentIndex: 2),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(appStateProvider.notifier).refreshHistory(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TU ACTIVIDAD',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w800,
                          color: PecoxColors.emerald700,
                        ),
                      ),
                      Text(
                        'Mi historial',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.6,
                          color: PecoxColors.forest900,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => setState(() {
                      _searchOpen = !_searchOpen;
                      if (!_searchOpen) _query = '';
                    }),
                    tooltip: _searchOpen ? 'Cerrar búsqueda' : 'Buscar en historial',
                    style: IconButton.styleFrom(
                      backgroundColor: PecoxColors.surface,
                      side: const BorderSide(color: PecoxColors.border),
                      minimumSize: const Size(48, 48),
                    ),
                    icon: Icon(_searchOpen ? Icons.close : Icons.search),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (state.offlineSim)
                PecoxOfflineBanner(
                  onRetry: () {
                    ref.read(appStateProvider.notifier).toggleOffline(false);
                    ref.read(appStateProvider.notifier).refreshHistory();
                  },
                ),
              if (state.historyError != null) ...[
                PecoxStateCard(
                  icon: Icons.cloud_off,
                  isError: true,
                  title: 'No pudimos sincronizar tu historial',
                  description: state.historyError!,
                  primaryLabel: 'Reintentar',
                  onPrimary: () => ref.read(appStateProvider.notifier).refreshHistory(),
                ),
                const SizedBox(height: 12),
              ],
              if (_searchOpen) ...[
                TextField(
                  onChanged: (v) => setState(() => _query = v),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Buscar por objeto o material...',
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [PecoxColors.forest900, PecoxColors.emerald700],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Clasificaciones',
                            style: TextStyle(fontSize: 12, color: Color(0xFFB7D8CC)),
                          ),
                          Text(
                            '${history.length}',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 34, color: Colors.white24),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Corregidas',
                            style: TextStyle(fontSize: 12, color: Color(0xFFB7D8CC)),
                          ),
                          Text(
                            '$correctedCount',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: FilterChip(
                        label: const Text('Todos'),
                        selected: _filter == null,
                        onSelected: (_) => setState(() => _filter = null),
                      ),
                    ),
                    for (final mat in kMaterials)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: FilterChip(
                          label: Text(mat.label),
                          selected: _filter == mat.key,
                          onSelected: (_) => setState(() => _filter = mat.key),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (state.historyLoading && history.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (!state.isAuthenticated || state.user.isGuest)
                PecoxStateCard(
                  icon: Icons.lock_outline,
                  title: 'Inicia sesión para ver tu historial',
                  description:
                      'Tu historial se almacena de forma privada por usuario en el servidor PECOX.',
                  primaryLabel: 'Ir a iniciar sesión',
                  onPrimary: () => context.go('/auth'),
                  secondaryLabel: 'Explorar guía de materiales',
                  onSecondary: () => context.push('/guide'),
                )
              else if (history.isEmpty)
                PecoxStateCard(
                  icon: Icons.history,
                  title: 'Aún no tienes clasificaciones',
                  description:
                      'Captura o selecciona una fotografía para empezar a construir tu registro de separación.',
                  primaryLabel: 'Escanear mi primer residuo',
                  onPrimary: () => context.push('/scanner'),
                  secondaryLabel: 'Explorar guía de materiales',
                  onSecondary: () => context.push('/guide'),
                )
              else if (filtered.isEmpty)
                PecoxStateCard(
                  icon: Icons.search_off,
                  title: 'Sin coincidencias',
                  description: 'No encontramos registros con los filtros actuales.',
                  primaryLabel: 'Limpiar filtros',
                  onPrimary: () => setState(() {
                    _filter = null;
                    _query = '';
                  }),
                )
              else
                for (final item in filtered) ...[
                  Card(
                    child: ListTile(
                      minVerticalPadding: 12,
                      onTap: () => _openDetailSheet(item),
                      leading: PecoxMaterialIconTile(
                        material: materialByKey(item.confirmedMaterial),
                      ),
                      title: Text(
                        item.title,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                      ),
                      subtitle: Text(
                        '${item.timestampLabel} · ${materialByKey(item.confirmedMaterial).label}',
                        style: const TextStyle(fontSize: 12, color: PecoxColors.textMuted),
                      ),
                      trailing: item.confidence != null
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: PecoxColors.mint100,
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: Text(
                                '${item.confidence}%',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: PecoxColors.emerald700,
                                ),
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaBox extends StatelessWidget {
  const _MetaBox({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5FAF7),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: PecoxColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: PecoxColors.textMuted)),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: PecoxColors.forest900,
            ),
          ),
        ],
      ),
    );
  }
}
