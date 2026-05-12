const appScreens = [
  {
    id: "appointments",
    accent: "#46017D",
    label: "Appointments",
    icon: (
      <svg
        className="h-5 w-5"
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
    title: "Upcoming Visit",
    time: "Today · 2:30 PM",
    detail: "Dr. Santos — General Consultation",
    subLabel: "Room 4, Floor 2",
    rows: [
      { label: "Next Check-up", value: "Jun 3" },
      { label: "Lab Results", value: "Ready" },
    ],
    rowAccent: "#46017D",
  },
  {
    id: "records",
    accent: "#0099FF",
    label: "Health Records",
    icon: (
      <svg
        className="h-5 w-5"
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
    title: "Your Records",
    time: "Last updated today",
    detail: "Blood Pressure · Glucose · CBC",
    subLabel: "All values within normal range",
    rows: [
      { label: "Blood Type", value: "O+" },
      { label: "Allergies", value: "None" },
    ],
    rowAccent: "#0099FF",
  },
  {
    id: "updates",
    accent: "#FF9100",
    label: "Care Updates",
    icon: (
      <svg
        className="h-5 w-5"
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
    title: "From Your Care Team",
    time: "Just now",
    detail: "Your prescription has been updated.",
    subLabel: "Please collect from pharmacy",
    rows: [
      { label: "Refills Left", value: "2" },
      { label: "Next Dose", value: "8:00 PM" },
    ],
    rowAccent: "#FF9100",
  },
];

export function LandingImageShowcase() {
  return (
    <section
      id="preview"
      className="mx-auto w-full max-w-6xl px-4 py-10 md:px-6 md:py-14 lg:px-8"
    >
      {/* Section header */}
      <div className="mb-10 text-center animate-fade-up">
        <span className="inline-flex items-center gap-2 rounded-full border border-[#0099FF]/20 bg-[#0099FF]/8 px-3.5 py-1.5 text-xs font-bold uppercase tracking-widest text-[#0066bb]">
          App Preview
        </span>
        <h2 className="mt-4 text-3xl font-bold tracking-tight text-[#353839] md:text-4xl">
          Simple screens, real clarity
        </h2>
        <p className="mx-auto mt-4 max-w-xl text-base leading-7 text-[#5f6368]">
          Here's a look at what you'll find inside the app — designed so your
          important health information is always easy to find.
        </p>
      </div>

      {/* App screen preview cards */}
      <div className="grid gap-4 md:grid-cols-3 animate-fade-up delay-200">
        {appScreens.map((screen) => (
          <div
            key={screen.id}
            className="group overflow-hidden rounded-3xl border border-[#e7e0d4] bg-white shadow-sm transition-all duration-300 hover:-translate-y-1 hover:shadow-lg"
            style={{
              boxShadow: `0 1px 3px rgba(0,0,0,0.06)`,
            }}
          >
            {/* Phone chrome top bar */}
            <div
              className="flex items-center justify-between px-4 py-3 text-white"
              style={{ backgroundColor: screen.accent }}
            >
              <div className="flex items-center gap-2">
                <div
                  className="flex h-7 w-7 items-center justify-center rounded-lg bg-white/20"
                >
                  {screen.icon}
                </div>
                <span className="text-sm font-bold">{screen.label}</span>
              </div>
              <span className="text-xs font-medium text-white/80">
                {screen.time}
              </span>
            </div>

            {/* Card body */}
            <div className="p-5">
              {/* Main info */}
              <div
                className="rounded-2xl px-4 py-4"
                style={{ backgroundColor: `${screen.accent}0d` }}
              >
                <p className="text-base font-bold text-[#353839]">
                  {screen.title}
                </p>
                <p className="mt-1 text-sm font-semibold" style={{ color: screen.accent }}>
                  {screen.detail}
                </p>
                <p className="mt-0.5 text-xs text-[#7a8086]">{screen.subLabel}</p>
              </div>

              {/* Info rows */}
              <div className="mt-4 space-y-2.5">
                {screen.rows.map((row) => (
                  <div
                    key={row.label}
                    className="flex items-center justify-between rounded-xl border border-[#e7e0d4] bg-[#fffaf0] px-4 py-2.5"
                  >
                    <span className="text-sm text-[#5f6368]">{row.label}</span>
                    <span
                      className="text-sm font-bold"
                      style={{ color: screen.accent }}
                    >
                      {row.value}
                    </span>
                  </div>
                ))}
              </div>

              {/* CTA strip */}
              <div className="mt-4 flex items-center justify-center rounded-xl py-2 text-xs font-bold transition-colors duration-200 group-hover:bg-[#fffaf0]" style={{ color: screen.accent }}>
                View in app →
              </div>
            </div>
          </div>
        ))}
      </div>
    </section>
  );
}
