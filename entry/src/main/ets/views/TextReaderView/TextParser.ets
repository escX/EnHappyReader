import fs from '@ohos.file.fs'
import { BusinessError } from '@kit.BasicServicesKit'
import { util } from '@kit.ArkTS'
import { myKVStore } from '../../common/MyKVStore'
import { myPreference } from '../../common/MyPreference'

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

  /**
   * 将解析后的数据，分片保存到KVStore中，同时将分片数量保存到首选项中
   * @param bookname 文件名
   * @param parseData 解析后的数据
   * @returns Promise
   */
  storeParseData(bookname: string, parseData: Array<ParseResult>): Promise<void> {
    if (!myKVStore.kvStore) {
      return Promise.reject()
    }
    const dataString = JSON.stringify(parseData)
    const convRatio = 1000 * 1000 * 4 // 为了容错不使用1024，使用1000，每份value长度最大为4MB
    const sliceNumber = Math.ceil(dataString.length / convRatio)
    const slicePutArray: Array<Promise<void>> = []
    for (let i = 0; i < sliceNumber; i++) {
      const sliceItem = dataString.slice(i * convRatio, i * convRatio + convRatio)
      slicePutArray.push(myKVStore.kvStore.put(`${bookname}_${i}`, sliceItem))
    }

    return Promise.all(slicePutArray).then(() => {
      return myPreference.setBookSlice(bookname, sliceNumber)
    })
  }

  /**
   * 从KVStore中，提取解析数据
   * @param bookname 文件名
   * @returns Promise: 解析数据
   */
  takeParseData(bookname: string): Promise<Array<ParseResult>> {
    if (!myKVStore.kvStore) {
      return Promise.reject()
    }
    const sliceNumber: number = myPreference.getBookSlice(bookname)
    const sliceGetArray: Array<Promise<string>> = []
    for (let i = 0; i < sliceNumber; i++) {
      sliceGetArray.push(myKVStore.kvStore.get(`${bookname}_${i}`) as Promise<string>)
    }

    return Promise.all(sliceGetArray).then((value) => {
      try {
        const parseStr = value.join('')
        const parseData: Array<ParseResult> = JSON.parse(parseStr)
        return parseData
      } catch(error) {
        return Promise.reject()
      }
    })
  }
}

export { ParseResult, LineLocation, StarLocation }
export default TextParser