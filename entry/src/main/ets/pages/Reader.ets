import Constants from '../common/Constants'
import StatusBar from '../common/StatusBar'
import TextReaderView from '../views/TextReaderView'
import ReaderBottomBar from '../views/ReaderBottomBar'

@Entry(LocalStorage.getShared())
@Component
struct Reader {
  private context = getContext()
  private statusBar: StatusBar = new StatusBar()
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
      this.bottomBarController.close()
    }
  })

  aboutToAppear() {
    // 设置全屏布局
    this.statusBar.setFullScreen(this.context)
  }

  onPageShow(): void {
    this.hideBar()
  }

  onPageHide() {
    this.showBar()
    this.bottomBarController.close()
  }

  showBar() {
    if (!this.statusBar.isShow) {
      this.statusBar.show(this.context)
    }
  }

  hideBar() {
    if (this.statusBar.isShow) {
      this.statusBar.hide(this.context)
    }
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
          this.bottomBarController.open()
        }),
        LongPressGesture().onAction(() => {
          this.hideBar()
          this.bottomBarController.close()
        }),
        PanGesture().onActionStart(() => {
          this.hideBar()
          this.bottomBarController.close()
        }),
        RotationGesture().onActionStart(() => {
          this.hideBar()
          this.bottomBarController.close()
        }),
        SwipeGesture().onAction(() => {
          this.hideBar()
          this.bottomBarController.close()
        }),
        TapGesture().onAction(() => {
          this.hideBar()
          this.bottomBarController.close()
        }),
      )
    )
  }
}