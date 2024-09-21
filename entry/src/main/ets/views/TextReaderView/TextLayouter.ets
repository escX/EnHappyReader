import { TextLineLocation } from './TextParser'

class TextLayouter {
  private startLineIndex: number = 0
  private preRenderPage: number = 0
  private pageHeight: number = 0
  private linesLocation: Array<TextLineLocation> = []

  constructor(startLineIndex: number, preRenderPage: number, pageHeight: number, linesLocation: Array<TextLineLocation>) {
    this.startLineIndex = startLineIndex
    this.preRenderPage = preRenderPage
    this.pageHeight = pageHeight
    this.linesLocation = linesLocation
  }

  private getOverLines(upDistance: number): Array<TextLineLocation> {
    const totalHeight = this.preRenderPage * this.pageHeight + upDistance
    const lines: Array<TextLineLocation> = []

    for(let i = this.startLineIndex, h = 0; i > 0; i--) {
      if (h >= totalHeight) {
        break
      }

      const thisLine = this.linesLocation[i]
      lines.unshift(thisLine)
      // h += thisLine.height
    }

    return lines
  }

  private getUnderLines(downDistance: number): Array<TextLineLocation> {
    const totalHeight = (this.preRenderPage + 1) * this.pageHeight + downDistance
    const lines: Array<TextLineLocation> = []

    for(let i = this.startLineIndex, h = 0; i < this.linesLocation.length; i++) {
      if (h >= totalHeight) {
        break
      }

      const thisLine = this.linesLocation[i]
      lines.push(thisLine)
      // h += thisLine.height
    }

    return lines
  }

  getLines(upDistance: number, downDistance: number): Array<TextLineLocation> {
    return [...this.getOverLines(upDistance), ...this.getUnderLines(downDistance)]
  }
}

export default TextLayouter