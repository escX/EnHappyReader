import { BuilderNode, FrameNode, NodeController } from '@kit.ArkUI'
import Constants from '../../common/Constants'

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
  margin: VerticalMargin
}

class TextNodeController extends NodeController {
  private textArray: Array<SpanNode> = []
  private topMargin: number = 0
  private bottomMargin: number = 0

  makeNode(uiContext: UIContext): FrameNode | null {
    const textNode = new BuilderNode<[BuildParams]>(uiContext)
    textNode.build(wrapBuilder(TextBuilder), {
      nodes: this.textArray,
      margin: {
        top: this.topMargin,
        bottom: this.bottomMargin
      }
    })
    return textNode.getFrameNode()
  }

  setMargin(top: number, bottom: number) {
    this.topMargin = top
    this.bottomMargin = bottom
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

// todo: 双击会选中文本的问题，在真机上验证是否存在这个问题
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
  .padding({left: Constants.SCREEN_MARGIN_X, right: Constants.SCREEN_MARGIN_X})
  .margin(params.margin)
  .fontSize(Constants.DEFAULT_FONT_SIZE)
  .lineHeight(Constants.DEFAULT_LINE_HEIGHT_RATIO * Constants.DEFAULT_FONT_SIZE)
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