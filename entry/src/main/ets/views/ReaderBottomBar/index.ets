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
    Column({space: 20}) {
      // 第一行
      GridRow() {
        GridCol({span: 2}) {
          Text('字体').width('100%')
        }
        GridCol({span: 10}) {
          Select(Constants.FONT_FAMILY_TITLE_ARRAY.map(item => {
            const resItem: SelectOption = {
              value: item
            }
            return resItem
          }))
            .alignSelf(ItemAlign.Start)
            .selected(this.fontFamilyIndex)
            .value(this.fontFamilyTitle)
            .onSelect((index: number, text: string) => {
              this.fontFamilyIndex = index
              this.fontFamilyTitle = text
              this.updateFontFamilyIndex(index)
            })
        }
      }
      .alignItems(ItemAlign.Center)

      // 第二行
      GridRow() {
        GridCol({span: 2}) {
          Text('字号').width('100%')
        }
        GridCol({span: 10}) {
          Slider({ style: SliderStyle.InSet, value: this.fontSize, step: 2, min: 16, max: 26 })
            .alignSelf(ItemAlign.Start)
            .showSteps(true)
            .stepSize(6)
            .onChange((value: number, mode: SliderChangeMode) => {
              if (mode === 2) {
                this.fontSize = value
                this.updateFontSize(this.fontSize)
              }
            })
        }
      }
      .alignItems(ItemAlign.Center)

      // 第三行
      GridRow() {
        GridCol({span: 2}) {
          Text('行高').width('100%')
        }
        GridCol({span: 10}) {
          Slider({ style: SliderStyle.InSet, value: this.lineHeight * 10, step: 2, min: 12, max: 22 })
            .alignSelf(ItemAlign.Start)
            .showSteps(true)
            .stepSize(6)
            .onChange((value: number, mode: SliderChangeMode) => {
              if (mode === 2) {
                this.lineHeight = value / 10
                this.updateLineHeight(this.lineHeight)
              }
            })
        }
      }
      .alignItems(ItemAlign.Center)

      // 第四行
      GridRow() {
        GridCol({span: 2}) {
          Text('背景').width('100%')
        }
        GridCol({span: 10}) {
          Grid() {
            ForEach(Constants.BG_COLOR_ARRAY, (item: string, index: number) => {
              GridItem()
                .height(36)
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
          .alignSelf(ItemAlign.Start)
          .height(36)
          .columnsGap(20)
          .columnsTemplate(Array(Constants.BG_COLOR_ARRAY.length).fill('1fr').join(' '))
        }
      }
      .alignItems(ItemAlign.Center)
    }
    .width('100%')
    .backgroundColor(Color.White)
    .padding({bottom: this.naviBarHeight, top: 30, left: 20, right: 20})
    .transition(TransitionEffect.OPACITY.animation({ duration: 300 }).combine(TransitionEffect.translate({ y: 300 })))
  }
}