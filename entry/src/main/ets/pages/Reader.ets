import Constants from '../common/Constants'
import SystemBar from '../common/SystemBar'
import ReaderBottomBar from '../views/ReaderBottomBar'
import { font } from '@kit.ArkUI'
import { myPreference } from '../common/MyPreference'
import TextReaderView from '../views/TextReaderView'
import { common } from '@kit.AbilityKit'
import { preferences } from '@kit.ArkData'

@Entry(LocalStorage.getShared())
@Component
struct Reader {
  @State bgColorIndex: number = myPreference.getBgColorIndex()
  private context = getContext() as common.UIAbilityContext
  private systemBar = new SystemBar(this.context)
  private bgColorKey = ['bgColorIndex']
  private bindObserveBgColor: (data: Record<string, preferences.ValueType>) => void = this.observeBgColor.bind(this)
  private bottomBarController: CustomDialogController = new CustomDialogController({
    builder: ReaderBottomBar(),
    isModal: false,
    alignment: DialogAlignment.BottomStart,
    width: '100%',
    backgroundBlurStyle: BlurStyle.NONE,
    shadow: ShadowStyle.OUTER_FLOATING_SM,
    openAnimation: {tempo: 0, duration: 0},
    cornerRadius: {
      topLeft: 0, topRight: 0, bottomLeft: 0, bottomRight: 0
    },
    cancel: () => {
      this.systemBar.displayStatusBar(false)
      this.bottomBarController.close()
    }
  })

  registerFont() {
    Constants.FONT_FAMILY_ARRAY.forEach(item => {
      font.registerFont({
        familyName: item,
        familySrc: $rawfile(`fonts/${item}.ttf`)
      })
    })
  }

  // 添加监听
  addTextListener() {
    myPreference.onDataChange(this.bgColorKey, this.bindObserveBgColor)
  }

  // 移除监听
  removeTextListener() {
    myPreference.offDataChange(this.bgColorKey, this.bindObserveBgColor)
  }

  observeBgColor(data: Record<string, preferences.ValueType>) {
    if (data.bgColorIndex !== undefined) {
      this.bgColorIndex = data.bgColorIndex as number
      this.systemBar.displayStatusBar(true, Constants.FILL_COLOR_ARRAY[this.bgColorIndex])
    }
  }

  onPageShow() {
    this.addTextListener()
    this.registerFont()
    this.systemBar.setFullScreen(true)
    this.systemBar.displayStatusBar(false)
    this.systemBar.mainWindow.setWindowKeepScreenOn(true)
  }

  onPageHide() {
    this.removeTextListener()
    this.bottomBarController.close()
    this.systemBar.setFullScreen(false)
    this.systemBar.displayStatusBar(true)
    this.systemBar.mainWindow.setWindowKeepScreenOn(false)
  }

  build() {
    Column(){
      TextReaderView()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Constants.BG_COLOR_ARRAY[this.bgColorIndex])
    .parallelGesture(
      // todo: 自定义菜单：操作按钮，页面信息，配置
      GestureGroup(GestureMode.Exclusive,
        PinchGesture().onActionStart(() => {
          this.systemBar.displayStatusBar(true, Constants.FILL_COLOR_ARRAY[this.bgColorIndex])
          this.bottomBarController.open()
        }),
        LongPressGesture().onAction(() => {
          this.systemBar.displayStatusBar(false)
          this.bottomBarController.close()
        }),
        PanGesture().onActionStart(() => {
          this.systemBar.displayStatusBar(false)
          this.bottomBarController.close()
        }),
        RotationGesture().onActionStart(() => {
          this.systemBar.displayStatusBar(false)
          this.bottomBarController.close()
        }),
        SwipeGesture().onAction(() => {
          this.systemBar.displayStatusBar(false)
          this.bottomBarController.close()
        }),
        TapGesture().onAction(() => {
          this.systemBar.displayStatusBar(false)
          this.bottomBarController.close()
        })
      )
    )
  }
}