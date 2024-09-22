import fs from '@ohos.file.fs'
import { BusinessError } from '@kit.BasicServicesKit'
import { util } from '@kit.ArkTS'

interface TextLineLocation {
  byteStart: number
  byteLen: number
}

class TextParser {
  private textEncoder = util.TextEncoder.create('utf-8')

  /**
   * 解析文件每行文本的起始位置和长度
   * @param filePath 文件路径
   * @returns Promise: 文件中每行文本的起始位置和长度
   */
  parseLocation(filePath: string): Promise<Array<TextLineLocation>> {
    return new Promise((resolve, reject) => {
      fs.readLines(filePath, { encoding: 'utf-8' }).then((readerIterator: fs.ReaderIterator) => {
        const locationData: Array<TextLineLocation> = []
        let currStart: number = 0

        for (let it = readerIterator.next(); !it.done; it = readerIterator.next()) {
          const byteLen = this.textEncoder.encodeInto(it.value).length
          locationData.push({
            byteStart: currStart,
            byteLen
          })
          currStart += byteLen
        }

        resolve(locationData)
      }).catch((err: BusinessError) => {
        reject(err)
      })
    })
  }
}

export { TextLineLocation }
export default TextParser