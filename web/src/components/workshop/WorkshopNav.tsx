"use client";

import React from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { LayoutDashboard, Radio, BookOpen, CreditCard } from "lucide-react";

export const WorkshopNav: React.FC = () => {
  const pathname = usePathname();

  const navItems = [
    {
      label: "Tableau de bord",
      href: "/atelier/dashboard",
      icon: <LayoutDashboard className="w-4 h-4" />,
    },
    {
      label: "Fil des Urgences (SOS)",
      href: "/atelier/fil-urgences",
      icon: <Radio className="w-4 h-4 text-brand-accent" />,
    },
    {
      label: "Journal d'Atelier & Comptoir",
      href: "/atelier/journal",
      icon: <BookOpen className="w-4 h-4" />,
    },
    {
      label: "Abonnement Pro",
      href: "/atelier/abonnement",
      icon: <CreditCard className="w-4 h-4 text-emerald-600" />,
    },
  ];

  return (
    <div className="flex flex-wrap items-center gap-2 border-b border-slate-200 pb-3 mb-8">
      {navItems.map((item) => {
        const isActive = pathname === item.href;
        return (
          <Link
            key={item.href}
            href={item.href}
            className={`px-4 py-2 rounded-xl text-xs sm:text-sm font-bold flex items-center gap-2 transition-all ${
              isActive
                ? "bg-brand-primary text-white shadow-sm"
                : "bg-white text-slate-600 hover:bg-slate-100 border border-slate-200"
            }`}
          >
            {item.icon}
            <span>{item.label}</span>
          </Link>
        );
      })}
    </div>
  );
};
