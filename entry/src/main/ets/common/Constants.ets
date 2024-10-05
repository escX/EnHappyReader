// 背景色枚举
export enum BGColorType {
  WHITE,
  YELLOW,
  GREEN,
  BLUE
}

// 支持文件后缀枚举
export enum SupportSuffix {
  TXT,
  PDF,
  EPUB
}

export default class Constants {
  // 支持导入和阅读的文件后缀
  static readonly SUPPORT_SUFFIX = ['.txt', '.pdf', '.epub']
  // 可选背景色
  static readonly BG_COLOR_ARRAY = ['#FFFFFF','#FDEAD3', '#DFF7E5', '#DFF1FA']
  // 可选背景色标题
  static readonly BG_COLOR_TITLE_ARRAY = ['精白','赭黄', '竹青', '碧蓝']
  // 可选字体
  static readonly FONT_FAMILY_ARRAY = ['HarmonyOS Sans', 'AlbertSans', 'Montserrat', 'Dosis', 'Delius', 'Kalam', 'Lumanosimo', 'Bitter', 'Rosarivo', 'Georgia', 'Merriweather']
  // 可选字体标题
  static readonly FONT_FAMILY_TITLE_ARRAY = ['系统默认', 'AlbertSans', 'Montserrat', 'Dosis', 'Delius', 'Kalam', 'Lumanosimo', 'Bitter', 'Georgia', 'Rosarivo', 'Merriweather']
  // 屏幕的左右空白边距
  static readonly SCREEN_MARGIN_X = 16
  // 默认背景色索引
  static readonly DEFAULT_BGCOLOR_INDEX = BGColorType.YELLOW
  // 默认字体索引
  static readonly DEFAULT_FONT_FAMILY_INDEX = 0
  // 默认字号
  static readonly DEFAULT_FONT_SIZE = 20
  // 默认行高
  static readonly DEFAULT_LINE_HEIGHT_RATIO = 1.6
}