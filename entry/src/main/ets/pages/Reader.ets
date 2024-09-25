import Constants from '../common/Constants'
import StatusBar from '../common/StatusBar'
import TextReaderView from '../views/TextReaderView'

const myLocalStorage = LocalStorage.getShared()

@Entry
@Component
struct Reader {
  private context = getContext()
  private statusBar: StatusBar = new StatusBar()

  aboutToAppear() {
    // 设置全屏布局，隐藏状态栏
    this.statusBar.setFullScreen(this.context)
    this.statusBar.hide(this.context)
  }

  onPageHide() {
    this.statusBar.show(this.context)
  }

  build() {
    Column(){
      TextReaderView({}, myLocalStorage)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Constants.BG_COLOR_ARRAY[Constants.DEFAULT_BGCOLOR_INDEX])
    .parallelGesture(
      // todo: 自定义菜单：操作按钮，页面信息，配置
      // todo: 状态栏和自定义菜单的动画
      GestureGroup(GestureMode.Exclusive,
        LongPressGesture().onAction(() => {
          this.statusBar.hide(this.context)
        }),
        PanGesture().onActionStart(() => {
          this.statusBar.hide(this.context)
        }),
        PinchGesture().onActionStart(() => {
          this.statusBar.hide(this.context)
        }),
        RotationGesture().onActionStart(() => {
          this.statusBar.hide(this.context)
        }),
        SwipeGesture().onAction(() => {
          this.statusBar.hide(this.context)
        }),
        TapGesture({ count: 2 }).onAction(() => {
          this.statusBar.isShow ? this.statusBar.hide(this.context) : this.statusBar.show(this.context)
        }),
        TapGesture({ count: 1 }).onAction(() => {
          this.statusBar.hide(this.context)
        }),
      )
    )
  }
}