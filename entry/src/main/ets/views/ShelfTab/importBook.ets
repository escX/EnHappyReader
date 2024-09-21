import picker from '@ohos.file.picker'
import fs from '@ohos.file.fs'
import { BusinessError } from '@kit.BasicServicesKit'
import { fileUri } from '@kit.CoreFileKit'
import Constants from '../../common/Constants'

function importBook(context: Context): Promise<void> {
  return new Promise((resolve, reject) => {
    const documentPicker = new picker.DocumentViewPicker(context)
    const documentSelectOptions = new picker.DocumentSelectOptions()
    documentSelectOptions.maxSelectNumber = 1
    documentSelectOptions.fileSuffixFilters = Constants.SUPPORT_SUFFIX

    documentPicker.select(documentSelectOptions)
      .then((documentSelectResult) => {
        return documentSelectResult[0]
      })
      .then((bookUri) => {
        const fileUriObject = new fileUri.FileUri(bookUri)
        return fs.copyFile(fileUriObject.path, `${context.filesDir}/${fileUriObject.name}`)
      })
      .then(() => {
        resolve()
      })
      .catch((err: BusinessError) => {
        reject(err)
      })
  })
}

export default importBook