import type { Metadata } from "next";
import { Plus_Jakarta_Sans } from "next/font/google";
import { MotionConfig } from "motion/react";

import "@/app/globals.css";
import { AuthProvider } from "@/components/auth-provider";

const plusJakarta = Plus_Jakarta_Sans({
  subsets: ["latin"],
  weight: ["400", "500", "600", "700"],
  variable: "--font-sans",
  display: "swap",
});

export const metadata: Metadata = {
  title: "PECOX Admin — Gestión Operativa",
  description:
    "Panel administrativo de PECOX Vision para auditoría de clasificaciones, analítica real y estado del modelo ML.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="es" className={plusJakarta.variable}>
      <body className="min-h-screen font-sans antialiased">
        <MotionConfig reducedMotion="user">
          <AuthProvider>{children}</AuthProvider>
        </MotionConfig>
      </body>
    </html>
  );
}
