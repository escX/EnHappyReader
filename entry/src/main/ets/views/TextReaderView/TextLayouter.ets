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

interface NodeRecord {
  text: string
  height: number
}

class TextLayouter {
  private uiContext: UIContext
  private filePath: string
  private startLineIndex: number
  private preRenderPage: number
  private pageHeight: number
  private linesLocation: Array<TextLineLocation>
  private textStyle: TextStyle
  private prevNodeRecord: Record<string, NodeRecord> = {} // 记录向上翻页时渲染的 Span 数据
  private nextNodeRecord: Record<string, NodeRecord> = {} // 记录向下翻页时渲染的 Span 数据
  private prevLines: Array<SpanNode> = [] // 返回向上翻页时增量 Span 数据
  private nextLines: Array<SpanNode> = [] // 返回向下翻页时增量 Span 数据

  constructor(params: TextLayouterParams) {
    this.uiContext = params.uiContext
    this.filePath = params.filePath
    this.preRenderPage = params.preRenderPage
    this.pageHeight = params.pageHeight
    this.linesLocation = params.linesLocation
    this.textStyle = params.textStyle

    if (params.startLineIndex < 0) {
      this.startLineIndex = 0
    } else if (params.startLineIndex > params.linesLocation.length - 1) {
      this.startLineIndex = params.linesLocation.length - 1
    } else {
      this.startLineIndex = params.startLineIndex
    }
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

  private prevLinesLoop(totalHeight: number, index: number = this.startLineIndex - 1, linesHeight: number = 0, overLines: Array<SpanNode> = []): Promise<Array<SpanNode>> {
    if (linesHeight >= totalHeight || index < 0) {
      return Promise.resolve(overLines)
    }

    const record = this.prevNodeRecord[index.toString()]
    if (record === undefined) {
      // 未渲染过的节点，需要计算
      const thisLine = this.linesLocation[index]
      return this.getLineText(thisLine.byteStart, thisLine.byteLen)
        .then((text) => {
          const lineHeight = this.getLineHeight(text)
          // 缓存记录新增的增量节点数据
          this.prevNodeRecord[index.toString()] = {
            text,
            height: lineHeight
          }
          // 保存增量节点数据，计算后将返回这个数据
          this.prevLines.unshift({
            content: text,
            index
          })
          console.log(`testyy prev index:${index}, lineHeight:${lineHeight}, text:${text}`)
          // 保存增量节点数据，计算后将返回这个数据
          return this.prevLinesLoop(
            totalHeight,
            index - 1,
            linesHeight + lineHeight,
            [{ content: text, index }, ...overLines]
          )
        })
    } else {
      // 从缓存记录中读取
      return this.prevLinesLoop(
        totalHeight,
        index - 1,
        linesHeight + record.height,
        [{ content: record.text, index }, ...overLines]
      )
    }
  }

  private nextLinesLoop(totalHeight: number, index: number = this.startLineIndex, linesHeight: number = 0, overLines: Array<SpanNode> = []): Promise<Array<SpanNode>> {
    if (linesHeight >= totalHeight || index >= this.linesLocation.length) {
      return Promise.resolve(overLines)
    }

    const record = this.nextNodeRecord[index.toString()]
    if (record === undefined) {
      // 未渲染过的节点，需要计算
      const thisLine = this.linesLocation[index]
      return this.getLineText(thisLine.byteStart, thisLine.byteLen)
        .then((text) => {
          const lineHeight = this.getLineHeight(text)
          // 缓存记录新增的增量节点数据
          this.nextNodeRecord[index.toString()] = {
            text,
            height: lineHeight
          }
          console.log(`testyy next index:${index}, lineHeight:${lineHeight}, text:${text}`)
          // 保存增量节点数据，计算后将返回这个数据
          this.nextLines.push({
            content: text,
            index
          })
          // 递归计算，直到 Span 节点总高度大于设置的预渲染高度
          return this.nextLinesLoop(
            totalHeight,
            index + 1,
            linesHeight + lineHeight,
            [...overLines, { content: text, index }]
          )
        })
    } else {
      // 从缓存记录中读取
      return this.nextLinesLoop(
        totalHeight,
        index + 1,
        linesHeight + record.height,
        [...overLines, { content: record.text, index }]
      )
    }
  }

  /**
   * 获取向上滚动一段距离时，应该增量渲染 Span 的数据
   * @param upDistance 向上滚动的距离
   * @returns Promise: 增量渲染 Span 的数据
   */
  getPrevLines(upDistance: number): Promise<Array<SpanNode>> {
    const totalHeight = this.preRenderPage * this.pageHeight + upDistance
    this.prevLines = [] // 清空数据
    return this.prevLinesLoop(totalHeight)
      .then(() => {
        return Promise.resolve(this.prevLines)
      })
  }

  /**
   * 获取向下滚动一段距离时，应该增量渲染 Span 的数据
   * @param upDistance 向下滚动的距离
   * @returns Promise: 增量渲染 Span 的数据
   */
  getNextLines(downDistance: number): Promise<Array<SpanNode>> {
    const totalHeight = (this.preRenderPage + 1) * this.pageHeight + downDistance
    this.nextLines = [] // 清空数据
    return this.nextLinesLoop(totalHeight)
      .then(() => {
        return Promise.resolve(this.nextLines)
      })
  }
}

export default TextLayouter