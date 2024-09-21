import Constants from '../../common/Constants'
import { parseLocation } from './TextParser'
import TextNodeController from './TextNodeController'
import TextLayouter from './TextLayouter'

@Component
export default struct TextReaderView {
  private uiContext: UIContext = this.getUIContext()
  private textNodeController: TextNodeController = new TextNodeController()
  private textLayouter: TextLayouter | null = null
  @Require @Watch('parseTextLine') @Prop bookPath: string | undefined
  @Require @Watch('parseTextLine') @Prop screenW: number
  @Require @Watch('parseTextLine') @Prop screenH: number
  private startLineIndex: number = 0 // 首页首行在文件中的索引
  private maxUpDistance: number = 0 // 最大向上滚动距离
  private maxDownDistance: number = 0 // 最大向下滚动距离
  private currScroll: number = 0 // 当前滚动距离

  aboutToAppear() {

  }

  parseTextLine() {
    if (!!this.bookPath && this.screenW > 0 && this.screenH > 0) {
      parseLocation(this.bookPath).then((data) => {
        this.textLayouter = new TextLayouter(this.startLineIndex, 2, this.screenH, data)
        const lines = this.textLayouter.getLines(this.maxUpDistance, this.maxDownDistance)
      })
    }
  }

  build() {
    Scroll() {
      NodeContainer(this.textNodeController)
        .width('100%')
    }
    .height('100%')
    .width('100%')
    .align(Alignment.TopStart)
  }
}