import { window } from '@kit.ArkUI'

class SystemBar {
  private mainWindow: window.Window | null = null
  public isShow: boolean = true

  setMainWindow(mainWindow: window.Window) {
    this.mainWindow = mainWindow
  }

  setFullScreen(): Promise<void> {
    if (this.mainWindow) {
      return this.mainWindow.setWindowLayoutFullScreen(true)
    }

    return Promise.reject()
  }

  show(): void {
    this.displayStatusBar(true)
  }

  hide(): void {
    this.displayStatusBar(false)
  }

  showNaviBar() {
    this.mainWindow?.setSpecificSystemBarEnabled('navigationIndicator', true)
  }

  hideNaviBar() {
    this.mainWindow?.setSpecificSystemBarEnabled('navigationIndicator', false)
  }

  private displayStatusBar(show: boolean): void {
    if (this.mainWindow) {
      this.isShow = show

      // 设置透明
      this.mainWindow.setWindowSystemBarProperties({
        statusBarColor: show ? '#FFFFFFFF' : '#00000000', // '#66000000'
        navigationBarColor: show ? '#FFFFFFFF' : '#00000000', // '#66000000'
        statusBarContentColor: show ? '#FF000000' : '#00FFFFFF', // '#E5FFFFFF'
        navigationBarContentColor: show ? '#FF000000' : '#00FFFFFF' // '#E5FFFFFF'
      })
    }
  }
}

export const systemBar = new SystemBar()