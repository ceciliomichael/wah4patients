import Image from "next/image";
import Link from "next/link";

export function LandingHeader() {
  return (
    <header className="sticky top-0 z-30 border-b border-[#e7e0d4] bg-[#fffaf0]/96 backdrop-blur-md">
      <div className="mx-auto flex w-full max-w-6xl items-center justify-between gap-4 px-4 py-3 md:px-6 lg:px-8">
        {/* Logo */}
        <Link href="#top" className="flex items-center gap-3 group">
          <Image
            src="/wahforpatients_horizontal.png"
            alt="WAH for Patients"
            width={220}
            height={56}
            priority
            className="h-9 w-auto md:h-11 transition-opacity duration-200 group-hover:opacity-80"
          />
        </Link>

        {/* Nav links */}
        <nav className="hidden items-center gap-1 md:flex">
          {[
            { href: "#features", label: "Features" },
            { href: "#preview", label: "Preview" },
            { href: "#download", label: "Download" },
          ].map((link) => (
            <Link
              key={link.href}
              href={link.href}
              className="rounded-full px-4 py-2 text-sm font-semibold text-[#5f6368] transition-colors duration-200 hover:bg-[#46017D]/8 hover:text-[#46017D]"
            >
              {link.label}
            </Link>
          ))}
        </nav>

        {/* Right CTA */}
        <div className="flex items-center gap-3">
          <Link
            href="#download"
            className="inline-flex h-10 items-center rounded-full bg-[#46017D] px-5 text-sm font-semibold text-white shadow-md shadow-[#46017D]/25 transition-all duration-200 hover:bg-[#5a02a3] hover:shadow-[#46017D]/40 active:scale-95"
          >
            Download Now
          </Link>
        </div>
      </div>
    </header>
  );
}
