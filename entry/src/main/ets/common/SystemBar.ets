import { window } from '@kit.ArkUI'
import { common } from '@kit.AbilityKit'

type PresetBackground = 'white' | 'transparent'

class SystemBar {
  public mainWindow: window.Window
  private isShow: boolean = true

  constructor(context: common.UIAbilityContext) {
    this.mainWindow = context.windowStage.getMainWindowSync()
  }

  setFullScreen(full: boolean): void {
    this.mainWindow.setWindowLayoutFullScreen(full)
    this.mainWindow.setSpecificSystemBarEnabled('navigationIndicator', !full)
  }

  displayStatusBar(show: boolean, preset: PresetBackground = 'transparent'): void {
    if (show !== this.isShow) {
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

export default SystemBar