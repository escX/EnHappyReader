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
      systemBar.displayStatusBar(false)
      this.closeBottomBar()
    }
  })

  onPageShow(): void {
    systemBar.setFullScreen(true)
    systemBar.displayStatusBar(false)
  }

  onPageHide() {
    systemBar.setFullScreen(false)
    systemBar.displayStatusBar(true, 'transparent')
    this.closeBottomBar()
  }

  openBottomBar() {
    systemBar.enableNaviBar(false)
    this.bottomBarController.open()
  }

  closeBottomBar() {
    systemBar.enableNaviBar(true)
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
      GestureGroup(GestureMode.Exclusive,
        PinchGesture().onActionStart(() => {
          systemBar.displayStatusBar(true, 'white')
          this.openBottomBar()
        }),
        LongPressGesture().onAction(() => {
          systemBar.displayStatusBar(false)
          this.closeBottomBar()
        }),
        PanGesture().onActionStart(() => {
          systemBar.displayStatusBar(false)
          this.closeBottomBar()
        }),
        RotationGesture().onActionStart(() => {
          systemBar.displayStatusBar(false)
          this.closeBottomBar()
        }),
        SwipeGesture().onAction(() => {
          systemBar.displayStatusBar(false)
          this.closeBottomBar()
        }),
        TapGesture().onAction(() => {
          systemBar.displayStatusBar(false)
          this.closeBottomBar()
        })
      )
    )
  }
}