import { window } from '@kit.ArkUI'
import { common } from '@kit.AbilityKit'

class SystemBar {
  public mainWindow: window.Window

  constructor(context: common.UIAbilityContext) {
    this.mainWindow = context.windowStage.getMainWindowSync()
  }

  setFullScreen(full: boolean): void {
    this.mainWindow.setWindowLayoutFullScreen(full)
    this.mainWindow.setSpecificSystemBarEnabled('navigationIndicator', !full)
  }

  displayStatusBar(show: boolean, barColor: string = '#00000000'): void {
    this.mainWindow.setWindowSystemBarProperties({
      statusBarColor: show ? barColor : '#00000000',
      navigationBarColor: show ? barColor : '#00000000',
      statusBarContentColor: show ? '#FF000000' : '#00FFFFFF',
      navigationBarContentColor: show ? '#FF000000' : '#00FFFFFF'
    })
  }
}

export default SystemBar