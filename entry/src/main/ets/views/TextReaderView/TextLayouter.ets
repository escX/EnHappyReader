import fs from '@ohos.file.fs'
import { TextLineLocation } from './TextParser'
import { SpanNode } from './TextNodeController'

interface TextLayouterParams {
  uiContext: UIContext
  filePath: string
  startLineIndex: number
  preRenderPage: number
  pageHeight: number
  linesLocation: Array<TextLineLocation>
  textStyle: TextStyle
}

interface TextStyle {
  lineWidth: number
  fontSize: number
  lineHeight: number
  fontWeight: FontWeight
  fontFamily: string
}

class TextLayouter {
  private uiContext: UIContext
  private filePath: string
  private startLineIndex: number
  private preRenderPage: number
  private pageHeight: number
  private linesLocation: Array<TextLineLocation>
  private textStyle: TextStyle

  constructor(params: TextLayouterParams) {
    this.uiContext = params.uiContext
    this.filePath = params.filePath
    this.startLineIndex = params.startLineIndex
    this.preRenderPage = params.preRenderPage
    this.pageHeight = params.pageHeight
    this.linesLocation = params.linesLocation
    this.textStyle = params.textStyle
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
      textContent: text.replaceAll(/\r?\n/g, ''),
      constraintWidth: this.textStyle.lineWidth,
      fontSize: this.textStyle.fontSize,
      lineHeight: this.textStyle.lineHeight,
      fontWeight: this.textStyle.fontWeight,
      fontFamily: this.textStyle.fontFamily
    })
    return px2vp(textSize.height as number)
  }

  private overLinesLoop(totalHeight: number, index: number = this.startLineIndex - 1, linesHeight: number = 0, overLines: Array<SpanNode> = []): Promise<Array<SpanNode>> {
    if (linesHeight >= totalHeight || index < 0) {
      return Promise.resolve(overLines)
    }

    const thisLine = this.linesLocation[index]
    return this.getLineText(thisLine.byteStart, thisLine.byteLen)
      .then((text) => {
        return this.overLinesLoop(
          totalHeight,
          index - 1,
          linesHeight + this.getLineHeight(text),
          [{ content: text, index }, ...overLines]
        )
      })
  }

  private underLinesLoop(totalHeight: number, index: number = this.startLineIndex, linesHeight: number = 0, overLines: Array<SpanNode> = []): Promise<Array<SpanNode>> {
    if (linesHeight >= totalHeight || index >= this.linesLocation.length) {
      return Promise.resolve(overLines)
    }

    const thisLine = this.linesLocation[index]
    return this.getLineText(thisLine.byteStart, thisLine.byteLen)
      .then((text) => {
        return this.underLinesLoop(
          totalHeight,
          index + 1,
          linesHeight + this.getLineHeight(text),
          [...overLines, { content: text, index }]
        )
      })
  }

  /**
   * 获取向上滚动一段距离时，应该增量渲染 Span 的数据
   * @param upDistance 向上滚动的距离，这个距离应该大于下一个需要渲染 Span 的高度
   * @returns Promise: 增量渲染 Span 的数据
   */
  getOverLines(upDistance: number): Promise<Array<SpanNode>> {
    const totalHeight = this.preRenderPage * this.pageHeight + upDistance
    return this.overLinesLoop(totalHeight)
  }

  /**
   * 获取向下滚动一段距离时，应该增量渲染 Span 的数据
   * @param upDistance 向下滚动的距离，这个距离应该大于下一个需要渲染 Span 的高度
   * @returns Promise: 增量渲染 Span 的数据
   */
  getUnderLines(downDistance: number): Promise<Array<SpanNode>> {
    const totalHeight = (this.preRenderPage + 1) * this.pageHeight + downDistance
    return this.underLinesLoop(totalHeight)
  }
}

export default TextLayouter