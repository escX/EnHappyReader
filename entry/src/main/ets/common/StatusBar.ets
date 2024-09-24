import { window } from '@kit.ArkUI'

class StatusBar {
  private mainWindow: window.Window | null = null
  private initSystemBarProps: window.SystemBarProperties | null = null
  public isShow: boolean = true

  private getMainWindow(context: Context): Promise<window.Window> {
    return new Promise((resolve, reject) => {
      if (this.mainWindow) {
        resolve(this.mainWindow)
      } else {
        window.getLastWindow(context).then((mainWindow) => {
          this.mainWindow = mainWindow
          this.initSystemBarProps = mainWindow.getWindowSystemBarProperties()
          resolve(mainWindow)
        }).catch(() => {
          reject()
        })
      }
    })
  }

  setFullScreen(context: Context) {
    this.getMainWindow(context).then((mainWindow) => {
      mainWindow.setWindowLayoutFullScreen(true)
    })
  }

  show(context: Context): void {
    this.displayStatusBar(context, true)
  }

  hide(context: Context): void {
    this.displayStatusBar(context, false)
  }

  private displayStatusBar(context: Context, show: boolean): void {
    this.getMainWindow(context).then((mainWindow) => {
      this.isShow = show
      const statusBarColor = this.initSystemBarProps?.statusBarColor ?? '#FFFFFFFF'
      const navigationBarColor = this.initSystemBarProps?.navigationBarColor ?? '#FFFFFFFF'
      const statusBarContentColor = this.initSystemBarProps?.statusBarContentColor ?? '#FF000000'
      const navigationBarContentColor = this.initSystemBarProps?.navigationBarContentColor ?? '#FF000000'

      // 设置透明
      mainWindow.setWindowSystemBarProperties({
        statusBarColor: show ? statusBarColor : '#00000000', // 状态栏背景色，默认 #66000000
        navigationBarColor: show ? navigationBarColor : '#00000000', // 导航栏背景色，默认 #66000000
        statusBarContentColor: show ? statusBarContentColor : '#00FFFFFF', // 状态栏文字颜色，默认 #E5FFFFFF
        navigationBarContentColor: show ? navigationBarContentColor : '#00FFFFFF' // 导航栏文字颜色，默认 #E5FFFFFF
      })

      // 会使状态栏和导航栏隐藏
      // mainWindow.setWindowSystemBarEnable(show ? ['status', 'navigation'] : [])
      // mainWindow.setSpecificSystemBarEnabled('status', show)
      // mainWindow.setSpecificSystemBarEnabled('navigation', show)
      // mainWindow.setSpecificSystemBarEnabled('navigationIndicator', show)
      // 设置全屏布局，有一些问题，路由返回时没有生效，改为在页面中始终使用全屏布局，不再动态改变
      // mainWindow.setWindowLayoutFullScreen(!show)
    })
  }
}

export default StatusBar