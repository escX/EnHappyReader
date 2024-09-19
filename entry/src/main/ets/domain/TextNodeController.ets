import { BuilderNode, FrameNode, NodeController } from '@kit.ArkUI'
import Constants from '../common/Constants'

interface TextParams {
  text: Array<string>
}

@Builder
function TextBuilder(params: TextParams) {
  Text(){
    ForEach(
      params.text,
      (lineText: string) => (
        Span(lineText)
      ),
      (item: string) => { return item }
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

class TextNodeController extends NodeController {
  private textArray: Array<string> = []

  makeNode(uiContext: UIContext): FrameNode | null {
    const textNode = new BuilderNode<[TextParams]>(uiContext)
    textNode.build(wrapBuilder<[TextParams]>(TextBuilder), {text: this.textArray})
    return textNode.getFrameNode()
  }

  append(text: string[]) {
    this.textArray.push(...text)
    this.rebuild()
  }

  prepend(text: string[]) {
    this.textArray.unshift(...text)
    this.rebuild()
  }
}

export default TextNodeController