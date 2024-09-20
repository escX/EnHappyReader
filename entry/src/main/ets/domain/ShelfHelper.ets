import picker from '@ohos.file.picker'
import fs, { ListFileOptions } from '@ohos.file.fs'
import { common } from '@kit.AbilityKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { fileUri } from '@kit.CoreFileKit'
import Constants from '../common/Constants'

interface BookInfo {
  name: string
  size: number
  atime: number
}

class ShelfHelper {
  private context: Context | null = null

  constructor(context: Context) {
    this.context = context
  }

  copyBookFromUser(): Promise<void> {
    return new Promise((resolve, reject) => {
      if (this.context) {
        const documentPicker = new picker.DocumentViewPicker(this.context)
        const documentSelectOptions = new picker.DocumentSelectOptions()
        documentSelectOptions.maxSelectNumber = 1
        documentSelectOptions.fileSuffixFilters = Constants.SUPPORT_SUFFIX

        documentPicker.select(documentSelectOptions)
          .then((documentSelectResult) => {
            return documentSelectResult[0]
          })
          .then((userUri) => {
            const fileUriObject = new fileUri.FileUri(userUri)
            return fs.copyFile(fileUriObject.path, `${this.context!.filesDir}/${fileUriObject.name}`)
          })
          .then(() => {
            resolve()
          })
          .catch((err: BusinessError) => {
            reject()
          })
      } else {
        reject()
      }
    })
  }

  getAppBooks(): Promise<Array<BookInfo>> {
    return new Promise((resolve, reject) => {
      if (this.context) {
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

        fs.listFile(this.context.filesDir, listFileOption)
          .then((names) => {
            filenames = names
            const statArray: Array<Promise<fs.Stat>> = names.map((name) => {
              return fs.stat(`${this.context!.filesDir}/${name}`)
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
            reject()
          })
      } else {
        reject()
      }
    })
  }
}

export { BookInfo }
export default ShelfHelper