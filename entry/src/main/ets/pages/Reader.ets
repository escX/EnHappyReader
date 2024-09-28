import Constants from '../common/Constants'
import { systemBar } from '../common/SystemBar'
import TextReaderView from '../views/TextReaderView'
import ReaderBottomBar from '../views/ReaderBottomBar'

@Entry(LocalStorage.getShared())
@Component
struct Reader {
  private bottomBarController: CustomDialogController = new CustomDialogController({
    builder: ReaderBottomBar(),
    isModal: false,
    alignment: DialogAlignment.BottomStart,
    width: '100%',
    backgroundBlurStyle: BlurStyle.NONE,
    cornerRadius: {
      topLeft: 0, topRight: 0, bottomLeft: 0, bottomRight: 0
    },
    cancel: () => {
      this.hideBar()
      this.closeBottomBar()
    }
  })

  aboutToAppear() {
    // 设置全屏布局
    systemBar.setFullScreen()
  }

  onPageShow(): void {
    this.hideBar()
  }

  onPageHide() {
    this.showBar()
    this.closeBottomBar()
  }

  showBar() {
    if (!systemBar.isShow) {
      systemBar.show()
    }
  }

  hideBar() {
    if (systemBar.isShow) {
      systemBar.hide()
    }
  }

  openBottomBar() {
    systemBar.hideNaviBar()
    this.bottomBarController.open()
  }

  closeBottomBar() {
    systemBar.showNaviBar()
    this.bottomBarController.close()
  }

  build() {
    Column(){
      TextReaderView()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Constants.BG_COLOR_ARRAY[Constants.DEFAULT_BGCOLOR_INDEX])
    .parallelGesture(
      // todo: 自定义菜单：操作按钮，页面信息，配置
      // todo: 状态栏和自定义菜单的动画
      GestureGroup(GestureMode.Exclusive,
        PinchGesture().onActionStart(() => {
          this.showBar()
          this.openBottomBar()
        }),
        LongPressGesture().onAction(() => {
          this.hideBar()
          this.closeBottomBar()
        }),
        PanGesture().onActionStart(() => {
          this.hideBar()
          this.closeBottomBar()
        }),
        RotationGesture().onActionStart(() => {
          this.hideBar()
          this.closeBottomBar()
        }),
        SwipeGesture().onAction(() => {
          this.hideBar()
          this.closeBottomBar()
        }),
        TapGesture().onAction(() => {
          this.hideBar()
          this.closeBottomBar()
        }),
      )
    )
  }
}