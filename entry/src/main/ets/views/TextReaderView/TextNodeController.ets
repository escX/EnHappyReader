import { BuilderNode, FrameNode, NodeController } from '@kit.ArkUI'
import Constants from '../../common/Constants'
import { myPreference } from '../../common/MyPreference'

interface SpanNode {
  content: string
  index: number
}

interface VerticalMargin {
  top: number
  bottom: number
}

interface BuildParams {
  nodes: Array<SpanNode>
  marginY: VerticalMargin
  fontSize: number
  lineHeight: number
  fontFamily: string
  paddingX: number
}

class TextNodeController extends NodeController {
  private textArray: Array<SpanNode> = []
  private topMargin: number = 0
  private bottomMargin: number = 0
  private fontSize: number = myPreference.getFontSize()
  private lineHeight: number = myPreference.getLineHeightRatio() * this.fontSize
  private fontFamily: string = Constants.FONT_FAMILY_ARRAY[myPreference.getFontFamilyIndex()]
  private paddingX: number = myPreference.getPaddingX()

  makeNode(uiContext: UIContext): FrameNode | null {
    const textNode = new BuilderNode<[BuildParams]>(uiContext)
    textNode.build(wrapBuilder(TextBuilder), {
      nodes: this.textArray,
      marginY: {
        top: this.topMargin,
        bottom: this.bottomMargin
      },
      fontSize: this.fontSize,
      lineHeight: this.lineHeight,
      fontFamily: this.fontFamily,
      paddingX: this.paddingX
    })
    return textNode.getFrameNode()
  }

  setMargin(top: number, bottom: number) {
    this.topMargin = top
    this.bottomMargin = bottom
  }

  setPadding(x: number) {
    this.paddingX = x
  }

  setStyle(fontSize: number, lineHeight: number, fontFamily: string) {
    this.fontSize = fontSize
    this.lineHeight = lineHeight
    this.fontFamily = fontFamily
  }

  append(lineArray: Array<SpanNode>) {
    this.textArray.push(...lineArray)
    this.rebuild()
  }

  prepend(lineArray: Array<SpanNode>) {
    this.textArray.unshift(...lineArray)
    this.rebuild()
  }

  reset() {
    this.textArray = []
    this.rebuild()
  }
}

@Builder
function TextBuilder(params: BuildParams) {
  Text(){
    ForEach(
      params.nodes,
      (obj: SpanNode) => Span(obj.content),
      (obj: SpanNode) => obj.index.toString()
    )
  }
  .width('100%')
  .padding({left: params.paddingX, right: params.paddingX})
  .margin(params.marginY)
  .fontSize(params.fontSize)
  .lineHeight(params.lineHeight)
  .fontFamily(params.fontFamily)
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

export { SpanNode }
export default TextNodeController