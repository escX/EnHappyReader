import { window, display } from '@kit.ArkUI'
import { common } from '@kit.AbilityKit'
import Constants from '../common/Constants'
import TextReaderView from '../views/TextReaderView'

const readerStorage = LocalStorage.getShared()

@Entry(readerStorage)
@Component
struct Reader {
  @LocalStorageProp('currBookPath') bookPath: string | undefined = undefined
  private stateHeight: number = 0
  private naviHeight: number = 0
  private screenH: number = 0
  @State screenW: number = 0
  private context = getContext(this) as common.UIAbilityContext
  private windowClass: window.Window | null = null
  private initSystemBarProps: window.SystemBarProperties | null = null

  onPageShow(): void {
    // 设置画布高度和行数
    this.screenH = px2vp(display.getDefaultDisplaySync().height)
    this.screenW = px2vp(display.getDefaultDisplaySync().width)

    window.getLastWindow(this.context, (err, windowClass) => {
      if (err.code === 0) {
        // 设置全屏，隐藏状态栏
        this.windowClass = windowClass
        this.displayStatusBar(false)
        windowClass.setWindowLayoutFullScreen(true)

        // 获取状态栏和导航栏高度，用于设置自定义菜单的偏移量
        const stateBar = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM)
        const naviBar = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR)
        this.stateHeight = px2vp(stateBar.topRect.height)
        this.naviHeight = px2vp(naviBar.bottomRect.height)

        // 获取初始状态栏属性值，用于状态栏恢复显示
        this.initSystemBarProps = windowClass.getWindowSystemBarProperties()
      }
    })
  }

  onPageHide(): void {
    if (!!this.windowClass) {
      // 恢复状态栏
      this.displayStatusBar(true, true)
      this.windowClass.setWindowLayoutFullScreen(false)
    }
  }

  // isExist: 是否退出当前页面，是的话，恢复状态栏到初始状态
  displayStatusBar(isShow: boolean, isExist: boolean = false): void {
    if (!!this.windowClass) {
      let statusBarColor: string = '#FFFFFFFF'
      let navigationBarColor: string = '#FFFFFFFF'
      let statusBarContentColor: string = '#FF000000'
      let navigationBarContentColor: string = '#FF000000'

      if (isExist && !!this.initSystemBarProps) {
        statusBarColor = this.initSystemBarProps.statusBarColor as string
        navigationBarColor = this.initSystemBarProps.navigationBarColor as string
        statusBarContentColor = this.initSystemBarProps.statusBarContentColor as string
        navigationBarContentColor = this.initSystemBarProps.navigationBarContentColor as string
      }

      this.windowClass.setWindowSystemBarProperties({
        statusBarColor: isShow ? statusBarColor : '#00000000', // 状态栏背景色，默认 #66000000
        navigationBarColor: isShow ? navigationBarColor : '#00000000', // 导航栏背景色，默认 #66000000
        statusBarContentColor: isShow ? statusBarContentColor : '#00FFFFFF', // 状态栏文字颜色，默认 #E5FFFFFF
        navigationBarContentColor: isShow ? navigationBarContentColor : '#00FFFFFF' // 导航栏文字颜色，默认 #E5FFFFFF
      })
    }
  }

  build() {
    Column(){
      TextReaderView({bookPath: this.bookPath, screenW: this.screenW})
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Constants.BG_COLOR_ARRAY[Constants.DEFAULT_BGCOLOR_INDEX])
    .gesture(GestureGroup(GestureMode.Exclusive,
      TapGesture({ count: 2 })
        .onAction(() => {
          // todo: 自定义菜单：操作按钮，页面信息，配置
          // todo: 状态栏和自定义菜单的动画
          this.displayStatusBar(true)
        }),
      TapGesture({ count: 1 })
        .onAction(() => {
          this.displayStatusBar(false)
        })
    ))
  }
}