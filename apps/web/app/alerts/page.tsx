"use client";

import { BellRing, ShieldCheck, Wrench } from "lucide-react";

import { AdminShell } from "@/components/admin-shell";
import { Card, FutureConceptBanner } from "@/components/ui";

export default function AlertsPage() {
  return (
    <AdminShell
      title="Centro de alertas operativas"
      subtitle="Reglas automáticas de mantenimiento y anomalías de hardware — planificado para V3."
    >
      <FutureConceptBanner
        title="Sin incidentes simulados — pendiente de hardware V3"
        description="Actualmente no hay estaciones RVM conectadas ni cola de eventos de sensores. Esta sección se activará cuando exista telemetría real desde dispositivos en campo."
      />

      <div className="grid gap-4 md:grid-cols-3">
        <Card className="space-y-2">
          <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-amber-50 text-amber-700">
            <BellRing className="h-4 w-4" />
          </div>
          <h3 className="text-sm font-bold text-[#17221E]">
            Umbral de llenado crítico
          </h3>
          <p className="text-xs leading-relaxed text-[#556861]">
            Notificación preventiva cuando cualquier compartimento supere el
            85% de capacidad reportada.
          </p>
        </Card>

        <Card className="space-y-2">
          <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-amber-50 text-amber-700">
            <Wrench className="h-4 w-4" />
          </div>
          <h3 className="text-sm font-bold text-[#17221E]">
            Atasco o sensor desconectado
          </h3>
          <p className="text-xs leading-relaxed text-[#556861]">
            Detección de pérdida de heartbeat mayor a 10 minutos o falla en
            actuador de compuerta.
          </p>
        </Card>

        <Card className="space-y-2">
          <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-[#E9FAF3] text-[#087D60]">
            <ShieldCheck className="h-4 w-4" />
          </div>
          <h3 className="text-sm font-bold text-[#17221E]">
            Deriva de confianza ML
          </h3>
          <p className="text-xs leading-relaxed text-[#556861]">
            Aviso cuando la tasa semanal de corrección manual supere el umbral
            operativo configurado sobre datos reales de producción.
          </p>
        </Card>
      </div>
    </AdminShell>
  );
}
