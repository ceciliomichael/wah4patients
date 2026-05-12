import Link from "next/link";

const androidSteps = [
  "Tap the Download button below",
  'Open the downloaded APK file on your Android phone',
  'Allow installation from unknown sources if prompted',
  "Install and open WAH for Patients",
];

export function LandingDownload() {
  return (
    <section
      id="download"
      className="mx-auto w-full max-w-6xl px-4 pb-16 pt-6 md:px-6 md:pb-24 lg:px-8"
    >
      {/* Main CTA block */}
      <div className="relative overflow-hidden rounded-3xl bg-[#46017D] shadow-xl shadow-[#46017D]/30 animate-fade-up">
        {/* Decorative circles */}
        <div
          aria-hidden
          className="pointer-events-none absolute -right-16 -top-16 h-64 w-64 rounded-full opacity-15"
          style={{ backgroundColor: "#0099FF" }}
        />
        <div
          aria-hidden
          className="pointer-events-none absolute -bottom-12 -left-12 h-48 w-48 rounded-full opacity-10"
          style={{ backgroundColor: "#FF9100" }}
        />

        <div className="relative grid gap-0 lg:grid-cols-[1fr_380px]">
          {/* Left: headline + steps */}
          <div className="p-8 text-white md:p-10 lg:p-12">
            <span className="inline-flex items-center gap-2 rounded-full bg-white/15 px-3 py-1.5 text-xs font-bold uppercase tracking-widest text-white">
              <span className="size-1.5 animate-pulse-soft rounded-full bg-[#0099FF]" />
              Android APK
            </span>

            <h2 className="mt-5 text-3xl font-bold tracking-tight text-white md:text-4xl lg:text-5xl">
              Download WAH for Patients
            </h2>
            <p className="mt-4 max-w-lg text-base leading-7 text-white/80">
              The Android app is available now — free to download. Apple (iOS)
              support is on the way and will be announced soon.
            </p>

            {/* Steps */}
            <div className="mt-8 space-y-3">
              {androidSteps.map((step, i) => (
                <div key={step} className="flex items-start gap-3">
                  <span
                    className="mt-0.5 flex h-6 w-6 shrink-0 items-center justify-center rounded-full bg-white/20 text-xs font-bold text-white"
                  >
                    {i + 1}
                  </span>
                  <p className="text-sm leading-6 text-white/85">{step}</p>
                </div>
              ))}
            </div>

            {/* Platform badges */}
            <div className="mt-8 flex flex-wrap gap-2">
              <span className="inline-flex items-center gap-2 rounded-full bg-white/15 px-4 py-2 text-sm font-semibold text-white">
                <svg className="h-4 w-4" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M17.523 15.341c-.32.905-.676 1.762-1.066 2.574-.563 1.175-1.023 1.987-1.376 2.437-.549.665-1.137.998-1.764 1.011-.45 0-.993-.13-1.625-.39-.634-.262-1.217-.393-1.75-.393-.56 0-1.16.131-1.8.393-.642.26-1.158.396-1.55.409-.6.026-1.202-.314-1.809-1.022-.383-.466-.862-1.3-1.437-2.5-.616-1.285-1.122-2.776-1.522-4.475-.428-1.833-.643-3.608-.643-5.326 0-1.968.426-3.665 1.276-5.091.67-1.142 1.56-2.042 2.672-2.7a7.17 7.17 0 013.6-.972c.71 0 1.643.22 2.8.655 1.154.436 1.895.656 2.22.656.243 0 1.068-.258 2.47-.773 1.323-.48 2.44-.678 3.352-.598 2.476.2 4.337 1.174 5.58 2.924-2.214 1.342-3.31 3.222-3.287 5.637.022 1.88.7 3.444 2.036 4.69.606.575 1.283.02 2.03.303-.163.471-.334.924-.513 1.36zM13.22 1.124C13.22 2.62 12.67 4.014 11.57 5.3c-1.32 1.536-2.917 2.422-4.647 2.283-.022-.18-.034-.369-.034-.559 0-1.435.624-2.971 1.733-4.228.554-.633 1.258-1.16 2.112-1.58.852-.415 1.658-.643 2.417-.684.022.2.031.4.031.601l.038-.009z" />
                </svg>
                iOS · Coming Soon
              </span>
              <span className="inline-flex items-center gap-2 rounded-full bg-[#0099FF]/30 px-4 py-2 text-sm font-semibold text-white">
                <svg className="h-4 w-4" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M17.523 15.341C17.203 16.246 16.848 17.103 16.457 17.915C15.894 19.09 15.434 19.902 15.081 20.352C14.532 21.017 13.944 21.35 13.317 21.363C12.867 21.363 12.324 21.233 11.692 20.973C11.058 20.711 10.475 20.58 9.942 20.58C9.382 20.58 8.782 20.711 8.142 20.973C7.5 21.233 6.984 21.369 6.592 21.382C5.992 21.408 5.39 21.068 4.783 20.36C4.4 19.894 3.921 19.06 3.346 17.86C2.73 16.575 2.224 15.084 1.824 13.385C1.396 11.552 1.181 9.777 1.181 8.059C1.181 6.091 1.607 4.394 2.457 2.968C3.127 1.826 4.017 0.926 5.129 0.268C6.241 -0.39 7.441 -0.72 8.733 -0.72C9.443 -0.72 10.376 -0.5 11.533 -0.065C12.687 0.371 13.428 0.591 13.753 0.591C13.996 0.591 14.821 0.333 16.223 -0.182C17.546 -0.662 18.663 -0.86 19.575 -0.78C22.051 -0.58 23.912 0.394 25.155 2.144C22.941 3.486 21.845 5.366 21.868 7.781C21.89 9.661 22.568 11.225 23.904 12.471C24.51 13.046 25.187 12.491 25.934 12.774C25.771 13.245 25.6 13.698 25.421 14.134Z" />
                </svg>
                Android · Available Now
              </span>
            </div>
          </div>

          {/* Right: action panel */}
          <div className="flex flex-col justify-center gap-4 bg-white p-8 lg:rounded-l-3xl">
            <div>
              <p className="text-xs font-bold uppercase tracking-widest text-[#7a8086]">
                Step 1 of 1
              </p>
              <p className="mt-1 text-lg font-bold text-[#353839]">
                Get the Android APK
              </p>
              <p className="mt-1 text-sm text-[#5f6368]">
                Tap below to download directly to your device.
              </p>
            </div>

            <Link
              href="/downloads/wah4p-android.apk"
              className="inline-flex h-13 w-full items-center justify-center gap-2 rounded-2xl bg-[#46017D] text-sm font-bold text-white shadow-lg shadow-[#46017D]/30 transition-all duration-200 hover:bg-[#5a02a3] hover:-translate-y-0.5 hover:shadow-[#46017D]/50 active:scale-95"
            >
              <svg
                className="h-5 w-5"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
                strokeWidth={2.5}
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"
                />
              </svg>
              Download Android APK
            </Link>

            {/* Apple coming soon */}
            <div className="rounded-2xl border border-[#FF9100]/25 bg-[#FF9100]/6 px-4 py-4">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <svg
                    className="h-5 w-5 text-[#b36200]"
                    viewBox="0 0 24 24"
                    fill="currentColor"
                  >
                    <path d="M17.523 15.341c-.32.905-.676 1.762-1.066 2.574-.563 1.175-1.023 1.987-1.376 2.437-.549.665-1.137.998-1.764 1.011-.45 0-.993-.13-1.625-.39-.634-.262-1.217-.393-1.75-.393-.56 0-1.16.131-1.8.393-.642.26-1.158.396-1.55.409-.6.026-1.202-.314-1.809-1.022-.383-.466-.862-1.3-1.437-2.5-.616-1.285-1.122-2.776-1.522-4.475-.428-1.833-.643-3.608-.643-5.326 0-1.968.426-3.665 1.276-5.091.67-1.142 1.56-2.042 2.672-2.7a7.17 7.17 0 013.6-.972c.71 0 1.643.22 2.8.655 1.154.436 1.895.656 2.22.656.243 0 1.068-.258 2.47-.773 1.323-.48 2.44-.678 3.352-.598 2.476.2 4.337 1.174 5.58 2.924-2.214 1.342-3.31 3.222-3.287 5.637.022 1.88.7 3.444 2.036 4.69.606.575 1.283.02 2.03.303-.163.471-.334.924-.513 1.36zM13.22 1.124C13.22 2.62 12.67 4.014 11.57 5.3c-1.32 1.536-2.917 2.422-4.647 2.283-.022-.18-.034-.369-.034-.559 0-1.435.624-2.971 1.733-4.228.554-.633 1.258-1.16 2.112-1.58.852-.415 1.658-.643 2.417-.684.022.2.031.4.031.601l.038-.009z" />
                  </svg>
                  <div>
                    <p className="text-sm font-bold text-[#353839]">Apple iPhone</p>
                    <p className="text-xs text-[#b36200]">Coming soon</p>
                  </div>
                </div>
                <span className="rounded-full bg-[#FF9100]/20 px-2.5 py-1 text-xs font-bold text-[#b36200]">
                  Soon
                </span>
              </div>
            </div>

            <p className="text-center text-xs text-[#9ca3af]">
              Free to download · No account required to browse
            </p>
          </div>
        </div>
      </div>

      {/* Footer */}
      <p className="mt-10 text-center text-sm text-[#9ca3af]">
        © {new Date().getFullYear()} WAH for Patients · Built for patients, by the WAH team
      </p>
    </section>
  );
}
