import React from "react";
import { HeroSection } from "@/components/landing/HeroSection";
import { ServicesSection } from "@/components/landing/ServicesSection";
import { HowItWorksSection } from "@/components/landing/HowItWorksSection";
import { BamakoDistrictsSection } from "@/components/landing/BamakoDistrictsSection";
import { TarifsSection } from "@/components/landing/TarifsSection";

export default function HomePage() {
  return (
    <div className="flex flex-col min-h-screen">
      <HeroSection />
      <ServicesSection />
      <HowItWorksSection />
      <BamakoDistrictsSection />
      <TarifsSection />
    </div>
  );
}
