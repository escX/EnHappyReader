import Constants from '../../common/Constants'
import TextParser from './TextParser'
import TextNodeController from './TextNodeController'
import TextLayouter from './TextLayouter'

@Component
export default struct TextReaderView {
  private uiContext: UIContext = this.getUIContext()
  private textNodeController: TextNodeController = new TextNodeController()
  private textParser: TextParser = new TextParser()
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
      this.textParser.parseLocation(this.bookPath).then((linesLocation) => {
        this.textLayouter = new TextLayouter({
          uiContext: this.uiContext,
          filePath: this.bookPath!,
          startLineIndex: this.startLineIndex,
          preRenderPage: 2,
          pageHeight: this.screenH,
          linesLocation,
          textStyle: {
            lineWidth: this.screenW - Constants.SCREEN_MARGIN_X * 2,
            fontSize: Constants.DEFAULT_FONT_SIZE,
            lineHeight: Constants.DEFAULT_LINE_HEIGHT_RATIO * Constants.DEFAULT_FONT_SIZE,
            fontWeight: Constants.DEFAULT_FONT_WEIGHT,
            fontFamily: Constants.DEFAULT_FONT_FAMILY,
          }
        })
        this.renderNextLine(0)
        this.renderPrevLine(0)
      })
    }
  }

  renderNextLine(downDistance: number) {
    this.textLayouter?.getNextLines(downDistance).then((data) => {
      if (data.length > 0) {
        this.textNodeController.append(data)
      }
    })
  }

  renderPrevLine(upDistance: number) {
    this.textLayouter?.getPrevLines(upDistance).then((data) => {
      if (data.length > 0) {
        this.textNodeController.prepend(data)
      }
    })
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