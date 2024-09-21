import fs from '@ohos.file.fs'
import { BusinessError } from '@kit.BasicServicesKit'

interface TextLineLocation {
  start: number
  length: number
}

// interface ParseLocationParams {
//   uiContext: UIContext
//   lineWidth: number
//   fontSize: number
//   lineHeight: number
//   fontWeight: FontWeight
//   fontFamily: string
// }

// const textSize = uiContextMeasure.measureTextSize({
//   textContent: it.value.replaceAll(/\n/g, ''),
//   constraintWidth: params.lineWidth,
//   fontSize: params.fontSize,
//   lineHeight: params.lineHeight,
//   fontWeight: params.fontWeight,
//   fontFamily: params.fontFamily
// })

// {
//   uiContext: this.uiContext,
//   lineWidth: this.screenW - Constants.SCREEN_MARGIN_X * 2,
//   fontSize: Constants.DEFAULT_FONT_SIZE,
//   lineHeight: Constants.DEFAULT_LINE_HEIGHT_RATIO * Constants.DEFAULT_FONT_SIZE,
//   fontWeight: Constants.DEFAULT_FONT_WEIGHT,
//   fontFamily: Constants.DEFAULT_FONT_FAMILY,
// }

// const res: TextLineLocation = {
//   start: currStart,
//   end: currStart + it.value.length,
//   height: px2vp(textSize.height as number)
// }

function parseLocation(filePath: string): Promise<Array<TextLineLocation>> {
  return new Promise((resolve, reject) => {
    fs.readLines(filePath, { encoding: 'utf-8' }).then((readerIterator: fs.ReaderIterator) => {
      const locationData: Array<TextLineLocation> = []
      let currStart: number = 0

      for (let it = readerIterator.next(); !it.done; it = readerIterator.next()) {
        const textLength = it.value.length
        locationData.push({
          start: currStart,
          length: textLength
        })
        currStart += textLength
      }

      resolve(locationData)
    }).catch((err: BusinessError) => {
      reject(err)
    })
  })
}

export { TextLineLocation, parseLocation }