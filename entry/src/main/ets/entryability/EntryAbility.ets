import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { display, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit'
import { systemBar } from '../common/SystemBar';
import { myPreference } from '../common/MyPreference';

interface ILocalStorage {
  screenW: number
  screenH: number
  statusBarHeight: number
  naviBarHeight: number
  currBookPath: string | undefined
}

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    let mainWindow: window.Window
    windowStage.getMainWindow()
      .then((windowClass) => {
        mainWindow = windowClass
        return myPreference.init(this.context)
      })
      .then(() => {
        systemBar.setMainWindow(mainWindow)

        const displaySize: display.Display = display.getDefaultDisplaySync()
        const statusBar: window.AvoidArea = mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM)
        const naviBar: window.AvoidArea = mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR)

        const myLocalStorage: ILocalStorage = {
          screenW: px2vp(displaySize.width),
          screenH: px2vp(displaySize.height),
          statusBarHeight: px2vp(statusBar.topRect.height),
          naviBarHeight: px2vp(naviBar.bottomRect.height),
          currBookPath: undefined
        }

        return Promise.resolve(myLocalStorage)
      })
      .then((localStorage) => {
        return windowStage.loadContent('pages/Index', new LocalStorage(localStorage))
      })
      .catch((err: BusinessError) => {
        if (err.code) {
          hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
          return;
        }
        hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
      })
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}