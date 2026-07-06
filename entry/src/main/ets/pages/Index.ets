import { common } from '@kit.AbilityKit';
import { effectKit, uiEffect } from '@kit.ArkGraphics2D';
import { image } from '@kit.ImageKit';
import { EFFECT_DEMOS, EffectDemo, EffectDemoId, findEffectDemo } from '../model/EffectDemo';
import { CONTRAST_MATRIX, SEPIA_MATRIX } from '../model/ImageMatrices';

const IMAGE_MODE_ORIGINAL: number = 0;
const IMAGE_MODE_GRAYSCALE: number = 1;
const IMAGE_MODE_SEPIA: number = 2;
const IMAGE_MODE_CONTRAST: number = 3;

@Entry
@Component
struct Index {
  @State selectedEffect: EffectDemoId = EffectDemoId.FOREGROUND_BLUR;
  @State motionRadius: number = 0;
  @State swipeOffset: number = 0;
  @State visualPulse: boolean = false;
  @State inversionEnabled: boolean = true;
  @State imageMode: number = IMAGE_MODE_ORIGINAL;
  @State imageStatus: string = 'Loading image...';
  @State pixelMap: image.PixelMap | undefined = undefined;

  private originalPixelMap: image.PixelMap | undefined = undefined;
  private readonly liveVisualEffect: uiEffect.VisualEffect = uiEffect.createEffect();
  private readonly liveForegroundFilter: uiEffect.Filter = uiEffect.createFilter().blur(1.2);

  aboutToAppear(): void {
    this.loadDemoImage();
  }

  async loadDemoImage(): Promise<void> {
    try {
      const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      const rawFd = await context.resourceManager.getRawFd('effect_scene.jpg');
      const source = image.createImageSource(rawFd);
      const decoded = await source.createPixelMap({
        desiredPixelFormat: image.PixelMapFormat.RGBA_8888
      });
      this.originalPixelMap = decoded;
      this.pixelMap = decoded.cloneSync();
      this.imageStatus = 'Original';
    } catch (error) {
      this.imageStatus = 'Image unavailable';
    }
  }

  selectEffect(id: EffectDemoId): void {
    this.selectedEffect = id;
    this.motionRadius = 0;
    this.swipeOffset = 0;
  }

  pulseVisualEffect(): void {
    if (this.selectedEffect !== EffectDemoId.VISUAL_EFFECT) {
      return;
    }
    this.visualPulse = !this.visualPulse;
  }

  finishMotion(): void {
    this.getUIContext().animateTo({
      duration: 260,
      curve: Curve.EaseOut,
      onFinish: () => {
        this.motionRadius = 0;
        this.swipeOffset = 0;
      }
    }, () => {
      this.swipeOffset = 0;
    });
  }

  async cycleImageEffect(): Promise<void> {
    if (this.selectedEffect !== EffectDemoId.IMAGE_EFFECT || !this.originalPixelMap) {
      return;
    }

    this.imageMode = (this.imageMode + 1) % 4;
    const source = this.originalPixelMap;
    try {
      if (this.imageMode === IMAGE_MODE_ORIGINAL) {
        this.pixelMap = source.cloneSync();
        this.imageStatus = 'Original';
        return;
      }

      let filter: effectKit.Filter = effectKit.createEffect(source);
      if (this.imageMode === IMAGE_MODE_GRAYSCALE) {
        filter = filter.grayscale();
        this.imageStatus = 'Grayscale';
      } else if (this.imageMode === IMAGE_MODE_SEPIA) {
        filter = filter.setColorMatrix(SEPIA_MATRIX);
        this.imageStatus = 'Sepia matrix';
      } else {
        filter = filter.setColorMatrix(CONTRAST_MATRIX);
        this.imageStatus = 'High contrast';
      }
      this.pixelMap = await filter.getEffectPixelMap();
    } catch (error) {
      this.imageStatus = 'Filter failed';
    }
  }

  imageModeLabel(): string {
    if (this.imageMode === IMAGE_MODE_GRAYSCALE) {
      return 'GRAY';
    }
    if (this.imageMode === IMAGE_MODE_SEPIA) {
      return 'SEPIA';
    }
    if (this.imageMode === IMAGE_MODE_CONTRAST) {
      return 'CONTRAST';
    }
    return 'ORIGINAL';
  }

  @Builder
  DemoChip(demo: EffectDemo): void {
    Text(demo.shortLabel)
      .height(22)
      .padding({ left: 8, right: 8 })
      .fontSize(8)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.selectedEffect === demo.id ? '#07101D' : '#C9D7EA')
      .textAlign(TextAlign.Center)
      .backgroundColor(this.selectedEffect === demo.id ? '#7CE7FF' : '#18253A')
      .borderRadius(11)
      .border({
        width: 1,
        color: this.selectedEffect === demo.id ? '#BFF5FF' : '#2B3D57'
      })
      .margin(2)
      .onClick(() => {
        this.selectEffect(demo.id);
      })
  }

  @Builder
  Header(): void {
    Column({ space: 1 }) {
      Text('VISUAL LAB')
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .fontColor('#F5FAFF')
        .letterSpacing(1.1)
      Text('HarmonyOS 6.0.1(21)')
        .fontSize(7)
        .fontColor('#8295AF')
    }
    .width('100%')
  }

  @Builder
  GradientWatchBackground(): void {
    Stack() {
      Circle()
        .width(124)
        .height(124)
        .fill('#00000000')
        .stroke('#54FFFFFF')
        .strokeWidth(1)

      Circle()
        .width(92)
        .height(92)
        .fill('#08142666')
        .stroke('#22FFFFFF')
        .strokeWidth(1)

      ForEach([0, 1, 2, 3], (item: number) => {
        Rect()
          .width(2)
          .height(8)
          .fill('#D8F7FF')
          .borderRadius(1)
          .position({
            x: 67,
            y: item % 2 === 0 ? 5 : 125
          })
          .rotate({ angle: item * 90, centerX: '50%', centerY: item % 2 === 0 ? 64 : -56 })
      }, (item: number) => `${item}`)
    }
    .width(138)
    .height(138)
    .borderRadius(69)
    .linearGradient({
      angle: 138,
      colors: [
        ['#6C5CE7', 0.0],
        ['#1677C8', 0.38],
        ['#00B6C9', 0.68],
        ['#35D08A', 1.0]
      ]
    })
    .shadow({
      radius: 16,
      color: '#5537D9FF',
      offsetX: 0,
      offsetY: 6
    })
  }

  @Builder
  TimeFace(): void {
    Column({ space: 0 }) {
      Text('10:09')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .fontFeature('"tnum" 1')
      Text('WED 10 JUN')
        .fontSize(7)
        .fontWeight(FontWeight.Medium)
        .fontColor('#DDF8FF')
        .letterSpacing(0.8)
    }
  }

  @Builder
  ActivityComplication(): void {
    Column({ space: 1 }) {
      Text('MOVE')
        .fontSize(6)
        .fontColor('#BFEFFF')
      Text('72%')
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
    }
    .width(42)
    .height(34)
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#40101B2A')
    .borderRadius(12)
    .border({ width: 1, color: '#45FFFFFF' })
  }

  @Builder
  ImageComplication(): void {
    Stack({ alignContent: Alignment.Bottom }) {
      if (this.pixelMap) {
        Image(this.pixelMap)
          .width(52)
          .height(40)
          .objectFit(ImageFit.Cover)
      } else {
        Row({ space: 3 }) {
          Circle().width(9).height(9).fill('#FFD66B')
          Rect().width(24).height(12).fill('#4ED1A1').borderRadius(4)
        }
        .width(52)
        .height(40)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#1D5B72')
      }

      Text(this.imageModeLabel())
        .width('100%')
        .height(12)
        .fontSize(5)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .textAlign(TextAlign.Center)
        .backgroundColor('#AA07101D')
    }
    .width(52)
    .height(40)
    .clip(true)
    .borderRadius(11)
    .border({
      width: this.selectedEffect === EffectDemoId.IMAGE_EFFECT ? 1.5 : 1,
      color: this.selectedEffect === EffectDemoId.IMAGE_EFFECT ? '#A6F4FF' : '#40FFFFFF'
    })
    .onClick(() => {
      this.cycleImageEffect();
    })
  }

  @Builder
  NotificationCardContent(): void {
    Row({ space: 6 }) {
      Stack() {
        Circle()
          .width(22)
          .height(22)
          .fill('#5AE0FF')
        Text('!')
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor('#07101D')
      }

      Column({ space: 1 }) {
        Text('Focus reminder')
          .fontSize(8)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .maxLines(1)
        Text('Breathe for 1 minute')
          .fontSize(6)
          .fontColor('#D6E8F6')
          .maxLines(1)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .height(38)
    .padding({ left: 7, right: 7 })
  }

  @Builder
  NotificationCardBody(): void {
    Stack() {
      Rect()
        .width('100%')
        .height('100%')
        .fill('#4A0A1626')
        .radius(13)

      this.NotificationCardContent()
    }
    .width(112)
    .height(38)
    .borderRadius(13)
    .border({ width: 1, color: '#55FFFFFF' })
    .clip(true)
  }

  @Builder
  NotificationCard(): void {
    if (this.selectedEffect === EffectDemoId.FOREGROUND_BLUR) {
      Stack() {
        Stack() {
          Circle()
            .width(72)
            .height(72)
            .fill('#805AE0FF')
            .position({ x: -18, y: -25 })
          Circle()
            .width(68)
            .height(68)
            .fill('#706C5CE7')
            .position({ x: 65, y: 7 })
          Rect()
            .width(112)
            .height(38)
            .fill('#240A1626')
        }
        .width(112)
        .height(38)
        .foregroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THIN, {
          colorMode: ThemeColorMode.DARK,
          adaptiveColor: AdaptiveColor.AVERAGE,
          scale: 0.72
        })
        .borderRadius(13)
        .clip(true)

        this.NotificationCardContent()
      }
      .width(112)
      .height(38)
      .backdropBlur(8)
      .borderRadius(13)
      .border({ width: 1, color: '#70FFFFFF' })
      .clip(true)
    } else if (this.selectedEffect === EffectDemoId.FOREGROUND_EFFECT) {
      Column() {
        this.NotificationCardBody()
      }
      .foregroundEffect({ radius: 3.5 })
      .saturate(1.35)
      .brightness(1.12)
    } else {
      this.NotificationCardBody()
    }
  }

  @Builder
  WatchFaceContent(): void {
    Stack({ alignContent: Alignment.Center }) {
      this.GradientWatchBackground()

      Column() {
        this.TimeFace()
      }
      .position({ x: 39, y: 34 })

      Row({ space: 8 }) {
        this.ActivityComplication()
        this.ImageComplication()
      }
      .position({ x: 18, y: 82 })

      Column() {
        this.NotificationCard()
      }
      .position({ x: 13, y: 116 })
    }
    .width(138)
    .height(158)
  }

  @Builder
  MotionSurface(): void {
    Stack() {
      this.WatchFaceContent()
    }
    .translate({ x: this.swipeOffset })
    .motionBlur({
      radius: this.motionRadius,
      anchor: {
        x: 0.5,
        y: 0.5
      }
    })
    .gesture(
      PanGesture()
        .onActionStart(() => {
          this.motionRadius = 0;
        })
        .onActionUpdate((event: GestureEvent) => {
          this.swipeOffset = Math.max(-24, Math.min(24, event.offsetX));
          this.motionRadius = Math.min(0.8, Math.abs(event.offsetX) / 30);
        })
        .onActionEnd(() => {
          this.finishMotion();
        })
        .onActionCancel(() => {
          this.finishMotion();
        })
    )
  }

  @Builder
  VisualEffectSurface(): void {
    Stack() {
      this.WatchFaceContent()
    }
    .visualEffect(this.liveVisualEffect)
    .foregroundFilter(this.liveForegroundFilter)
    .hueRotate(this.visualPulse ? 34 : 0)
    .saturate(this.visualPulse ? 1.45 : 1.05)
    .scale({
      x: this.visualPulse ? 1.025 : 1,
      y: this.visualPulse ? 1.025 : 1
    })
    .animation({ duration: 260, curve: Curve.EaseInOut })
    .onClick(() => {
      this.pulseVisualEffect();
    })
  }

  @Builder
  DrawingCombinationSurface(): void {
    Stack() {
      this.WatchFaceContent()
    }
    .useEffect(true)
    .backgroundEffect({
      radius: 11,
      saturation: 1.3,
      brightness: 1.08,
      color: '#1A8BD8FF'
    })
    .renderGroup(true)
  }

  @Builder
  InversionSurface(): void {
    Stack() {
      this.WatchFaceContent()
    }
    .allowForceDark(true)
    .invert(this.inversionEnabled ? 1 : 0)
    .onClick(() => {
      this.inversionEnabled = !this.inversionEnabled;
    })
  }

  @Builder
  EffectSurface(): void {
    if (this.selectedEffect === EffectDemoId.MOTION_BLUR) {
      this.MotionSurface()
    } else if (this.selectedEffect === EffectDemoId.VISUAL_EFFECT) {
      this.VisualEffectSurface()
    } else if (this.selectedEffect === EffectDemoId.DRAWING_COMBINATION) {
      this.DrawingCombinationSurface()
    } else if (this.selectedEffect === EffectDemoId.COLOR_INVERSION) {
      this.InversionSurface()
    } else {
      this.WatchFaceContent()
    }
  }

  @Builder
  StatusPanel(): void {
    Column({ space: 2 }) {
      Text(findEffectDemo(this.selectedEffect).title)
        .fontSize(9)
        .fontWeight(FontWeight.Bold)
        .fontColor('#F4FAFF')
        .maxLines(1)
      Text(this.selectedEffect === EffectDemoId.IMAGE_EFFECT ?
        `${findEffectDemo(this.selectedEffect).hint}: ${this.imageStatus}` :
        findEffectDemo(this.selectedEffect).hint)
        .fontSize(7)
        .fontColor('#91A7C3')
        .maxLines(1)
    }
    .width(154)
    .height(32)
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#151E2E')
    .borderRadius(10)
    .border({ width: 1, color: '#26364E' })
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Scroll() {
        Column({ space: 6 }) {
          this.Header()

          Stack({ alignContent: Alignment.Center }) {
            this.EffectSurface()
          }
          .width(158)
          .height(164)
          .backgroundColor('#090F1B')
          .borderRadius(26)
          .border({ width: 1, color: '#233650' })
          .clip(true)

          Flex({
            wrap: FlexWrap.Wrap,
            justifyContent: FlexAlign.Center,
            alignContent: FlexAlign.Center
          }) {
            ForEach(EFFECT_DEMOS, (demo: EffectDemo) => {
              this.DemoChip(demo)
            }, (demo: EffectDemo) => `${demo.id}`)
          }
          .width(172)

          this.StatusPanel()
        }
        .width('100%')
        .padding({ top: 10, bottom: 30 })
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#050914')
  }
}