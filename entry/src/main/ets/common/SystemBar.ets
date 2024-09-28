import { window } from '@kit.ArkUI'

type PresetBackground = 'white' | 'transparent'

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

  displayStatusBar(show: boolean, preset: PresetBackground = 'transparent'): void {
    if (this.mainWindow && show !== this.isShow) {
      this.isShow = show

      let barColor = '#00FFFFFF'
      let contentColor = '#FF000000'
      if (preset === 'white') {
        barColor = '#FFFFFFFF'
        contentColor = '#FF000000'
      }

      this.mainWindow.setWindowSystemBarProperties({
        statusBarColor: show ? barColor : '#00000000',
        navigationBarColor: show ? barColor : '#00000000',
        statusBarContentColor: show ? contentColor : '#00FFFFFF',
        navigationBarContentColor: show ? contentColor : '#00FFFFFF'
      })
    }
  }
}

export const systemBar = new SystemBar()