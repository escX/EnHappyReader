import { window } from '@kit.ArkUI'

class SystemBar {
  private mainWindow: window.Window | null = null
  private isShow: boolean = true

  setMainWindow(mainWindow: window.Window) {
    this.mainWindow = mainWindow
  }

  setFullScreen(full: boolean): Promise<void> {
    if (this.mainWindow) {
      return this.mainWindow.setWindowLayoutFullScreen(full)
    }

    return Promise.reject()
  }

  enableNaviBar(enable: boolean): void {
    this.mainWindow?.setSpecificSystemBarEnabled('navigationIndicator', enable)
  }

  displayStatusBar(show: boolean): void {
    if (this.mainWindow && show !== this.isShow) {
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