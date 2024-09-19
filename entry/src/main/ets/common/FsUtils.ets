import picker from '@ohos.file.picker'
import fs, { ListFileOptions } from '@ohos.file.fs'
import { common } from '@kit.AbilityKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { fileUri } from '@kit.CoreFileKit'
import Constants from './Constants'

export interface FileInfo {
  name: string
  size: number
  atime: number
}

// 复制用户文件到应用文件
export async function copyFromUser(context: common.UIAbilityContext): Promise<void> {
  const documentPicker = new picker.DocumentViewPicker(context)
  const documentSelectOptions = new picker.DocumentSelectOptions()
  documentSelectOptions.maxSelectNumber = 1
  documentSelectOptions.fileSuffixFilters = Constants.SUPPORT_SUFFIX

  return documentPicker.select(documentSelectOptions)
    .then((documentSelectResult) => {
      return documentSelectResult[0]
    })
    .then((userUri) => {
      const fileUriObject = new fileUri.FileUri(userUri)
      return fs.copyFile(fileUriObject.path, `${context.filesDir}/${fileUriObject.name}`)
    })
    .catch((err: BusinessError) => {
      console.log('testyy error: ', err)
      throw new Error(err.message)
    })
}

// 获取用户文件Stat
export function getFilesInfo(context: common.UIAbilityContext): Promise<Array<FileInfo>> {
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

  return fs.listFile(context.filesDir, listFileOption)
    .then((names) => {
      filenames = names

      const statArray: Array<Promise<fs.Stat>> = names.map((name) => {
        return fs.stat(`${context.filesDir}/${name}`)
      })

      return Promise.allSettled(statArray)
    })
    .then((result: Array<PromiseSettledResult<fs.Stat>>) => {
      const fulfilledRes: Array<FileInfo> = []

      result.forEach((item, index) => {
        if (item.status === 'fulfilled') {
          fulfilledRes.push({
            name: filenames[index],
            size: item.value.size,
            atime: item.value.atime
          })
        }
      })

      return fulfilledRes
    })
    .catch((err: BusinessError) => {
      console.log('testyy error: ', err)
      throw new Error(err.message)
    })
}