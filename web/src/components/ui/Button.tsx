import React from "react";
import { clsx } from "clsx";
import { Loader2 } from "lucide-react";

export interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: "primary" | "accent" | "outline" | "ghost" | "success" | "danger";
  size?: "sm" | "md" | "lg";
  isLoading?: boolean;
  leftIcon?: React.ReactNode;
  rightIcon?: React.ReactNode;
}

export const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  (
    {
      className,
      variant = "primary",
      size = "md",
      isLoading = false,
      leftIcon,
      rightIcon,
      children,
      disabled,
      ...props
    },
    ref
  ) => {
    const baseStyles =
      "inline-flex items-center justify-center font-semibold transition-all duration-150 rounded-xl focus:outline-none focus:ring-2 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed select-none";

    const variants = {
      primary:
        "bg-brand-primary text-white hover:bg-brand-primary-light focus:ring-brand-primary/50 shadow-sm active:scale-[0.98]",
      accent:
        "bg-brand-accent text-white hover:bg-brand-accent-hover focus:ring-brand-accent/50 shadow-sm active:scale-[0.98]",
      outline:
        "border border-brand-border bg-white text-brand-primary hover:bg-brand-surface hover:border-brand-primary/40 focus:ring-brand-primary/30",
      ghost:
        "text-brand-primary hover:bg-brand-primary/5 focus:ring-brand-primary/20",
      success:
        "bg-brand-success text-white hover:bg-emerald-700 focus:ring-brand-success/50 shadow-sm",
      danger:
        "bg-rose-600 text-white hover:bg-rose-700 focus:ring-rose-500/50 shadow-sm",
    };

    const sizes = {
      sm: "text-xs px-3 py-1.5 gap-1.5",
      md: "text-sm px-4 py-2.5 gap-2",
      lg: "text-base px-6 py-3.5 gap-2.5",
    };

    return (
      <button
        ref={ref}
        disabled={disabled || isLoading}
        className={clsx(baseStyles, variants[variant], sizes[size], className)}
        {...props}
      >
        {isLoading && <Loader2 className="w-4 h-4 animate-spin shrink-0" />}
        {!isLoading && leftIcon && <span className="shrink-0">{leftIcon}</span>}
        <span>{children}</span>
        {!isLoading && rightIcon && <span className="shrink-0">{rightIcon}</span>}
      </button>
    );
  }
);

Button.displayName = "Button";
