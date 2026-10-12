import React from "react";
import { clsx } from "clsx";

export interface BadgeProps extends React.HTMLAttributes<HTMLSpanElement> {
  variant?: "pending" | "offers" | "in_progress" | "completed" | "cancelled" | "info" | "neutral";
  size?: "sm" | "md";
}

export const Badge: React.FC<BadgeProps> = ({
  className,
  variant = "neutral",
  size = "md",
  children,
  ...props
}) => {
  const baseStyles = "inline-flex items-center font-semibold rounded-full select-none";

  const variants = {
    pending: "bg-amber-100 text-amber-900 border border-amber-200/80",
    offers: "bg-blue-100 text-blue-900 border border-blue-200/80",
    in_progress: "bg-orange-100 text-orange-950 border border-orange-200/80",
    completed: "bg-emerald-100 text-emerald-950 border border-emerald-200/80",
    cancelled: "bg-rose-100 text-rose-950 border border-rose-200/80",
    info: "bg-slate-100 text-slate-800 border border-slate-200",
    neutral: "bg-gray-100 text-gray-700 border border-gray-200",
  };

  const sizes = {
    sm: "text-[11px] px-2 py-0.5",
    md: "text-xs px-2.5 py-1",
  };

  return (
    <span className={clsx(baseStyles, variants[variant], sizes[size], className)} {...props}>
      {children}
    </span>
  );
};
