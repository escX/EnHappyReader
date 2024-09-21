import fs, { ListFileOptions } from '@ohos.file.fs'
import { BusinessError } from '@kit.BasicServicesKit'
import Constants from '../../common/Constants'

interface BookInfo {
  name: string
  size: number
  atime: number
}

function getBooks(context: Context): Promise<Array<BookInfo>> {
  return new Promise((resolve, reject) => {
    let filenames: Array<string> = []
    const listFileOption: ListFileOptions  = {
      recursion: false,
      listNum: 0,
      filter: {
        suffix: Constants.SUPPORT_SUFFIX,
        fileSizeOver: 0,
        lastModifiedAfter: new Date(0).getTime()
      }
    }

    fs.listFile(context.filesDir, listFileOption)
      .then((names) => {
        filenames = names
        const statArray: Array<Promise<fs.Stat>> = names.map((name) => {
          return fs.stat(`${context.filesDir}/${name}`)
        })

        return Promise.allSettled(statArray)
      })
      .then((result: Array<PromiseSettledResult<fs.Stat>>) => {
        const fulfilledRes: Array<BookInfo> = []

        result.forEach((item, index) => {
          if (item.status === 'fulfilled') {
            fulfilledRes.push({
              name: filenames[index],
              size: item.value.size,
              atime: item.value.atime
            })
          }
        })

        resolve(fulfilledRes)
      })
      .catch((err: BusinessError) => {
        reject(err)
      })
  })
}

export { BookInfo }
export default getBooks