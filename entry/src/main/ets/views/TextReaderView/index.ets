import Constants from '../../common/Constants'
import TextParser from './TextParser'
import TextNodeController from './TextNodeController'
import TextLayouter from './TextLayouter'
import { BusinessError } from '@kit.BasicServicesKit'

@Component
export default struct TextReaderView {
  private uiContext: UIContext = this.getUIContext()
  private textNodeController: TextNodeController = new TextNodeController()
  private textParser: TextParser = new TextParser()
  private textLayouter: TextLayouter | null = null
  private scroller: Scroller = new Scroller()
  @Require @Watch('parseTextLine') @Prop bookPath: string | undefined
  @Require @Watch('parseTextLine') @Prop screenW: number
  @Require @Watch('parseTextLine') @Prop screenH: number
  private startLineIndex: number = 0 // 首页首行在文件中的索引
  private maxUpDistance: number = 0 // 最大向上滚动距离
  private maxDownDistance: number = 0 // 最大向下滚动距离
  private scrollOffsetY: number = 0 // 相对初始位置的滚动距离

  // 布局初始化和渲染
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
        this.renderNextLines(0).then(() => {
          this.renderPrevLines(0) // 必须保证 Prev 最后渲染，否则 scrollBy 可能会被 Next 的渲染覆盖不生效
        })
      })
    }
  }

  // 渲染下方的增量 Span
  renderNextLines(downDistance: number): Promise<void> {
    return new Promise((resolve, reject) => {
      this.textLayouter?.getNextLines(downDistance)
        .then((data) => {
          if (data.length > 0) {
            this.textNodeController.append(data)
            this.maxDownDistance = downDistance
          }
          resolve()
        })
        .catch((err: BusinessError) => {
          reject(err)
        })
    })
  }

  // 渲染上方的增量 Span
  renderPrevLines(upDistance: number): Promise<void> {
    return new Promise((resolve, reject) => {
      this.textLayouter?.getPrevLines(upDistance)
        .then((data) => {
          if (data.length > 0) {
            this.textNodeController.prepend(data)
            this.maxUpDistance = upDistance
            this.scroller.scrollBy(0, this.textLayouter?.getIncrementPrevHeight()) // 滚动容器内容上方增加了高度，需要 ScrollBy 向下滑动这个距离
          }
          resolve()
        })
        .catch((err: BusinessError) => {
          reject(err)
        })
    })
  }

  // 进行计算增量渲染的条件：当前滚动距离，超出之前最大滚动距离，半个以上屏幕
  needLayoutPrev() {
    return -this.scrollOffsetY - this.maxUpDistance > this.screenH / 2
  }

  // 进行计算增量渲染的条件：当前滚动距离，超出之前最大滚动距离，半个以上屏幕
  needLayoutNext() {
    return this.scrollOffsetY - this.maxDownDistance > this.screenH / 2
  }

  build() {
    Scroll(this.scroller) {
      NodeContainer(this.textNodeController)
        .width('100%')
    }
    .height('100%')
    .width('100%')
    .align(Alignment.TopStart) // 子元素在顶部对齐
    .scrollBar(BarState.Off) // 不显示滚动条
    .edgeEffect(EdgeEffect.Fade) // 滚动到底后显示半弧形阴影
    .friction(1) // 弹性滚动摩擦系数
    .onWillScroll((xOffset: number, yOffset: number, scrollState: ScrollState, scrollSource: ScrollSource) => {
      if (scrollState === ScrollState.Idle && scrollSource === ScrollSource.SCROLLER) {
        this.scrollOffsetY -= yOffset // 减去 scrollBy 的距离
      }
    })
    .onDidScroll((xOffset: number, yOffset: number) => {
      this.scrollOffsetY += yOffset
    })
    .onScrollStop(() => {
      if (this.scrollOffsetY > 0 && this.needLayoutNext()) {
        this.renderNextLines(this.scrollOffsetY)
      }
      if (this.scrollOffsetY < 0 && this.needLayoutPrev()) {
        this.renderPrevLines(-this.scrollOffsetY)
      }
    })
  }
}