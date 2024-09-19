import { BuilderNode, FrameNode, NodeController } from '@kit.ArkUI'
import Constants from '../common/Constants'

class TextObj {
  public content: string = ''
  public lineIndex: number = -1

  constructor(content: string, lineIndex: number) {
    this.content = content
    this.lineIndex = lineIndex
  }
}

class TextNodeController extends NodeController {
  private textArray: Array<TextObj> = []

  makeNode(uiContext: UIContext): FrameNode | null {
    const textNode = new BuilderNode<[Array<TextObj>]>(uiContext)
    textNode.build(wrapBuilder<[Array<TextObj>]>(TextBuilder), this.textArray)
    return textNode.getFrameNode()
  }

  append(textObj: Array<TextObj>) {
    this.textArray.push(...textObj)
    this.rebuild()
  }

  prepend(textObj: Array<TextObj>) {
    this.textArray.unshift(...textObj)
    this.rebuild()
  }
}

@Builder
function TextBuilder(params: Array<TextObj>) {
  Text(){
    ForEach(
      params,
      (obj: TextObj) => (
      Span(obj.content)
      ),
      (obj: TextObj) => {
        return obj.lineIndex.toString()
      }
    )
  }
  .width('100%')
  .padding({left: Constants.SCREEN_MARGIN_X, right: Constants.SCREEN_MARGIN_X})
  .copyOption(CopyOptions.InApp)
  .fontSize(Constants.DEFAULT_FONT_SIZE)
  .lineHeight(Constants.DEFAULT_LINE_HEIGHT_RATIO * Constants.DEFAULT_FONT_SIZE)
  .fontWeight(Constants.DEFAULT_FONT_WEIGHT)
  .fontFamily(Constants.DEFAULT_FONT_FAMILY)
}

export { TextObj }
export default TextNodeController