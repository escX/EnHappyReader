import Constants from '../../common/Constants'

@CustomDialog
export default struct ReaderBottomBar {
  private controller?: CustomDialogController
  @LocalStorageProp('naviBarHeight') naviBarHeight: number = 0
  @State fontSize: number = Constants.DEFAULT_FONT_SIZE
  @State lineHeight: number = Constants.DEFAULT_LINE_HEIGHT_RATIO
  @State bgIndex: number = Constants.DEFAULT_BGCOLOR_INDEX

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
          })
          .onDec(() => {
            this.fontSize -= 1
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
          })
          .onDec(() => {
            this.lineHeight = (this.lineHeight * 10 - 1) / 10
          })
        }
        .flexGrow(1)
      }
      .width('100%')
      .padding({left: 20, right: 20})
      .justifyContent(FlexAlign.SpaceBetween)
      // 第二行
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
                color: this.bgIndex === index ? '#FF0A59F7' : '#44000000',
                radius: 4,
                style: BorderStyle.Solid
              })
              .onClick(() => {
                this.bgIndex = index
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