"use client";

import { Cpu, Radio, ServerCog } from "lucide-react";

import { AdminShell } from "@/components/admin-shell";
import { Card, FutureConceptBanner } from "@/components/ui";

export default function MachinesPage() {
  return (
    <AdminShell
      title="Red de máquinas inteligentes"
      subtitle="Integración física con puntos de reciclaje y sensores conectados — próxima etapa."
    >
      <FutureConceptBanner
        title="Módulo reservado para estaciones inteligentes conectadas"
        description="Por política de transparencia de PECOX Vision, esta vista NO muestra máquinas ficticias ni telemetría simulada. Cuando se conecten estaciones físicas con sensores reales, su estado en vivo aparecerá aquí."
      />

      <div className="grid gap-4 md:grid-cols-3">
        <Card className="space-y-2">
          <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-[#E9FAF3] text-[#087D60]">
            <Radio className="h-4 w-4" />
          </div>
          <h3 className="text-sm font-bold text-[#17221E]">
            Telemetría de llenado
          </h3>
          <p className="text-xs leading-relaxed text-[#556861]">
            Lectura periódica por compartimento (Plástico, Vidrio, Metal,
            Cartón/Papel) para programar rutas de recolección antes de alcanzar
            el 85% de capacidad.
          </p>
        </Card>

        <Card className="space-y-2">
          <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-[#E9FAF3] text-[#087D60]">
            <Cpu className="h-4 w-4" />
          </div>
          <h3 className="text-sm font-bold text-[#17221E]">
            Inferencia en el borde (ONNX)
          </h3>
          <p className="text-xs leading-relaxed text-[#556861]">
            Despliegue del clasificador ResNet18 exportado en estaciones con
            cámara fija para validación automática en compuerta.
          </p>
        </Card>

        <Card className="space-y-2">
          <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-[#E9FAF3] text-[#087D60]">
            <ServerCog className="h-4 w-4" />
          </div>
          <h3 className="text-sm font-bold text-[#17221E]">
            Provisionamiento de sedes
          </h3>
          <p className="text-xs leading-relaxed text-[#556861]">
            Registro autenticado por llave de dispositivo para vincular depósitos
            físicos a cuentas institucionales sin exponer credenciales de usuario.
          </p>
        </Card>
      </div>
    </AdminShell>
  );
}
