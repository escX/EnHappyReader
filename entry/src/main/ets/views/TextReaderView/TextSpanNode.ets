import { SpanNode } from "./TextLayoutManage"

@Component
export default struct TextSpanNode {
  @Prop textSpanArray: Array<SpanNode>
  @Prop paddingTop: number
  @Prop paddingBottom: number
  @Prop paddingX: number
  @Prop fontSize: number
  @Prop lineHeight: number
  @Prop fontFamily: string

  build() {
    Text(){
      ForEach(
        this.textSpanArray,
        (obj: SpanNode) => Span(obj.content),
        (obj: SpanNode) => obj.index.toString()
      )
    }
    .width('100%')
    .padding({left: this.paddingX, right: this.paddingX, top: this.paddingTop, bottom: this.paddingBottom})
    .fontSize(this.fontSize)
    .lineHeight(this.lineHeight)
    .fontFamily(this.fontFamily)
    .copyOption(CopyOptions.InApp)
    .editMenuOptions( {
      onCreateMenu: (menuItems: Array<TextMenuItem>) => {
        return [
          {id: TextMenuItemId.COPY, content: '复制'},
          {id: TextMenuItemId.of('translate'), content: '翻译'},
          {id: TextMenuItemId.of('star'), content: '收藏'},
          {id: TextMenuItemId.of('share'), content: '分享'},
        ]
      },
      onMenuItemClick: (menuItem: TextMenuItem, textRange: TextRange) => {
        // todo: 翻译、收藏、分享
        if (menuItem.id.equals(TextMenuItemId.of('translate'))) {
          return true
        }

        if (menuItem.id.equals(TextMenuItemId.of('star'))) {
          return true
        }

        if (menuItem.id.equals(TextMenuItemId.of('share'))) {
          return true
        }

        return false
      }
    })
  }
}