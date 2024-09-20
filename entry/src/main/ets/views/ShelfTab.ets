import { router } from '@kit.ArkUI'
import ShelfHelper, { BookInfo } from '../domain/ShelfHelper'

@Component
export default struct ShelfTab {
  @State bookList: Array<BookInfo> = []
  @LocalStorageLink('currBookPath') bookPath: string | undefined = undefined
  private context = getContext()
  private shelfHelper: ShelfHelper = new ShelfHelper(this.context)

  aboutToAppear() {
    this.setBookList()
  }

  setBookList() {
    this.shelfHelper.getAppBooks().then((files) => {
      this.bookList = files
    })
  }

  build() {
    Column(){
      Row() {
        Button('导入')
          .buttonStyle(ButtonStyleMode.TEXTUAL)
          .stateEffect(false)
          .onClick(() => {
            this.shelfHelper.copyBookFromUser().then(() => {
              this.setBookList()
            })
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.End)

      List({space: 2}) {
        ForEach(this.bookList, (item: BookInfo) => {
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