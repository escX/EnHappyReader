import { LineLocation, ParseResult } from './TextParser'
import TextLayoutManage, { SpanNode } from './TextLayoutManage'
import TextSpanNode from './TextSpanNode'
import { BusinessError } from '@kit.BasicServicesKit'
import Constants from '../../common/Constants'
import { BookMark, myPreference } from '../../common/MyPreference'
import { preferences } from '@kit.ArkData'
import { myKVStore } from '../../common/MyKVStore'

@Component
export default struct TextReaderView {
  @LocalStorageProp('currBookName') currBookName: string | undefined = undefined
  @LocalStorageProp('statusBarHeight') statusBarHeight: number = 0
  @LocalStorageProp('naviBarHeight') naviBarHeight: number = 0
  @LocalStorageProp('screenW') screenW: number = 0
  @LocalStorageProp('screenH') screenH: number = 0
  @Prop @Watch('onPageStateChange') pageState: boolean | null
  @State textSpanArray: Array<SpanNode> = []
  @State fontSize: number = myPreference.getFontSize()
  @State lineHeight: number = myPreference.getLineHeightRatio() * this.fontSize
  @State fontFamily: string = Constants.FONT_FAMILY_ARRAY[myPreference.getFontFamilyIndex()]
  @State paddingX: number = myPreference.getPaddingX()
  private uiContext: UIContext = this.getUIContext()
  private context = getContext()
  private textLayoutManage: TextLayoutManage | null = null
  private scroller: Scroller = new Scroller()
  private bookMark: BookMark = myPreference.getBookMark()
  private dataChangeKeys: Array<string> = ['fontSize', 'lineHeightRatio', 'fontFamilyIndex', 'paddingX']
  private bindObserve: (data: Record<string, preferences.ValueType>) => void = this.observe.bind(this)
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
    if (!!this.currBookName) {
      const mark = this.getLinePosition()
      return myPreference.setBookMark(this.currBookName, mark)
    }
    return Promise.reject()
  }

  // 获取缓存书签
  getBookMark() {
    this.bookMark = myPreference.getBookMark(this.currBookName)
  }

  // 设置 textLayoutManage
  setLayoutManage(linesLocation: ParseResult[], startLineIndex: number) {
    if (!!this.currBookName) {
      this.textLayoutManage = new TextLayoutManage({
        uiContext: this.uiContext,
        filePath: `${this.context.filesDir}/${this.currBookName}`,
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
    if (!!this.currBookName && myKVStore.kvStore) {
      // 拼接解析后的数据
      const bookSliceNumber: number = myPreference.getBookSlice(this.currBookName)
      const getSliceStrAsync: Array<Promise<string>> = []
      for (let i = 0; i < bookSliceNumber; i++) {
        getSliceStrAsync.push(myKVStore.kvStore.get(`${this.currBookName}_${i}`) as Promise<string>)
      }
      Promise.all(getSliceStrAsync).then((value) => {
        const parseStr = value.join('')
        try {
          const parseData: Array<ParseResult> = JSON.parse(parseStr)
          const linesLocation: LineLocation[] = parseData.map(item => {
            const lineLocation: LineLocation = {
              byteStart: item.byteStart,
              byteLen: item.byteLen
            }
            return lineLocation
          })
          this.setLayoutManage(linesLocation, startLineIndex)
          this.buildNode(startLineIndex, startLineOffset)
        } catch(error) {}
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
    this.resetLayout()
    this.textLayout(bookMark.index, bookMark.offset)
  }

  // 重置布局
  resetLayout() {
    this.scroller.scrollTo({ xOffset: 0, yOffset: 0 })
    this.textSpanArray = []
    this.totalOffset = 0
    this.maxDownDistance = 0
    this.maxUpDistance = 0
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
            this.textSpanArray.push(...data)
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
            this.textSpanArray.unshift(...data)
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
      TextSpanNode({
        textSpanArray: this.textSpanArray,
        paddingTop: this.statusBarHeight,
        paddingBottom: this.naviBarHeight,
        paddingX: this.paddingX,
        fontSize: this.fontSize,
        lineHeight: this.lineHeight,
        fontFamily: this.fontFamily
      })
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