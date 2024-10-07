import fs from '@ohos.file.fs'
import { BusinessError } from '@kit.BasicServicesKit'
import { util } from '@kit.ArkTS'

interface LineLocation {
  byteStart: number
  byteLen: number
}

interface StarLocation {}

interface ParseResult extends LineLocation, StarLocation {}

class TextParser {
  private textEncoder = util.TextEncoder.create('utf-8')

  /**
   * 解析文件每行文本的起始位置和长度
   * @param filePath 文件路径
   * @returns Promise: 文件中每行文本的起始位置和长度
   */
  parse(filePath: string): Promise<Array<ParseResult>> {
    return new Promise((resolve, reject) => {
      fs.readLines(filePath, { encoding: 'utf-8' }).then((readerIterator: fs.ReaderIterator) => {
        const result: Array<ParseResult> = []
        let currStart: number = 0

        for (let it = readerIterator.next(); !it.done; it = readerIterator.next()) {
          const byteLen = this.textEncoder.encodeInto(it.value).length
          result.push({
            byteStart: currStart,
            byteLen
          })
          currStart += byteLen
        }

        resolve(result)
      }).catch((err: BusinessError) => {
        reject(err)
      })
    })
  }
}

export { ParseResult, LineLocation, StarLocation }
export default TextParser