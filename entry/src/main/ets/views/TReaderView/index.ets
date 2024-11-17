import { myPreference } from "../../common/MyPreference"
import { preferences } from "@kit.ArkData"
import Constants from "../../common/Constants"
import TextLayoutManage, { SpanNode } from "./TextLayoutManage"
import TextParser from "../TextReaderView/TextParser"
import { common } from "@kit.AbilityKit"
import { window } from "@kit.ArkUI"

interface TextSpan extends SpanNode {
  pageIndex: number
}

@Component
export default struct TReaderView {
  @LocalStorageProp('currBookName') currBookName: string | undefined = undefined
  @LocalStorageProp('statusBarHeight') statusBarHeight: number = 0
  @LocalStorageProp('naviBarHeight') naviBarHeight: number = 0
  @LocalStorageProp('screenW') screenW: number = 0
  @LocalStorageProp('screenH') screenH: number = 0
  @State spanArray: Array<TextSpan> = [] // 当前渲染的文本节点数据
  @State translateY: number = 0 // 当前页面平移距离
  @State offsetY: number = 0 // 单次手势中滑动的距离
  @State fontSize: number = myPreference.getFontSize()
  @State lineHeight: number = myPreference.getLineHeightRatio() * this.fontSize
  @State fontFamily: string = Constants.FONT_FAMILY_ARRAY[myPreference.getFontFamilyIndex()]
  @State paddingX: number = myPreference.getPaddingX()
  private textLayoutManage: TextLayoutManage | null = null
  private textParser: TextParser = new TextParser()
  private uiContext: UIContext = this.getUIContext()
  private context = getContext() as common.UIAbilityContext
  private markIndex: number = -1
  private dataChangeKeys: Array<string> = ['fontSize', 'lineHeightRatio', 'fontFamilyIndex', 'paddingX']
  private bindObserveText: (data: Record<string, preferences.ValueType>) => void = this.observeText.bind(this)
  private bindObserveInactive: (data: window.WindowEventType) => void = this.observeInactive.bind(this)
  private initDistance: number = 0 // 初始也即显示 page0 时的平移距离
  private maxUpDistance: number = 0 // 最大向上滚动距离，始终为0
  private maxDownDistance: number = 0 // 最大向下滚动距离，等于所有页面高度和减去屏幕高度
  private isTextTop: boolean = false // 单次手势是否滚动到了顶部
  private isTextBottom: boolean = false // 单次手势是否滚动到了底部

  aboutToAppear() {
    this.markIndex = this.getMarkStore()
    this.setLayout(this.markIndex)
    this.addTextListener()
    this.addInactiveListener()
  }

  aboutToDisappear() {
    this.setMarkStore()
    this.removeTextListener()
    this.removeInactiveListener()
  }

  // 设置缓存书签
  setMarkStore(): Promise<void> {
    if (!!this.currBookName) {
      return myPreference.setBookMark(this.currBookName, this.markIndex)
    }
    return Promise.reject()
  }

  // 获取缓存书签
  getMarkStore(): number {
    if (!!this.currBookName) {
      return myPreference.getBookMark(this.currBookName)
    }
    return -1
  }

  // 获取当前视窗首行索引（书签）
  getMarkIndex(): number {
    let totalHeight = 0
    let index = -1
    for (let i = 0; i < this.spanArray.length; i++) {
      totalHeight += this.spanArray[i].height
      if (totalHeight >= -this.translateY) {
        index = this.spanArray[i].index
        break
      }
    }
    return index
  }

  // 页面布局，在进入页面和修改页面配置时会执行
  setLayout(startIndex: number) {
    if (!!this.currBookName) {
      this.textParser.takeParseData(this.currBookName).then((linesLocation) => {
        this.textLayoutManage = new TextLayoutManage({
          uiContext: this.uiContext,
          filePath: `${this.context.filesDir}/${this.currBookName}`,
          pageHeight: this.screenH,
          linesLocation,
          topSpace: this.statusBarHeight,
          bottomSpace: this.statusBarHeight,
          lineWidth: this.screenW - this.paddingX * 2,
          fontSize: this.fontSize,
          lineHeight: this.lineHeight,
          fontFamily: this.fontFamily,
        })

        let page_2: TextSpan[] = [] // -2 page
        let page_1: TextSpan[] = [] // -1 page
        let page0: TextSpan[] = []  // 当前页
        let page1: TextSpan[] = []  // +1 page
        let page2: TextSpan[] = []  // +2 page

        this.textLayoutManage.getPageLinesStartAt(startIndex) // 0 page 当前页
          .then((data) => {
            page0 = data.map(item => ({
              index: item.index,
              content: item.content,
              height: item.height,
              pageIndex: 0,
            } as TextSpan))

            const firstSpan = page0[0]
            const lastSpan = page0[page0.length - 1]
            return Promise.all([
              this.textLayoutManage!.getPageLinesStartAt(!!lastSpan ? lastSpan.index + 1 : undefined), // +1 page
              this.textLayoutManage!.getPageLinesEndAt(!!firstSpan ? firstSpan.index - 1 : undefined)  // -1 page
            ])
          })
          .then((data) => {
            page1 = data[0].map(item => ({
              index: item.index,
              content: item.content,
              height: item.height,
              pageIndex: 1,
            } as TextSpan))

            page_1 = data[1].map(item => ({
              index: item.index,
              content: item.content,
              height: item.height,
              pageIndex: -1,
            } as TextSpan))

            const firstSpan = page_1[0]
            const lastSpan = page1[page1.length - 1]

            return Promise.all([
              this.textLayoutManage!.getPageLinesStartAt(!!lastSpan ? lastSpan.index + 1 : undefined), // +2 page
              this.textLayoutManage!.getPageLinesEndAt(!!firstSpan ? firstSpan.index - 1 : undefined)  // -2 page
            ])
          })
          .then((data) => {
            page2 = data[0].map(item => ({
              index: item.index,
              content: item.content,
              height: item.height,
              pageIndex: 2,
            } as TextSpan))

            page_2 = data[1].map(item => ({
              index: item.index,
              content: item.content,
              height: item.height,
              pageIndex: -2,
            } as TextSpan))

            this.spanArray = [...page_2, ...page_1, ...page0, ...page1, ...page2]
            this.initDistance = TextLayoutManage.getLinesHeight([...page_2, ...page_1])
            this.translateY = -this.initDistance
            this.markIndex = this.getMarkIndex()
            const totalTextHeight = TextLayoutManage.getLinesHeight(this.spanArray)
            if (totalTextHeight <= this.screenH) {
              this.maxDownDistance = 0
            } else {
              this.maxDownDistance = totalTextHeight - this.screenH
            }
          })
      })
    }
  }

  // 获取并添加下一页文本，移除之前第一页文本
  getNextPage() {
    const lastSpan = this.spanArray[this.spanArray.length - 1]
    if (!!lastSpan && !!this.textLayoutManage) {
      this.textLayoutManage.getPageLinesStartAt(lastSpan.index + 1).then(data => {
        const firstPageHeight = TextLayoutManage.getLinesHeight(this.spanArray.filter(item => item.pageIndex === -2))
        this.spanArray = [
          ...this.spanArray.filter(item => item.pageIndex !== -2).map(item => ({
            index: item.index,
            height: item.height,
            content: item.content,
            pageIndex: item.pageIndex - 1
          } as TextSpan)),
          ...data.map(item => ({
            index: item.index,
            height: item.height,
            content: item.content,
            pageIndex: 2
          } as TextSpan))
        ]
        this.translateY = -(-this.translateY - firstPageHeight)
        this.markIndex = this.getMarkIndex()
        this.initDistance = TextLayoutManage.getLinesHeight(this.spanArray.filter(item => item.pageIndex === -2 || item.pageIndex === -1))
        const totalTextHeight = TextLayoutManage.getLinesHeight(this.spanArray)
        if (totalTextHeight <= this.screenH) {
          this.maxDownDistance = 0
        } else {
          this.maxDownDistance = totalTextHeight - this.screenH
        }
      })
    }
  }

  // 获取并添加上一页文本，移除之前最后一页文本
  getPrevPage() {
    const firstSpan = this.spanArray[0]
    if (!!firstSpan && !!this.textLayoutManage) {
      this.textLayoutManage.getPageLinesEndAt(firstSpan.index - 1).then(data => {
        const firstPageHeight = TextLayoutManage.getLinesHeight(data)
        this.spanArray = [
          ...data.map(item => ({
            index: item.index,
            height: item.height,
            content: item.content,
            pageIndex: -2
          } as TextSpan)),
          ...this.spanArray.filter(item => item.pageIndex !== 2).map(item => ({
            index: item.index,
            height: item.height,
            content: item.content,
            pageIndex: item.pageIndex + 1
          } as TextSpan)),
        ]
        this.translateY = -(-this.translateY + firstPageHeight)
        this.markIndex = this.getMarkIndex()
        this.initDistance = TextLayoutManage.getLinesHeight(this.spanArray.filter(item => item.pageIndex === -2 || item.pageIndex === -1))
        const totalTextHeight = TextLayoutManage.getLinesHeight(this.spanArray)
        if (totalTextHeight <= this.screenH) {
          this.maxDownDistance = 0
        } else {
          this.maxDownDistance = totalTextHeight - this.screenH
        }
      })
    }
  }

  // 监听页面失焦后，保存书签
  observeInactive(data: window.WindowEventType) {
    if (data == window.WindowEventType.WINDOW_INACTIVE) {
      this.setMarkStore()
    }
  }

  // 添加监听
  addInactiveListener() {
    this.context.windowStage.getMainWindowSync().on("windowEvent", this.bindObserveInactive)
  }

  // 移除监听
  removeInactiveListener() {
    this.context.windowStage.getMainWindowSync().off("windowEvent", this.bindObserveInactive)
  }

  // 监听阅读设置改变，重新布局
  observeText(data: Record<string, preferences.ValueType>) {
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

    this.setLayout(this.markIndex)
  }

  // 添加监听
  addTextListener() {
    myPreference.onDataChange(this.dataChangeKeys, this.bindObserveText)
  }

  // 移除监听
  removeTextListener() {
    myPreference.offDataChange(this.dataChangeKeys, this.bindObserveText)
  }

  build() {
    Text(){
      ForEach(
        this.spanArray,
        (obj: TextSpan) => Span(obj.content),
        (obj: TextSpan) => obj.index.toString()
      )
    }
    .width('100%')
    .padding({left: this.paddingX, right: this.paddingX})
    .fontSize(this.fontSize)
    .lineHeight(this.lineHeight)
    .fontFamily(this.fontFamily)
    .translate({ x: 0, y: this.translateY + this.offsetY, z: 0 })
    .gesture(
      PanGesture()
        .onActionUpdate((event?: GestureEvent) => {
          if (!event) {
            return
          }

          if (this.isTextTop) {
            return
          }

          if (this.isTextBottom) {
            return
          }

          let offsetY = event.offsetY * Constants.FLIP_RATIO
          const translateY = this.translateY + offsetY

          if (translateY > 0 && translateY >= this.maxUpDistance) {
            offsetY = this.maxUpDistance - this.translateY
            this.isTextTop = true
          } else if (translateY <= 0 && -translateY >= this.maxDownDistance) {
            offsetY = -this.maxDownDistance - this.translateY
            this.isTextBottom = true
          }

          animateTo({
            duration: 300,
            curve: Curve.EaseOut
          }, () => {
            this.offsetY = offsetY
          })
        })
        .onActionEnd(() => {
          this.translateY += this.offsetY
          this.offsetY = 0
          this.isTextTop = false
          this.isTextBottom = false

          if (-this.translateY - this.initDistance >= this.screenH) {
            this.getNextPage()
          } else if (this.initDistance - (-this.translateY) >= this.screenH) {
            this.getPrevPage()
          } else {
            this.markIndex = this.getMarkIndex()
          }
        })
    )
  }
}