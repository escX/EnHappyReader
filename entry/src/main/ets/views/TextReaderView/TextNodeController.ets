import { BuilderNode, FrameNode, NodeController } from '@kit.ArkUI'
import Constants from '../../common/Constants'

interface TextLineData {
  content: string
  index: number
}

class TextNodeController extends NodeController {
  private textArray: Array<TextLineData> = []

  makeNode(uiContext: UIContext): FrameNode | null {
    const textNode = new BuilderNode<[Array<TextLineData>]>(uiContext)
    textNode.build(wrapBuilder<[Array<TextLineData>]>(TextBuilder), this.textArray)
    return textNode.getFrameNode()
  }

  append(lineArray: Array<TextLineData>) {
    this.textArray.push(...lineArray)
    this.rebuild()
  }

  prepend(lineArray: Array<TextLineData>) {
    this.textArray.unshift(...lineArray)
    this.rebuild()
  }

  setLines(lineArray: Array<TextLineData>) {
    this.textArray = lineArray
    this.rebuild()
  }
}

@Builder
function TextBuilder(params: Array<TextLineData>) {
  Text(){
    ForEach(
      params,
      (obj: TextLineData) => Span(obj.content),
      (obj: TextLineData) => obj.index.toString()
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

export default TextNodeController