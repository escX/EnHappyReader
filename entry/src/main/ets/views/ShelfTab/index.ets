import { router } from '@kit.ArkUI'
import { SupportSuffix } from '../../common/Constants'
import { myPreference } from '../../common/MyPreference'
import TextParser from '../TextReaderView/TextParser'
import getBooks, { BookInfo } from './getBooks'
import importBook from './importBook'

@Component
export default struct ShelfTab {
  @State bookList: Array<BookInfo> = []
  @LocalStorageLink('currBookName') currBookName: string | undefined = undefined
  private textParser: TextParser = new TextParser()
  private context = getContext()

  aboutToAppear() {
    this.loadBookList()
  }

  loadBookList() {
    getBooks(this.context).then((files) => {
      this.bookList = files
      Promise.all(
        files
          .filter(item => {
            const bookSlice = myPreference.getBookSlice(item.name)
            return bookSlice === 0
          })
          .map(item => {
            if (item.type === SupportSuffix.TXT) {
              return this.setTextParseStore(item.name) as Promise<void>
            }

            return Promise.resolve()
          })
      )
    })
  }

  setTextParseStore(name: string): Promise<void> {
    // todo: setTimeout 验证大文件解析事件长的情况，进入read页面读取数据应该有loading
    return this.textParser.parse(`${this.context.filesDir}/${name}`).then((parseValue) => {
      return this.textParser.storeParseData(name, parseValue)
    })
  }

  build() {
    Column(){
      Row() {
        Button('导入')
          .buttonStyle(ButtonStyleMode.TEXTUAL)
          .stateEffect(false)
          .onClick(() => {
            // todo: 筛选utf-8格式的文件
            importBook(this.context).then(() => {
              this.loadBookList()
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
            this.currBookName = item.name
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