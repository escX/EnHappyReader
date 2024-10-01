import Constants from '../../common/Constants'
import TextParser from './TextParser'
import TextNodeController from './TextNodeController'
import TextLayoutManage from './TextLayoutManage'
import { BusinessError } from '@kit.BasicServicesKit'

interface LinePosition {
  index: number
  offset: number
}

@Component
export default struct TextReaderView {
  @LocalStorageProp('currBookPath') currBookPath: string | undefined = undefined
  @LocalStorageProp('statusBarHeight') statusBarHeight: number = 0
  @LocalStorageProp('naviBarHeight') naviBarHeight: number = 0
  @LocalStorageProp('screenW') screenW: number = 0
  @LocalStorageProp('screenH') screenH: number = 0
  private uiContext: UIContext = this.getUIContext()
  private textNodeController: TextNodeController = new TextNodeController()
  private textParser: TextParser = new TextParser()
  private textLayoutManage: TextLayoutManage | null = null
  private scroller: Scroller = new Scroller()
  private startLineIndex: number = 0 // 首页首行在文件中的索引
  private startOffset: number = 0 // 相对于初始行 startLine 顶部的距离，用于定位初始滚动条位置
  private maxUpDistance: number = 0 // 最大向上滚动距离，用于计算需要增量渲染的高度
  private maxDownDistance: number = 0 // 最大向下滚动距离，用于计算需要增量渲染的高度
  private totalOffset: number = 0 // 相对初始位置的滚动距离，用于计算需要增量渲染的高度

  aboutToAppear() {
    this.textLayout()
  }

  textLayout() {
    if (!!this.currBookPath) {
      this.textParser.parseLocation(this.currBookPath).then((linesLocation) => {
        this.textLayoutManage = new TextLayoutManage({
          uiContext: this.uiContext,
          filePath: this.currBookPath!,
          startLineIndex: this.startLineIndex,
          preRenderPage: 2,
          pageHeight: this.screenH,
          linesLocation,
          textStyle: {
            lineWidth: this.screenW - Constants.SCREEN_MARGIN_X * 2,
            fontSize: Constants.DEFAULT_FONT_SIZE,
            lineHeight: Constants.DEFAULT_LINE_HEIGHT_RATIO * Constants.DEFAULT_FONT_SIZE,
            fontFamily: Constants.FONT_FAMILY_ARRAY[Constants.DEFAULT_FONT_FAMILY_INDEX],
          }
        })

        this.textNodeController.setMargin(this.statusBarHeight, this.naviBarHeight)
        this.renderNextLines(this.startOffset)
          .then(() => {
            return this.renderPrevLines(0) // 必须保证 PrevLines 最后渲染，否则 scrollBy 可能不会作用
          })
          .then((prependHeight) => {
            // 定位初始位置，如果不是首次进入，需要额外滚动 statusBarHeight 的高度
            if (!(this.startLineIndex === 0 && this.startOffset === 0)) {
              this.scroller.scrollBy(0, prependHeight + this.statusBarHeight + this.startOffset)
            }
          })
      })
    }
  }

  // 渲染下方的增量 Span，返回渲染的高度
  renderNextLines(downDistance: number): Promise<number> {
    return new Promise((resolve, reject) => {
      this.textLayoutManage?.getNextLines(downDistance)
        .then((data) => {
          let appendHeight = 0
          if (data.length > 0) {
            this.textNodeController.append(data)
            this.maxDownDistance = downDistance
            appendHeight = this.textLayoutManage?.getIncrementNextHeight() ?? 0
          }
          resolve(appendHeight)
        })
        .catch((err: BusinessError) => {
          reject(err)
        })
    })
  }

  // 渲染上方的增量 Span，返回渲染的高度
  renderPrevLines(upDistance: number): Promise<number> {
    return new Promise((resolve, reject) => {
      this.textLayoutManage?.getPrevLines(upDistance)
        .then((data) => {
          let prependHeight = 0
          if (data.length > 0) {
            this.textNodeController.prepend(data)
            this.maxUpDistance = upDistance
            prependHeight = this.textLayoutManage?.getIncrementPrevHeight() ?? 0
          }
          resolve(prependHeight)
        })
        .catch((err: BusinessError) => {
          reject(err)
        })
    })
  }

  // 进行计算增量渲染的条件：当前滚动距离，超出之前最大滚动距离，半个以上屏幕
  needLayoutPrev() {
    return -this.totalOffset - this.maxUpDistance > this.screenH / 2
  }

  // 进行计算增量渲染的条件：当前滚动距离，超出之前最大滚动距离，半个以上屏幕
  needLayoutNext() {
    return this.totalOffset - this.maxDownDistance > this.screenH / 2
  }

  // 当前视窗顶部第一行的索引，和相对该行顶部的偏移高度，用于下次打开应用的滚动定位
  getLinePosition(): LinePosition {
    if (this.textLayoutManage) {
      const rect = this.scroller.getItemRect(0)
      if (rect.height !== 0) {
        const scrollOffset = -rect.y
        if (scrollOffset < this.statusBarHeight) {
          return {
            index: 0,
            offset: 0
          }
        }
        const layoutNodes = this.textLayoutManage.getNodeRecord()
        if (layoutNodes.length > 0) {
          let nodeIndex = 0
          let nodeHeight = layoutNodes[0].height + this.statusBarHeight

          while (nodeHeight < scrollOffset && nodeIndex < layoutNodes.length - 1) {
            nodeIndex += 1
            nodeHeight += layoutNodes[nodeIndex].height
          }

          const lineOffset = scrollOffset - (nodeHeight - layoutNodes[nodeIndex].height)
          return {
            index: layoutNodes[nodeIndex].index,
            offset: lineOffset < 0 ? 0 : lineOffset
          }
        }
      }
    }

    return {
      index: this.startLineIndex,
      offset: this.startOffset
    }
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
        this.totalOffset -= yOffset // 减去 scrollBy 的距离
      }
    })
    .onDidScroll((xOffset: number, yOffset: number) => {
      this.totalOffset += yOffset
    })
    .onScrollStop(() => {
      if (this.totalOffset > 0 && this.needLayoutNext()) {
        this.renderNextLines(this.totalOffset)
      }
      if (this.totalOffset < 0 && this.needLayoutPrev()) {
        this.renderPrevLines(-this.totalOffset).then((prependHeight) => {
          this.scroller.scrollBy(0, prependHeight) // 滚动容器内容上方增加了高度，需要 ScrollBy 向下滑动这个距离
        })
      }
    })
  }
}