import { BuilderNode, FrameNode, NodeController } from '@kit.ArkUI'
import Constants from '../../common/Constants'

interface SpanNode {
  content: string
  index: number
}

class TextNodeController extends NodeController {
  private textArray: Array<SpanNode> = []

  makeNode(uiContext: UIContext): FrameNode | null {
    const textNode = new BuilderNode<[Array<SpanNode>]>(uiContext)
    textNode.build(wrapBuilder<[Array<SpanNode>]>(TextBuilder), this.textArray)
    return textNode.getFrameNode()
  }

  append(lineArray: Array<SpanNode>) {
    this.textArray.push(...lineArray)
    this.rebuild()
  }

  prepend(lineArray: Array<SpanNode>) {
    this.textArray.unshift(...lineArray)
    this.rebuild()
  }
}

@Builder
function TextBuilder(params: Array<SpanNode>) {
  Text(){
    ForEach(
      params,
      (obj: SpanNode) => Span(obj.content),
      (obj: SpanNode) => obj.index.toString()
    )
  }
  .width('100%')
  .padding({left: Constants.SCREEN_MARGIN_X, right: Constants.SCREEN_MARGIN_X})
  .fontSize(Constants.DEFAULT_FONT_SIZE)
  .lineHeight(Constants.DEFAULT_LINE_HEIGHT_RATIO * Constants.DEFAULT_FONT_SIZE)
  .fontWeight(Constants.DEFAULT_FONT_WEIGHT)
  .fontFamily(Constants.DEFAULT_FONT_FAMILY)
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