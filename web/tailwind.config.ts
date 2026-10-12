import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        brand: {
          primary: "#1F3A5F",
          "primary-dark": "#162A45",
          "primary-light": "#2B4C7E",
          accent: "#E8641C",
          "accent-hover": "#D35400",
          success: "#2E8B57",
          "success-light": "#E8F5E9",
          alert: "#D9A441",
          "alert-light": "#FFF8E1",
          surface: "#F8FAFC",
          card: "#FFFFFF",
          border: "#E2E8F0",
          dark: "#0F172A",
          "dark-card": "#1E293B",
          "dark-border": "#334155",
        },
      },
      fontFamily: {
        sans: [
          "var(--font-sans)",
          "-apple-system",
          "BlinkMacSystemFont",
          "Segoe UI",
          "Roboto",
          "sans-serif",
        ],
      },
      boxShadow: {
        subtle: "0 1px 3px 0 rgba(0, 0, 0, 0.05), 0 1px 2px -1px rgba(0, 0, 0, 0.05)",
        card: "0 4px 6px -1px rgba(0, 0, 0, 0.05), 0 2px 4px -2px rgba(0, 0, 0, 0.05)",
        hover: "0 10px 15px -3px rgba(31, 58, 95, 0.08), 0 4px 6px -4px rgba(31, 58, 95, 0.04)",
      },
    },
  },
  plugins: [],
};

export default config;
