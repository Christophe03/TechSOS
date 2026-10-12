import React from "react";
import { clsx } from "clsx";

export interface CardProps extends React.HTMLAttributes<HTMLDivElement> {
  hover?: boolean;
}

export const Card: React.FC<CardProps> = ({ className, hover = false, children, ...props }) => {
  return (
    <div
      className={clsx(
        "bg-white rounded-2xl border border-brand-border p-6 shadow-subtle transition-all duration-200",
        hover && "hover:shadow-hover hover:border-brand-primary/20",
        className
      )}
      {...props}
    >
      {children}
    </div>
  );
};
