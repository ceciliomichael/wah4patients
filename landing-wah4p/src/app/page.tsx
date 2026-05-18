import { LandingDownload } from "@/components/landing/landing-download";
import { LandingHeader } from "@/components/landing/landing-header";
import { LandingHero } from "@/components/landing/landing-hero";
import { LandingHighlights } from "@/components/landing/landing-highlights";
import { LandingImageShowcase } from "@/components/landing/landing-image-showcase";

export const dynamic = "force-dynamic";

export default function Home() {
  return (
    <main className="overflow-x-hidden">
      <LandingHeader />
      <LandingHero />
      <LandingHighlights />
      <LandingImageShowcase />
      <LandingDownload />
    </main>
  );
}
