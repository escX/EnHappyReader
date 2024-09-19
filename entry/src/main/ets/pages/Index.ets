import SettingsTab from '../views/SettingsTab'
import ShelfTab from '../views/ShelfTab'
import StarTab from '../views/StarTab'
import SummaryTab from '../views/SummaryTab'
import { SymbolGlyphModifier } from '@kit.ArkUI'

const readerStorage = LocalStorage.getShared()

@Entry
@Component
struct Index {
  build() {
    Tabs() {
      // 书架
      TabContent() {
        ShelfTab({}, readerStorage)
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
        SettingsTab()
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
    .divider({strokeWidth: 0.5})
    .barPosition(BarPosition.End)
    .animationMode(AnimationMode.NO_ANIMATION)
  }
}