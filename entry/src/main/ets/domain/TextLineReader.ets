import { fileIo as fs } from '@kit.CoreFileKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { MeasureOptions, MeasureUtils } from '@kit.ArkUI'
import Constants from '../common/Constants'

interface TextLineLocation {
  start: number
  end: number
  height: Length | undefined
}

interface TextLineMark {

}

interface TextLineMetaData extends TextLineLocation, TextLineMark {

}

interface ParseParams {
  uiContext: UIContext
  constraintWidth: number
  fontSize: number
  lineHeight: number
  fontWeight: FontWeight
  fontFamily: string
}

class TextLineReader {
  private filePath: string | undefined = undefined

  constructor(filePath: string | undefined) {
    this.filePath = filePath
  }

  private parseTextHeight(uiContext: UIContext, measureOptions: MeasureOptions) {
    const uiContextMeasure: MeasureUtils = uiContext.getMeasureUtils()
    const textSize = uiContextMeasure.measureTextSize(measureOptions)
    return px2vp(textSize.height as number) - Constants.DEFAULT_FONT_SIZE * Constants.DEFAULT_LINE_HEIGHT_RATIO // 减去一个换行符的高度
  }

  parse(params: ParseParams) {
    return new Promise<Array<TextLineMetaData>>((resolve, reject) => {
      const metaData: Array<TextLineMetaData> = []
      let currStart: number = 0

      fs.readLines(this.filePath, { encoding: 'utf-8' }).then((readerIterator: fs.ReaderIterator) => {
        for (let it = readerIterator.next(); !it.done; it = readerIterator.next()) {
          const textLength = it.value.length
          metaData.push({
            start: currStart,
            end: currStart + textLength - 1,
            height: this.parseTextHeight(params.uiContext, {
              textContent: it.value,
              constraintWidth: params.constraintWidth,
              fontSize: params.fontSize,
              lineHeight: params.lineHeight,
              fontWeight: params.fontWeight,
              fontFamily: params.fontFamily
            })
          })
          currStart += textLength
        }

        resolve(metaData)
      }).catch((err: BusinessError) => {
        reject(err.message)
      })
    })

  }
}

export default TextLineReader