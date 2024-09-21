import fs from '@ohos.file.fs'
import { buffer } from '@kit.ArkTS'
import { TextLineLocation } from './TextParser'
import { BusinessError } from '@kit.BasicServicesKit'
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

  private getLineText(start: number, length: number): Promise<string> {
    return new Promise((resolve, reject) => {
      let arrayBuffer = new ArrayBuffer(length)
      let file: fs.File

      fs.open(this.filePath, fs.OpenMode.READ_WRITE)
        .then((thisFile) => {
          file = thisFile
          return fs.read(thisFile.fd, arrayBuffer, {
            offset: start,
            length
          })
        })
        .then((readLen) => {
          let buf = buffer.from(arrayBuffer, 0, readLen)
          resolve(buf.toString())
          fs.close(file)
        })
        .catch((err: BusinessError) => {
          reject(err)
        })
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

  /**
   * 获取向上滚动一段距离时，应该增量渲染 Span 的数据
   * @param upDistance 向上滚动的距离，这个距离应该大于下一个需要渲染 Span 的高度
   * @returns Promise: 增量渲染 Span 的数据
   */
  async getOverLines(upDistance: number): Promise<Array<SpanNode>> {
    const totalHeight = this.preRenderPage * this.pageHeight + upDistance
    const lines: Array<SpanNode> = []

    for(let i = this.startLineIndex, h = 0; i > 0; i--) {
      if (h >= totalHeight) {
        break
      }

      const thisLine = this.linesLocation[i]
      try {
        const text = await this.getLineText(thisLine.start, thisLine.length)
        const lineHeight = this.getLineHeight(text)

        h += lineHeight
        lines.unshift({
          content: text,
          index: i
        })
      } catch (err) {

      }
    }

    return lines
  }

  /**
   * 获取向下滚动一段距离时，应该增量渲染 Span 的数据
   * @param upDistance 向下滚动的距离，这个距离应该大于下一个需要渲染 Span 的高度
   * @returns Promise: 增量渲染 Span 的数据
   */
  async getUnderLines(downDistance: number): Promise<Array<SpanNode>> {
    const totalHeight = (this.preRenderPage + 1) * this.pageHeight + downDistance
    const lines: Array<SpanNode> = []

    const text = await this.getLineText(0, 10)

    // for(let i = this.startLineIndex, h = 0; i < this.linesLocation.length; i++) {
    //   if (h >= totalHeight) {
    //     break
    //   }
    //
    //   const thisLine = this.linesLocation[i]
    //   try {
    //     const text = await this.getLineText(thisLine.start, thisLine.length)
    //     const lineHeight = this.getLineHeight(text)
    //
    //     h += lineHeight
    //     lines.push({
    //       content: text,
    //       index: i
    //     })
    //   } catch (err) {
    //
    //   }
    // }

    return lines
  }

}

export default TextLayouter