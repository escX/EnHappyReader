import SettingTab from '../views/SettingTab/index'
import ShelfTab from '../views/ShelfTab/index'
import StarTab from '../views/StarTab/index'
import SummaryTab from '../views/SummaryTab/index'
import { SymbolGlyphModifier } from '@kit.ArkUI'
import { systemBar } from '../common/SystemBar'

@Entry(LocalStorage.getShared())
@Component
struct Index {
  @LocalStorageProp('statusBarHeight') statusBarHeight: number = 0
  @LocalStorageProp('naviBarHeight') naviBarHeight: number = 0

  aboutToAppear() {
    systemBar.setFullScreen()
  }

  build() {
    Column(){
      Tabs() {
        // 书架
        TabContent() {
          ShelfTab()
        }.tabBar(BottomTabBarStyle.of({
          normal: new SymbolGlyphModifier($r('sys.symbol.bookshelf'))
        }, '书架'))

        // 统计
        TabContent() {
          SummaryTab()
        }.tabBar(BottomTabBarStyle.of({
          normal: new SymbolGlyphModifier($r('sys.symbol.exercise_records'))
        }, '统计'))

        // 设置
        TabContent() {
          SettingTab()
        }.tabBar(BottomTabBarStyle.of({
          normal: new SymbolGlyphModifier($r('sys.symbol.handwriting_set'))
        }, '设置'))

        // 收藏
        TabContent() {
          StarTab()
        }.tabBar(BottomTabBarStyle.of({
          normal: new SymbolGlyphModifier($r('sys.symbol.heart_square_stack'))
        }, '收藏'))
      }
      .margin({top: this.statusBarHeight, bottom: this.naviBarHeight})
      .divider({strokeWidth: 0.5})
      .barPosition(BarPosition.End)
      .animationMode(AnimationMode.NO_ANIMATION)
      .layoutWeight(1)
    }
  }
}