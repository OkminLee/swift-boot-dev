/**
 * SwiftBoot Sound System
 * Web Audio API를 사용한 프로그래매틱 사운드 효과
 */

// 사운드 설정 localStorage 키
const SOUND_ENABLED_KEY = "swiftboot-sound-enabled";

// AudioContext 싱글톤 (브라우저에서만 초기화)
let audioContext: AudioContext | null = null;

function getAudioContext(): AudioContext | null {
  if (typeof window === "undefined") return null;

  if (!audioContext) {
    audioContext = new (window.AudioContext || (window as unknown as { webkitAudioContext: typeof AudioContext }).webkitAudioContext)();
  }

  // 일시 중지된 상태면 재개
  if (audioContext.state === "suspended") {
    audioContext.resume();
  }

  return audioContext;
}

// 사운드 설정 확인
export function isSoundEnabled(): boolean {
  if (typeof window === "undefined") return true;
  const stored = localStorage.getItem(SOUND_ENABLED_KEY);
  return stored === null ? true : stored === "true";
}

// 사운드 설정 변경
export function setSoundEnabled(enabled: boolean): void {
  if (typeof window === "undefined") return;
  localStorage.setItem(SOUND_ENABLED_KEY, String(enabled));
}

// 사운드 설정 토글
export function toggleSound(): boolean {
  const newValue = !isSoundEnabled();
  setSoundEnabled(newValue);
  return newValue;
}

/**
 * 성공 사운드 - 상승하는 밝은 멜로디
 * C5 → E5 → G5 (메이저 코드 아르페지오)
 */
export function playSuccess(): void {
  if (!isSoundEnabled()) return;

  const ctx = getAudioContext();
  if (!ctx) return;

  const now = ctx.currentTime;
  const masterGain = ctx.createGain();
  masterGain.connect(ctx.destination);
  masterGain.gain.value = 0.3;

  // 주파수: C5(523), E5(659), G5(784)
  const frequencies = [523.25, 659.25, 783.99];
  const duration = 0.15;

  frequencies.forEach((freq, i) => {
    const osc = ctx.createOscillator();
    const gain = ctx.createGain();

    osc.connect(gain);
    gain.connect(masterGain);

    osc.type = "sine";
    osc.frequency.value = freq;

    const startTime = now + i * duration;
    gain.gain.setValueAtTime(0, startTime);
    gain.gain.linearRampToValueAtTime(0.8, startTime + 0.02);
    gain.gain.exponentialRampToValueAtTime(0.01, startTime + duration + 0.1);

    osc.start(startTime);
    osc.stop(startTime + duration + 0.15);
  });
}

/**
 * 실패 사운드 - 하강하는 톤
 * 짧고 둔탁한 효과음
 */
export function playError(): void {
  if (!isSoundEnabled()) return;

  const ctx = getAudioContext();
  if (!ctx) return;

  const now = ctx.currentTime;

  // 첫 번째 톤 (낮은 음)
  const osc1 = ctx.createOscillator();
  const gain1 = ctx.createGain();

  osc1.connect(gain1);
  gain1.connect(ctx.destination);

  osc1.type = "triangle";
  osc1.frequency.setValueAtTime(280, now);
  osc1.frequency.exponentialRampToValueAtTime(180, now + 0.15);

  gain1.gain.setValueAtTime(0.3, now);
  gain1.gain.exponentialRampToValueAtTime(0.01, now + 0.2);

  osc1.start(now);
  osc1.stop(now + 0.25);

  // 두 번째 톤 (약간의 불협화음)
  const osc2 = ctx.createOscillator();
  const gain2 = ctx.createGain();

  osc2.connect(gain2);
  gain2.connect(ctx.destination);

  osc2.type = "triangle";
  osc2.frequency.setValueAtTime(250, now + 0.05);
  osc2.frequency.exponentialRampToValueAtTime(150, now + 0.2);

  gain2.gain.setValueAtTime(0.15, now + 0.05);
  gain2.gain.exponentialRampToValueAtTime(0.01, now + 0.25);

  osc2.start(now + 0.05);
  osc2.stop(now + 0.3);
}

/**
 * 레벨업 팡파레 - 화려한 상승 멜로디
 * C5 → E5 → G5 → C6 (옥타브 상승)
 */
export function playLevelUp(): void {
  if (!isSoundEnabled()) return;

  const ctx = getAudioContext();
  if (!ctx) return;

  const now = ctx.currentTime;
  const masterGain = ctx.createGain();
  masterGain.connect(ctx.destination);
  masterGain.gain.value = 0.25;

  // 팡파레 멜로디
  const notes = [
    { freq: 523.25, time: 0, duration: 0.12 },      // C5
    { freq: 659.25, time: 0.1, duration: 0.12 },    // E5
    { freq: 783.99, time: 0.2, duration: 0.12 },    // G5
    { freq: 1046.50, time: 0.3, duration: 0.4 },    // C6 (길게)
  ];

  notes.forEach(({ freq, time, duration }) => {
    // 메인 톤 (사인파)
    const osc = ctx.createOscillator();
    const gain = ctx.createGain();

    osc.connect(gain);
    gain.connect(masterGain);

    osc.type = "sine";
    osc.frequency.value = freq;

    const startTime = now + time;
    gain.gain.setValueAtTime(0, startTime);
    gain.gain.linearRampToValueAtTime(1, startTime + 0.02);
    gain.gain.setValueAtTime(1, startTime + duration * 0.7);
    gain.gain.exponentialRampToValueAtTime(0.01, startTime + duration);

    osc.start(startTime);
    osc.stop(startTime + duration + 0.05);

    // 하모닉스 (밝은 느낌 추가)
    const osc2 = ctx.createOscillator();
    const gain2 = ctx.createGain();

    osc2.connect(gain2);
    gain2.connect(masterGain);

    osc2.type = "sine";
    osc2.frequency.value = freq * 2; // 옥타브 위

    gain2.gain.setValueAtTime(0, startTime);
    gain2.gain.linearRampToValueAtTime(0.3, startTime + 0.02);
    gain2.gain.exponentialRampToValueAtTime(0.01, startTime + duration * 0.8);

    osc2.start(startTime);
    osc2.stop(startTime + duration + 0.05);
  });

  // 마지막 음에 글리터 효과 (짧은 고음들)
  const glitterFreqs = [1318, 1568, 2093, 1760];
  glitterFreqs.forEach((freq, i) => {
    const osc = ctx.createOscillator();
    const gain = ctx.createGain();

    osc.connect(gain);
    gain.connect(masterGain);

    osc.type = "sine";
    osc.frequency.value = freq;

    const startTime = now + 0.35 + i * 0.05;
    gain.gain.setValueAtTime(0, startTime);
    gain.gain.linearRampToValueAtTime(0.2, startTime + 0.01);
    gain.gain.exponentialRampToValueAtTime(0.01, startTime + 0.1);

    osc.start(startTime);
    osc.stop(startTime + 0.15);
  });
}

/**
 * 구매 성공 사운드 - 코인 소리
 */
export function playPurchase(): void {
  if (!isSoundEnabled()) return;

  const ctx = getAudioContext();
  if (!ctx) return;

  const now = ctx.currentTime;

  // 높은 금속성 소리
  const osc = ctx.createOscillator();
  const gain = ctx.createGain();

  osc.connect(gain);
  gain.connect(ctx.destination);

  osc.type = "sine";
  osc.frequency.setValueAtTime(2000, now);
  osc.frequency.exponentialRampToValueAtTime(1200, now + 0.1);

  gain.gain.setValueAtTime(0.2, now);
  gain.gain.exponentialRampToValueAtTime(0.01, now + 0.2);

  osc.start(now);
  osc.stop(now + 0.25);

  // 두 번째 음 (살짝 딜레이)
  const osc2 = ctx.createOscillator();
  const gain2 = ctx.createGain();

  osc2.connect(gain2);
  gain2.connect(ctx.destination);

  osc2.type = "sine";
  osc2.frequency.setValueAtTime(1800, now + 0.08);
  osc2.frequency.exponentialRampToValueAtTime(1000, now + 0.18);

  gain2.gain.setValueAtTime(0.15, now + 0.08);
  gain2.gain.exponentialRampToValueAtTime(0.01, now + 0.25);

  osc2.start(now + 0.08);
  osc2.stop(now + 0.3);
}

/**
 * 상자 개봉 사운드 - 신비로운 느낌
 */
export function playChestOpen(): void {
  if (!isSoundEnabled()) return;

  const ctx = getAudioContext();
  if (!ctx) return;

  const now = ctx.currentTime;
  const masterGain = ctx.createGain();
  masterGain.connect(ctx.destination);
  masterGain.gain.value = 0.2;

  // 스윕 사운드 (저음에서 고음으로)
  const osc = ctx.createOscillator();
  const gain = ctx.createGain();

  osc.connect(gain);
  gain.connect(masterGain);

  osc.type = "sine";
  osc.frequency.setValueAtTime(200, now);
  osc.frequency.exponentialRampToValueAtTime(800, now + 0.3);
  osc.frequency.exponentialRampToValueAtTime(1200, now + 0.5);

  gain.gain.setValueAtTime(0.8, now);
  gain.gain.setValueAtTime(0.8, now + 0.4);
  gain.gain.exponentialRampToValueAtTime(0.01, now + 0.6);

  osc.start(now);
  osc.stop(now + 0.7);

  // 반짝임 효과
  const sparkleFreqs = [1047, 1319, 1568, 2093];
  sparkleFreqs.forEach((freq, i) => {
    const sparkle = ctx.createOscillator();
    const sparkleGain = ctx.createGain();

    sparkle.connect(sparkleGain);
    sparkleGain.connect(masterGain);

    sparkle.type = "sine";
    sparkle.frequency.value = freq;

    const startTime = now + 0.4 + i * 0.06;
    sparkleGain.gain.setValueAtTime(0, startTime);
    sparkleGain.gain.linearRampToValueAtTime(0.4, startTime + 0.02);
    sparkleGain.gain.exponentialRampToValueAtTime(0.01, startTime + 0.15);

    sparkle.start(startTime);
    sparkle.stop(startTime + 0.2);
  });
}
