import { webview } from '@kit.ArkWeb';

@CustomDialog
export default struct webQuery {
  private controller?: CustomDialogController
  private webController: webview.WebviewController = new webview.WebviewController()
  @Link queryStr: string

  build() {
    Column() {
      Web({ src: 'http://tuweia.cn/c/home', controller: this.webController })
    }
    .width('100%')
  }
}