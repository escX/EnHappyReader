export enum SupportSuffix {
  TXT,
  PDF,
  EPUB
}

export default class Constants {
  // 支持导入和阅读的文件后缀
  static readonly SUPPORT_SUFFIX = ['.txt', '.pdf', '.epub']
  // 可选背景色
  static readonly BG_COLOR_ARRAY = ['#f5f5f5', '#d6d6d6', '#f5f1d8', '#dff4e3']
  // 背景色对应填充颜色
  static readonly FILL_COLOR_ARRAY = ['#ffffff', '#e3e3e3', '#f0e4c8', '#beeec6']
  // 背景色对应描边颜色
  static readonly STROKE_COLOR_ARRAY = ['#0a59f7', '#808080', '#aa7839', '#349522']
  // 可选字体
  static readonly FONT_FAMILY_ARRAY = ['HarmonyOS Sans', 'AlbertSans', 'Montserrat', 'Dosis', 'Delius', 'Kalam', 'Lumanosimo', 'Bitter', 'Rosarivo', 'Georgia', 'Merriweather']
  // 可选字体标题
  static readonly FONT_FAMILY_TITLE_ARRAY = ['系统默认', 'AlbertSans', 'Montserrat', 'Dosis', 'Delius', 'Kalam', 'Lumanosimo', 'Bitter', 'Georgia', 'Rosarivo', 'Merriweather']
  // 屏幕的左右空白边距
  static readonly SCREEN_MARGIN_X = 16
  // 默认背景色索引
  static readonly DEFAULT_BGCOLOR_INDEX = 0
  // 默认字体索引
  static readonly DEFAULT_FONT_FAMILY_INDEX = 0
  // 默认字号
  static readonly DEFAULT_FONT_SIZE = 20
  // 默认行高
  static readonly DEFAULT_LINE_HEIGHT_RATIO = 1.6
}