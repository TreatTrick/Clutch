import { MASCOT_FRAMES } from './mascotFrames.ts';

export interface MascotPlayback {
  clip: 'mood' | 'jump';
  cursor: number;
  loopDirection: 1 | -1;
}

/** 保留跨帧余量，让开心尾帧往返播放，下载后的跳跃持续循环。 */
export const advanceMascotFrame = (state: MascotPlayback, direction: number, step: number): MascotPlayback => {
  if (state.clip === 'jump') {
    return { ...state, cursor: (state.cursor + step) % MASCOT_FRAMES.jump };
  }
  if (direction < 0) {
    return { ...state, cursor: Math.max(0, state.cursor - step), loopDirection: 1 };
  }

  // 只循环最后一秒的开心摇尾巴，避免回放前面的情绪过渡。
  const start = MASCOT_FRAMES.mood - MASCOT_FRAMES.fps;
  const span = MASCOT_FRAMES.mood - 1 - start;
  const distance = state.cursor - start;
  const travel = (state.loopDirection > 0 ? distance : 2 * span - distance) + step;
  if (travel < 0) return { ...state, cursor: state.cursor + step, loopDirection: 1 };
  const phase = travel % (2 * span);
  return {
    ...state,
    cursor: start + (phase <= span ? phase : 2 * span - phase),
    loopDirection: phase < span ? 1 : -1
  };
};
