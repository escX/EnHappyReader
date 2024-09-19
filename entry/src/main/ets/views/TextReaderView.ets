import Constants from '../common/Constants'
import TextLineReader from '../domain/TextLineReader'
import TextNodeController, { TextObj } from '../domain/TextNodeController'

@Component
export default struct TextReaderView {
  @Watch('parseTextLine') @State testLineReader: TextLineReader | null = null
  private textNodeController: TextNodeController = new TextNodeController()
  private startLineIndex: number = 0
  private uiContext: UIContext = this.getUIContext()
  @Require @Prop bookPath: string | undefined
  @Require @Watch('parseTextLine') @Prop screenW: number

  aboutToAppear() {
    this.testLineReader = new TextLineReader(this.bookPath)
  }

  parseTextLine() {
    if (this.screenW > 0 && this.testLineReader) {
      this.testLineReader.parse({
        uiContext: this.uiContext,
        constraintWidth: this.screenW,
        fontSize: Constants.DEFAULT_FONT_SIZE,
        lineHeight: Constants.DEFAULT_LINE_HEIGHT_RATIO * Constants.DEFAULT_FONT_SIZE,
        fontWeight: Constants.DEFAULT_FONT_WEIGHT,
        fontFamily: Constants.DEFAULT_FONT_FAMILY,
      })
    }
  }

  build() {
    Scroll() {
      NodeContainer(this.textNodeController)
        .width('100%')
    }
    .height('100%')
    .width('100%')
    .align(Alignment.TopStart)
  }
}