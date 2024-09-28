import { window } from '@kit.ArkUI'

class StatusBar {
  private mainWindow: window.Window | null = null
  public isShow: boolean = true

  private getMainWindow(context: Context): Promise<window.Window> {
    return new Promise((resolve, reject) => {
      if (this.mainWindow) {
        resolve(this.mainWindow)
      } else {
        window.getLastWindow(context).then((mainWindow) => {
          this.mainWindow = mainWindow
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

  show(context: Context, useSystemBar: boolean = false): void {
    this.displayStatusBar(context, true, useSystemBar)
  }

  hide(context: Context): void {
    this.displayStatusBar(context, false)
  }

  private displayStatusBar(context: Context, show: boolean, useDefaultBar: boolean = false): void {
    this.getMainWindow(context).then((mainWindow) => {
      this.isShow = show
      const statusBarColor = useDefaultBar ? '#66000000' : '#FFFFFFFF'
      const navigationBarColor = useDefaultBar ? '#66000000' : '#FFFFFFFF'
      const statusBarContentColor = useDefaultBar ? '#E5FFFFFF' : '#FF000000'
      const navigationBarContentColor = useDefaultBar ? '#E5FFFFFF' : '#FF000000'

      // 设置透明
      mainWindow.setWindowSystemBarProperties({
        statusBarColor: show ? statusBarColor : '#00000000',
        navigationBarColor: show ? navigationBarColor : '#00000000',
        statusBarContentColor: show ? statusBarContentColor : '#00FFFFFF',
        navigationBarContentColor: show ? navigationBarContentColor : '#00FFFFFF'
      })

      // 隐藏底部导航条
      mainWindow.setSpecificSystemBarEnabled('navigationIndicator', !show)
    })
  }
}

export default StatusBar