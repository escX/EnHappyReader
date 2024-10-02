import Constants from '../../common/Constants'
import { myPreference } from '../../common/MyPreference'

@CustomDialog
export default struct ReaderBottomBar {
  private controller?: CustomDialogController
  @LocalStorageProp('naviBarHeight') naviBarHeight: number = 0
  @State fontSize: number = myPreference.getFontSize()
  @State lineHeight: number = myPreference.getLineHeightRatio()
  @State bgColorIndex: number = myPreference.getBgColorIndex()
  @State fontFamilyIndex: number = myPreference.getFontFamilyIndex()
  @State fontFamilyTitle: string = Constants.FONT_FAMILY_TITLE_ARRAY[this.fontFamilyIndex]

  updateFontSize(fontSize: number) {
    myPreference.setFontSize(fontSize)
  }

  updateLineHeight(lineHeight: number) {
    myPreference.setLineHeightRatio(lineHeight)
  }

  updateBgColorIndex(bgColorIndex: number) {
    myPreference.setBgColorIndex(bgColorIndex)
  }

  updateFontFamilyIndex(fontFamilyIndex: number) {
    myPreference.setFontFamilyIndex(fontFamilyIndex)
  }

  build() {
    Column() {
      // 第一行
      Row() {
        // 字号
        Row() {
          Text('字号')
            .margin({right: 10})
          Counter() {
            Text(this.fontSize.toString())
          }
          .enableInc(this.fontSize < 20)
          .enableDec(this.fontSize > 12)
          .onInc(() => {
            this.fontSize += 1
            this.updateFontSize(this.fontSize)
          })
          .onDec(() => {
            this.fontSize -= 1
            this.updateFontSize(this.fontSize)
          })
        }
        .flexGrow(1)
        // 行高
        Row() {
          Text('行高')
            .margin({right: 10})
          Counter() {
            Text(this.lineHeight.toString())
          }
          .enableInc(this.lineHeight < 1.9)
          .enableDec(this.lineHeight > 1.1)
          .onInc(() => {
            this.lineHeight = (this.lineHeight * 10 + 1) / 10
            this.updateLineHeight(this.lineHeight)
          })
          .onDec(() => {
            this.lineHeight = (this.lineHeight * 10 - 1) / 10
            this.updateLineHeight(this.lineHeight)
          })
        }
        .flexGrow(1)
      }
      .width('100%')
      .padding({left: 20, right: 20})
      .justifyContent(FlexAlign.SpaceBetween)
      // 第二行
      Row() {
        Text('字体')
          .margin({right: 10})
        Select(Constants.FONT_FAMILY_TITLE_ARRAY.map(item => {
          const resItem: SelectOption = {
            value: item
          }
          return resItem
        }))
          .selected(this.fontFamilyIndex)
          .value(this.fontFamilyTitle)
          .onSelect((index: number, text: string) => {
            this.fontFamilyIndex = index
            this.fontFamilyTitle = text
            this.updateFontFamilyIndex(index)
          })
      }
      .width('100%')
      .margin({top: 20})
      .padding({left: 20, right: 20})
      .justifyContent(FlexAlign.Start)
      // 第三行
      Row() {
        Text('背景')
          .margin({right: 10})
        Grid() {
          ForEach(Constants.BG_COLOR_ARRAY, (item: string, index: number) => {
            GridItem()
              .width(54)
              .height(34)
              .backgroundColor(item)
              .border({
                width: 1,
                color: this.bgColorIndex === index ? '#FF0A59F7' : '#44000000',
                radius: 4,
                style: BorderStyle.Solid
              })
              .onClick(() => {
                this.bgColorIndex = index
                this.updateBgColorIndex(this.bgColorIndex)
              })
          })
        }
        .columnsGap(20)
      }
      .width('100%')
      .margin({top: 20})
      .padding({left: 20, right: 20})
      .justifyContent(FlexAlign.Start)
    }
    .width('100%')
    .backgroundColor(Color.White)
    .padding({bottom: this.naviBarHeight, top: 30})
    .transition(TransitionEffect.OPACITY.animation({ duration: 300 }).combine(TransitionEffect.translate({ y: 300 })))
  }
}