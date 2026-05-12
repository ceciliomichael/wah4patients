import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "WAH for Patients — Your Care, Simplified",
  description:
    "WAH for Patients (WAH4P) is the official patient app that helps you track appointments, view your health records, and stay connected with your care team — all in one place.",
  icons: {
    icon: "/favicon.svg",
  },
  openGraph: {
    title: "WAH for Patients — Your Care, Simplified",
    description:
      "Track appointments, view health records, and stay connected with your care team. Available now on Android.",
    type: "website",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body
        suppressHydrationWarning
        className="bg-[#fffaf0] text-[#353839] antialiased"
        style={{ fontFamily: "'Open Sans', system-ui, sans-serif" }}
      >
        {children}
      </body>
    </html>
  );
}
