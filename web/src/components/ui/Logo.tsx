import React from "react";
import Link from "next/link";
import { clsx } from "clsx";

export interface LogoProps {
  className?: string;
  variant?: "light" | "dark";
  size?: "sm" | "md" | "lg";
  withLink?: boolean;
}

export const Logo: React.FC<LogoProps> = ({
  className,
  variant = "dark",
  size = "md",
  withLink = true,
}) => {
  const sizeMap = {
    sm: { icon: 28, text: "text-lg", subtext: "text-[9px]" },
    md: { icon: 36, text: "text-2xl", subtext: "text-[11px]" },
    lg: { icon: 48, text: "text-3xl", subtext: "text-xs" },
  };

  const isLight = variant === "light";
  const { icon, text, subtext } = sizeMap[size];

  const content = (
    <div className={clsx("inline-flex items-center gap-2.5 select-none", className)}>
      <svg
        width={icon}
        height={icon}
        viewBox="0 0 100 100"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
        className="shrink-0 drop-shadow-sm"
      >
        <path
          d="M50 8L82 22V52C82 72 68 88 50 94C32 88 18 72 18 52V22L50 8Z"
          fill={isLight ? "#0F1E33" : "#162A45"}
          stroke="#E8641C"
          strokeWidth="4"
        />
        <path
          d="M54 26L38 52H52L46 76L64 48H50L54 26Z"
          fill="#E8641C"
        />
      </svg>
      <div className="flex flex-col leading-tight">
        <span className={clsx("font-extrabold tracking-tight", text, isLight ? "text-white" : "text-brand-primary")}>
          Tech<span className="text-brand-accent">SOS</span>
        </span>
        <span className={clsx("font-medium tracking-wide uppercase", subtext, isLight ? "text-slate-300" : "text-slate-500")}>
          Bamako · Dépannage Pro
        </span>
      </div>
    </div>
  );

  if (withLink) {
    return (
      <Link href="/" className="hover:opacity-95 transition-opacity">
        {content}
      </Link>
    );
  }

  return content;
};
