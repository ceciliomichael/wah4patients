import Image from "next/image";
import Link from "next/link";

/** Renders the actual app screenshot inside a CSS phone frame */
function PhoneFrame() {
  return (
    <div className="relative mx-auto w-[260px] md:w-[290px] lg:w-[300px]">
      {/* Outer shell: gradient border via padding — NO overflow-hidden (that lives on inner) */}
      <div
        className="relative rounded-[38px] shadow-2xl"
        style={{
          padding: "3px",
          background: "linear-gradient(170deg, #606060 0%, #1c1c1c 50%, #424242 100%)",
        }}
      >
        {/* Inner: overflow-hidden at radius = outer(38) - padding(3) = 35px */}
        <div className="relative overflow-hidden rounded-[35px] bg-black">
          {/* Circle punch-hole notch — Android style */}
          <div className="absolute left-1/2 top-[14px] z-20 h-[13px] w-[13px] -translate-x-1/2 rounded-full bg-black" />

          {/* Screenshot — no border-radius needed; parent clips it */}
          <Image
            src="/hero-phone-screenshot.jpg"
            alt="WAH for Patients home screen showing Health Records, Appointments, Medication Resupply, and Daily Health Tip"
            width={390}
            height={844}
            priority
            className="block w-full"
          />

          {/* Glass sheen */}
          <div
            aria-hidden
            className="pointer-events-none absolute inset-0"
            style={{
              background:
                "linear-gradient(135deg, rgba(255,255,255,0.055) 0%, transparent 42%)",
            }}
          />

          {/* Home indicator */}
          <div className="absolute bottom-2 left-1/2 h-[3px] w-[72px] -translate-x-1/2 rounded-full bg-white/30" />
        </div>
      </div>

      {/* Power — right */}
      <div className="absolute -right-[3px] top-[96px] h-[52px] w-[3px] rounded-r bg-[#2e2e2e]" />
      {/* Volume up — left */}
      <div className="absolute -left-[3px] top-[80px] h-[34px] w-[3px] rounded-l bg-[#2e2e2e]" />
      {/* Volume down — left */}
      <div className="absolute -left-[3px] top-[122px] h-[34px] w-[3px] rounded-l bg-[#2e2e2e]" />

      {/* Bottom glow under phone */}
      <div
        aria-hidden
        className="pointer-events-none absolute -bottom-6 left-1/2 h-14 w-[65%] -translate-x-1/2 rounded-full blur-2xl"
        style={{ backgroundColor: "#46017D", opacity: 0.2 }}
      />
    </div>
  );
}

export function LandingHero() {
  return (
    <section
      id="top"
      className="relative w-full overflow-hidden bg-[#fffaf0]"
    >
      {/* Subtle decorative blobs */}
      <div
        aria-hidden
        className="pointer-events-none absolute -right-48 -top-48 h-[520px] w-[520px] rounded-full"
        style={{ backgroundColor: "#46017D", opacity: 0.045 }}
      />
      <div
        aria-hidden
        className="pointer-events-none absolute -bottom-32 -left-32 h-[380px] w-[380px] rounded-full"
        style={{ backgroundColor: "#0099FF", opacity: 0.04 }}
      />

      <div className="mx-auto flex w-full max-w-6xl flex-col items-center gap-14 px-4 pb-20 pt-16 md:px-6 md:pb-24 md:pt-20 lg:flex-row lg:items-center lg:gap-12 lg:px-8 lg:pb-28 lg:pt-24">
        {/* ── Left: copy ── */}
        <div className="flex w-full flex-col gap-7 lg:max-w-[54%] animate-fade-up">
          {/* Eyebrow chips */}
          <div className="flex flex-wrap gap-2">
            <span className="inline-flex items-center gap-2 rounded-full border border-[#46017D]/20 bg-[#46017D]/6 px-3.5 py-1.5 text-xs font-bold text-[#46017D]">
              <span className="size-1.5 rounded-full bg-[#46017D]" />
              Patient App
            </span>
            <span className="inline-flex items-center gap-2 rounded-full border border-[#FF9100]/20 bg-[#FF9100]/6 px-3.5 py-1.5 text-xs font-bold text-[#b36200]">
              <span className="size-1.5 rounded-full bg-[#FF9100]" />
              Apple Coming Soon
            </span>
          </div>

          {/* Headline — solid, no gradient */}
          <div className="space-y-5">
            <h1 className="text-4xl font-extrabold leading-[1.15] tracking-tight text-[#353839] md:text-5xl lg:text-[3.25rem]">
              Your health,{" "}
              <span className="text-[#46017D]">all in one place.</span>
            </h1>
            <p className="max-w-lg text-base leading-7 text-[#5f6368] md:text-lg md:leading-8">
              WAH for Patients gives you instant access to your appointments,
              health records, and care updates — without the confusion. Simple,
              clear, and built around you.
            </p>
          </div>

          {/* CTAs */}
          <div className="flex flex-wrap gap-3">
            <Link
              href="#download"
              className="inline-flex h-12 items-center justify-center rounded-full bg-[#46017D] px-7 text-sm font-bold text-white shadow-lg shadow-[#46017D]/25 transition-all duration-200 hover:bg-[#5a02a3] hover:-translate-y-0.5 hover:shadow-[#46017D]/40 active:scale-95"
            >
              Download for Android
            </Link>
            <Link
              href="#features"
              className="inline-flex h-12 items-center justify-center rounded-full border-2 border-[#353839]/12 bg-white px-7 text-sm font-bold text-[#353839] shadow-sm transition-all duration-200 hover:border-[#46017D]/25 hover:text-[#46017D] hover:-translate-y-0.5 active:scale-95"
            >
              See How It Works
            </Link>
          </div>

          {/* Stat strip */}
          <div className="flex items-center gap-6 border-t border-[#e7e0d4] pt-6">
            {[
              { value: "Free", sub: "To download" },
              { value: "Android", sub: "Available now" },
              { value: "iOS", sub: "Coming soon" },
            ].map((s, i) => (
              <div
                key={s.sub}
                className={`flex flex-col ${i > 0 ? "border-l border-[#e7e0d4] pl-6" : ""}`}
              >
                <span className="text-lg font-extrabold text-[#46017D] md:text-xl">
                  {s.value}
                </span>
                <span className="text-xs text-[#7a8086]">{s.sub}</span>
              </div>
            ))}
          </div>
        </div>

        {/* ── Right: phone in frame ── */}
        <div className="flex w-full items-center justify-center lg:max-w-[46%] animate-fade-up delay-200">
          <div className="animate-float">
            <PhoneFrame />
          </div>
        </div>
      </div>
    </section>
  );
}
