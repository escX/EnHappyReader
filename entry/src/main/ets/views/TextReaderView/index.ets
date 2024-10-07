import TextParser, { TextLineLocation } from './TextParser'
import TextNodeController from './TextNodeController'
import TextLayoutManage from './TextLayoutManage'
import { BusinessError } from '@kit.BasicServicesKit'
import Constants from '../../common/Constants'
import { BookMark, myPreference } from '../../common/MyPreference'
import { preferences } from '@kit.ArkData'

@Component
export default struct TextReaderView {
  @LocalStorageProp('currBookPath') currBookPath: string | undefined = undefined
  @LocalStorageProp('statusBarHeight') statusBarHeight: number = 0
  @LocalStorageProp('naviBarHeight') naviBarHeight: number = 0
  @LocalStorageProp('screenW') screenW: number = 0
  @LocalStorageProp('screenH') screenH: number = 0
  @Prop @Watch('onPageStateChange') pageState: boolean | null
  private uiContext: UIContext = this.getUIContext()
  private textNodeController: TextNodeController = new TextNodeController()
  private textParser: TextParser = new TextParser()
  private textLayoutManage: TextLayoutManage | null = null
  private scroller: Scroller = new Scroller()
  private bookMark: BookMark = myPreference.getBookMark()
  private dataChangeKeys: Array<string> = ['fontSize', 'lineHeightRatio', 'fontFamilyIndex', 'paddingX']
  private bindObserve: (data: Record<string, preferences.ValueType>) => void = this.observe.bind(this)
  private fontSize: number = myPreference.getFontSize()
  private lineHeight: number = myPreference.getLineHeightRatio() * this.fontSize
  private fontFamily: string = Constants.FONT_FAMILY_ARRAY[myPreference.getFontFamilyIndex()]
  private paddingX: number = myPreference.getPaddingX()
  private maxUpDistance: number = 0 // 最大向上滚动距离，用于计算需要增量渲染的高度
  private maxDownDistance: number = 0 // 最大向下滚动距离，用于计算需要增量渲染的高度
  private totalOffset: number = 0 // 相对初始位置的滚动距离，用于计算需要增量渲染的高度

  aboutToAppear() {
    this.getBookMark()
    this.textLayout(this.bookMark.index, this.bookMark.offset)
    this.addReadListener()
  }

  aboutToDisappear() {
    this.removeReadListener()
  }

  onPageStateChange() {
    if (this.pageState === false) {
      this.setBookMark()
    }
  }

  // 设置缓存书签
  setBookMark(): Promise<void> {
    if (!!this.currBookPath) {
      const mark = this.getLinePosition()
      return myPreference.setBookMark(this.currBookPath, mark)
    }
    return Promise.reject()
  }

  // 获取缓存书签
  getBookMark() {
    this.bookMark = myPreference.getBookMark(this.currBookPath)
  }

  // 设置 textLayoutManage
  setLayoutManage(linesLocation: TextLineLocation[], startLineIndex: number) {
    if (!!this.currBookPath) {
      this.textLayoutManage = new TextLayoutManage({
        uiContext: this.uiContext,
        filePath: this.currBookPath,
        startLineIndex,
        preRenderPage: 2,
        pageHeight: this.screenH,
        linesLocation,
        textStyle: {
          lineWidth: this.screenW - this.paddingX * 2,
          fontSize: this.fontSize,
          lineHeight: this.lineHeight,
          fontFamily: this.fontFamily,
        }
      })
    }
  }

  // 渲染自定义节点
  buildNode(startLineIndex: number, startLineOffset: number) {
    this.textNodeController.setMargin(this.statusBarHeight, this.naviBarHeight)
    this.textNodeController.setPadding(this.paddingX)
    this.textNodeController.setStyle(this.fontSize, this.lineHeight, this.fontFamily)
    this.renderNextLines(startLineOffset)
      .then(() => {
        return this.renderPrevLines(0) // 必须保证 PrevLines 最后渲染，否则 scrollBy 可能不会作用
      })
      .then((prependHeight) => {
        // 定位初始位置，如果不是首次进入，需要额外滚动 statusBarHeight 的高度
        if (!(startLineIndex === 0 && startLineOffset === 0)) {
          this.scroller.scrollBy(0, prependHeight + this.statusBarHeight + startLineOffset)
        }
      })
  }

  // 页面布局
  textLayout(startLineIndex: number, startLineOffset: number) {
    if (!!this.currBookPath) {
      this.textParser.parseLocation(this.currBookPath).then((linesLocation) => {
        this.setLayoutManage(linesLocation, startLineIndex)
        this.buildNode(startLineIndex, startLineOffset)
      })
    }
  }

  // 监听阅读设置改变，重新布局
  observe(data: Record<string, preferences.ValueType>) {
    if (data.fontSize !== undefined) {
      this.fontSize = data.fontSize as number
      this.lineHeight = (data.fontSize as number) * (myPreference.getLineHeightRatio() as number)
    }

    if (data.lineHeightRatio !== undefined) {
      const ratio = data.lineHeightRatio as number
      this.lineHeight = this.fontSize * ratio
    }

    if (data.fontFamilyIndex !== undefined) {
      const index = data.fontFamilyIndex as number
      this.fontFamily = Constants.FONT_FAMILY_ARRAY[index]
    }

    if (data.paddingX !== undefined) {
      const x = data.paddingX as number
      this.paddingX = x
    }

    const bookMark = this.getLinePosition()
    this.scroller.scrollTo({ xOffset: 0, yOffset: 0 })
    this.textNodeController.reset()
    // 这里重置 textLayout，需要在 onDidScroll 结束后进行，否则会导致 totalOffset 计算错误
    // 目前没有好的方法在 onDidScroll 结束后执行下面的方法，不能放在 onDidScroll 中进行，因为初始位置在顶部时，不会触发滚动，也就不会执行 onDidScroll
    // 在模拟器中测试 onDidScroll 延时为 13ms，不同的机型可能延时有长有短，这里暂取 100ms
    setTimeout(() => {
      this.totalOffset = 0
      this.maxDownDistance = 0
      this.maxUpDistance = 0
      this.textLayout(bookMark.index, bookMark.offset)
    }, 100)
  }

  // 添加监听
  addReadListener() {
    myPreference.onDataChange(this.dataChangeKeys, this.bindObserve)
  }

  // 移除监听
  removeReadListener() {
    myPreference.offDataChange(this.dataChangeKeys, this.bindObserve)
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

  // 获取当前视窗顶部第一行的索引，和相对该行顶部的偏移高度，用于保存书签
  getLinePosition(): BookMark {
    if (this.textLayoutManage) {
      const rect = this.scroller.getItemRect(0)
      if (rect.height !== 0) {
        const scrollOffset = -rect.y
        if (scrollOffset < this.statusBarHeight) {
          return new BookMark(0, 0)
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
          return new BookMark(layoutNodes[nodeIndex].index, lineOffset < 0 ? 0 : lineOffset)
        }
      }
    }

    return new BookMark(this.bookMark.index, this.bookMark.offset)
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