const features = [
  {
    accent: "#46017D",
    bg: "#46017D",
    icon: (
      <svg
        className="h-6 w-6 text-white"
        fill="none"
        viewBox="0 0 24 24"
        stroke="currentColor"
        strokeWidth={2}
      >
        <path
          strokeLinecap="round"
          strokeLinejoin="round"
          d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"
        />
      </svg>
    ),
    title: "Appointments at a glance",
    description:
      "See your upcoming visits, get reminders, and never miss a scheduled consultation with your care team.",
  },
  {
    accent: "#0099FF",
    bg: "#0099FF",
    icon: (
      <svg
        className="h-6 w-6 text-white"
        fill="none"
        viewBox="0 0 24 24"
        stroke="currentColor"
        strokeWidth={2}
      >
        <path
          strokeLinecap="round"
          strokeLinejoin="round"
          d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
        />
      </svg>
    ),
    title: "Your health records",
    description:
      "Access your medical history, lab results, and care notes whenever you need them — securely and clearly.",
  },
  {
    accent: "#FF9100",
    bg: "#FF9100",
    icon: (
      <svg
        className="h-6 w-6 text-white"
        fill="none"
        viewBox="0 0 24 24"
        stroke="currentColor"
        strokeWidth={2}
      >
        <path
          strokeLinecap="round"
          strokeLinejoin="round"
          d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"
        />
      </svg>
    ),
    title: "Stay in the loop",
    description:
      "Receive important updates from your care team and stay informed about the next steps in your health journey.",
  },
] as const;

export function LandingHighlights() {
  return (
    <section
      id="features"
      className="mx-auto w-full max-w-6xl px-4 py-10 md:px-6 md:py-14 lg:px-8"
    >
      {/* Section header */}
      <div className="mb-10 text-center animate-fade-up">
        <span className="inline-flex items-center gap-2 rounded-full border border-[#46017D]/20 bg-[#46017D]/8 px-3.5 py-1.5 text-xs font-bold uppercase tracking-widest text-[#46017D]">
          Features
        </span>
        <h2 className="mt-4 text-3xl font-bold tracking-tight text-[#353839] md:text-4xl">
          Everything you need for your care journey
        </h2>
        <p className="mx-auto mt-4 max-w-2xl text-base leading-7 text-[#5f6368]">
          WAH for Patients is built around simplicity. No confusing menus, no
          medical jargon — just the information that matters to you, in one
          place.
        </p>
      </div>

      {/* Feature cards */}
      <div className="grid gap-4 md:grid-cols-3 animate-fade-up delay-200">
        {features.map((feature) => (
          <div
            key={feature.title}
            className="group relative overflow-hidden rounded-3xl border border-[#e7e0d4] bg-white p-6 shadow-sm transition-all duration-300 hover:-translate-y-1 hover:shadow-md hover:shadow-[#46017D]/10 md:p-8"
          >
            {/* Subtle top accent line */}
            <div
              className="absolute inset-x-0 top-0 h-1 rounded-t-3xl transition-all duration-300 group-hover:h-1.5"
              style={{ backgroundColor: feature.accent }}
            />

            {/* Icon */}
            <div
              className="mb-5 flex h-12 w-12 items-center justify-center rounded-2xl shadow-md"
              style={{
                backgroundColor: feature.bg,
                boxShadow: `0 4px 14px ${feature.accent}40`,
              }}
            >
              {feature.icon}
            </div>

            <h3 className="text-lg font-bold text-[#353839]">{feature.title}</h3>
            <p className="mt-2 text-sm leading-7 text-[#5f6368]">
              {feature.description}
            </p>
          </div>
        ))}
      </div>

      {/* Bottom trust banner */}
      <div className="mt-8 flex flex-wrap items-center justify-center gap-6 animate-fade-up delay-300">
        {[
          "Simple & intuitive",
          "Built for patients",
          "Android-ready",
          "iOS coming soon",
        ].map((tag) => (
          <span
            key={tag}
            className="flex items-center gap-2 text-sm font-semibold text-[#5f6368]"
          >
            <svg
              className="h-4 w-4 text-[#46017D]"
              fill="currentColor"
              viewBox="0 0 20 20"
            >
              <path
                fillRule="evenodd"
                d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                clipRule="evenodd"
              />
            </svg>
            {tag}
          </span>
        ))}
      </div>
    </section>
  );
}
