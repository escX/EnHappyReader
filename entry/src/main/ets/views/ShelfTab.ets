import { common } from '@kit.AbilityKit'
import { router } from '@kit.ArkUI'
import { copyFromUser, FileInfo, getFilesInfo } from '../common/FsUtils'

@Component
export default struct ShelfTab {
  @State fileList: Array<FileInfo> = []
  @LocalStorageLink('currBookPath') bookPath: string | undefined = undefined
  private context = getContext(this) as common.UIAbilityContext

  aboutToAppear() {
    getFilesInfo(this.context)
      .then((files) => {
        this.fileList = files
      })
  }

  build() {
    Column(){
      Row() {
        Button('导入')
          .buttonStyle(ButtonStyleMode.TEXTUAL)
          .stateEffect(false)
          .onClick(() => {
            copyFromUser(this.context)
              .then(() => {
                return getFilesInfo(this.context)
              })
              .then((files) => {
                this.fileList = files
              })
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.End)

      List({space: 2}) {
        ForEach(this.fileList, (item: FileInfo) => {
          ListItem() {
            Text(item.name)
          }
          .width('100%')
          .padding(12)
          .borderRadius(6)
          .stateStyles({
            normal: { .backgroundColor('#ffffff') },
            clicked: { .backgroundColor('#eeeeee').opacity(0.8) },
            pressed: { .backgroundColor('#eeeeee').opacity(0.8) },
            focused: { .backgroundColor('#eeeeee').opacity(0.8) },
          })
          .onClick(() => {
            this.bookPath = `${this.context.filesDir}/${item.name}`
            router.pushUrl({ url: 'pages/Reader' })
          })
        })
      }
      .padding(8)
      .layoutWeight(1)
      .chainAnimation(true)
      .edgeEffect(EdgeEffect.Spring, {alwaysEnabled: true})
    }
    .width('100%')
    .height('100%')
  }
}