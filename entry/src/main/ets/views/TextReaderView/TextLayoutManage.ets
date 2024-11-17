import fs from '@ohos.file.fs'
import { LineLocation } from './TextParser'

interface SpanNode {
  content: string
  index: number
  height: number
}

interface TextLayoutParams {
  uiContext: UIContext
  filePath: string
  pageHeight: number
  linesLocation: Array<LineLocation>
  topSpace: number
  bottomSpace: number
  lineWidth: number
  fontSize: number
  lineHeight: number
  fontFamily: string
}

class TextLayoutManage {
  private uiContext: UIContext
  private filePath: string
  private pageHeight: number
  private linesLocation: Array<LineLocation>
  private rowHeight: number
  private topSpaceRows: number
  private bottomSpaceRows: number
  private lineWidth: number
  private fontSize: number
  private lineHeight: number
  private fontFamily: string

  constructor(params: TextLayoutParams) {
    this.uiContext = params.uiContext
    this.filePath = params.filePath
    this.pageHeight = params.pageHeight
    this.linesLocation = params.linesLocation
    this.lineWidth = params.lineWidth
    this.fontSize = params.fontSize
    this.lineHeight = params.lineHeight
    this.fontFamily = params.fontFamily

    this.rowHeight = this.getLineHeight('\r\n')
    this.topSpaceRows = Math.ceil(params.topSpace / this.rowHeight)
    this.bottomSpaceRows = Math.ceil(params.bottomSpace / this.rowHeight)
  }

  private getLineText(byteStart: number, byteLen: number): Promise<string> {
    return fs.readText(this.filePath, {
      offset: byteStart,
      length: byteLen,
      encoding: 'utf-8'
    })
  }

  private getLineHeight(text: string): number {
    const uiContextMeasure = this.uiContext.getMeasureUtils()
    const textSize = uiContextMeasure.measureTextSize({
      textContent: text.replaceAll(/\n/g, ''),
      constraintWidth: this.lineWidth,
      fontSize: this.fontSize,
      lineHeight: this.lineHeight,
      fontFamily: this.fontFamily
    })
    return px2vp(textSize.height as number)
  }

  private backwardLinesLoop(index: number, totalHeight: number, linesData: Array<SpanNode>): Promise<Array<SpanNode>> {
    if (totalHeight >= this.pageHeight || index > this.linesLocation.length) {
      return Promise.resolve(linesData)
    }

    // 模拟顶部空行
    if (index === -1) {
      const topSpaceHeight = this.topSpaceRows * this.rowHeight
      return this.backwardLinesLoop(
        index + 1,
        totalHeight + topSpaceHeight,
        [...linesData, { content: Array(this.bottomSpaceRows).fill('\r\n').join(''), index, height: topSpaceHeight }]
      )
    }

    // 模拟底部空行
    if (index === this.linesLocation.length) {
      const bottomSpaceHeight = this.bottomSpaceRows * this.rowHeight
      return this.backwardLinesLoop(
        index + 1,
        totalHeight + bottomSpaceHeight,
        [...linesData, { content: Array(this.bottomSpaceRows).fill('\r\n').join(''), index, height: bottomSpaceHeight }]
      )
    }

    const thisLine = this.linesLocation[index]
    if (thisLine === undefined) {
      return Promise.resolve(linesData)
    }

    return this.getLineText(thisLine.byteStart, thisLine.byteLen).then((text) => {
      const lineHeight = this.getLineHeight(text)
      // 递归计算，直到 Span 节点总高度大于页面高度
      return this.backwardLinesLoop(
        index + 1,
        totalHeight + lineHeight,
        [...linesData, { content: text, index, height: lineHeight }]
      )
    })
  }

  private forwardLinesLoop(index: number, totalHeight: number, linesData: Array<SpanNode>): Promise<Array<SpanNode>> {
    if (totalHeight >= this.pageHeight || index < -1) {
      return Promise.resolve(linesData)
    }

    // 模拟顶部空行
    if (index === -1) {
      const topSpaceHeight = this.topSpaceRows * this.rowHeight
      return this.forwardLinesLoop(
        index - 1,
        totalHeight + topSpaceHeight,
        [{ content: Array(this.topSpaceRows).fill('\r\n').join(''), index: -1, height: topSpaceHeight }, ...linesData]
      )
    }

    // 模拟底部空行
    if (index === this.linesLocation.length) {
      const bottomSpaceHeight = this.bottomSpaceRows * this.rowHeight
      return this.forwardLinesLoop(
        index - 1,
        totalHeight + bottomSpaceHeight,
        [{ content: Array(this.topSpaceRows).fill('\r\n').join(''), index: -1, height: bottomSpaceHeight }, ...linesData]
      )
    }

    const thisLine = this.linesLocation[index]
    if (thisLine === undefined) {
      return Promise.resolve(linesData)
    }

    return this.getLineText(thisLine.byteStart, thisLine.byteLen).then((text) => {
      const lineHeight = this.getLineHeight(text)
      // 递归计算，直到 Span 节点总高度大于页面高度
      return this.forwardLinesLoop(
        index - 1,
        totalHeight + lineHeight,
        [{ content: text, index, height: lineHeight }, ...linesData]
      )
    })
  }

  /**
   * 以 index 开头的行，获取一页文本数据
   * @param index 行索引
   * @returns Promise: 一页文本数据
   */
  getPageLinesStartAt(index?: number): Promise<Array<SpanNode>> {
    if (index === undefined) {
      return Promise.resolve([])
    }

    return this.backwardLinesLoop(index, 0, [])
  }

  /**
   * 以 index 结尾的行，获取一页文本数据
   * @param index 行索引
   * @returns Promise: 一页文本数据
   */
  getPageLinesEndAt(index?: number): Promise<Array<SpanNode>> {
    if (index === undefined) {
      return Promise.resolve([])
    }

    return this.forwardLinesLoop(index, 0, [])
  }

  /**
   * 获取若干行的总高度
   * @param lines 行数据
   * @returns 总高度
   */
  static getLinesHeight(lines: SpanNode[]): number {
    let height: number = 0
    lines.forEach(line => {
      height += line.height
    })
    return height
  }
}

export { SpanNode }
export default TextLayoutManage