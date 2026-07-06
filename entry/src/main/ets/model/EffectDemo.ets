export enum EffectDemoId {
  FOREGROUND_BLUR = 0,
  FOREGROUND_EFFECT = 1,
  MOTION_BLUR = 2,
  VISUAL_EFFECT = 3,
  IMAGE_EFFECT = 4,
  DRAWING_COMBINATION = 5,
  COLOR_GRADIENT = 6,
  COLOR_INVERSION = 7
}

export class EffectDemo {
  id: EffectDemoId;
  shortLabel: string;
  title: string;
  hint: string;

  constructor(id: EffectDemoId, shortLabel: string, title: string, hint: string) {
    this.id = id;
    this.shortLabel = shortLabel;
    this.title = title;
    this.hint = hint;
  }
}

export const EFFECT_DEMOS: EffectDemo[] = [
  new EffectDemo(EffectDemoId.FOREGROUND_BLUR, 'Blur', 'Foreground Blur', 'Frosted notification foreground'),
  new EffectDemo(EffectDemoId.FOREGROUND_EFFECT, 'F/X', 'Foreground Effect', 'Blur plus color tuning'),
  new EffectDemo(EffectDemoId.MOTION_BLUR, 'Move', 'Motion Blur', 'Swipe the watch face'),
  new EffectDemo(EffectDemoId.VISUAL_EFFECT, 'Live', 'Visual Effect', 'Tap for real-time rendering'),
  new EffectDemo(EffectDemoId.IMAGE_EFFECT, 'Image', 'Image Effect', 'Tap photo to change filter'),
  new EffectDemo(EffectDemoId.DRAWING_COMBINATION, 'Combo', 'Drawing Combination', 'One grouped effect pass'),
  new EffectDemo(EffectDemoId.COLOR_GRADIENT, 'Color', 'Color Gradient', 'Multi-stop watch background'),
  new EffectDemo(EffectDemoId.COLOR_INVERSION, 'Invert', 'Color Inversion', 'Accessibility contrast preview')
];

export function findEffectDemo(id: EffectDemoId): EffectDemo {
  const found = EFFECT_DEMOS.find((item: EffectDemo) => item.id === id);
  return found ? found : EFFECT_DEMOS[0];
}
