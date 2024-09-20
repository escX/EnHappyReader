import { fileIo as fs } from '@kit.CoreFileKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { MeasureUtils } from '@kit.ArkUI'
import Constants from '../common/Constants'

interface TextLineLocation {
  start: number
  end: number
  height: number
}

interface ParseLocationParams {
  uiContext: UIContext
  lineWidth: number
  fontSize: number
  lineHeight: number
  fontWeight: FontWeight
  fontFamily: string
}

class TextParser {
  private parseLineLocation(start: number, text: string, params: ParseLocationParams): TextLineLocation {
    const uiContextMeasure: MeasureUtils = params.uiContext.getMeasureUtils()
    const textSize = uiContextMeasure.measureTextSize({
      textContent: text.replaceAll(/\n/g, ''),
      constraintWidth: params.lineWidth,
      fontSize: params.fontSize,
      lineHeight: params.lineHeight,
      fontWeight: params.fontWeight,
      fontFamily: params.fontFamily
    })

    return {
      start,
      end: start + text.length - 1,
      height: px2vp(textSize.height as number)
    }
  }

  parseLocation(filePath: string, params: ParseLocationParams): Promise<Array<TextLineLocation>> {
    return new Promise((resolve, reject) => {
      fs.readLines(filePath, { encoding: 'utf-8' }).then((readerIterator: fs.ReaderIterator) => {
        const locationData: Array<TextLineLocation> = []
        let currStart: number = 0

        for (let it = readerIterator.next(); !it.done; it = readerIterator.next()) {
          locationData.push(this.parseLineLocation(currStart, it.value, params))
          currStart += it.value.length
        }

        resolve(locationData)
      }).catch((err: BusinessError) => {
        reject(err.message)
      })
    })
  }
}

export { TextLineLocation }
export default TextParser