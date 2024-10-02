import { preferences } from '@kit.ArkData'
import Constants from './Constants'

class BookMark {
  public index: number
  public offset: number

  constructor(index: number, offset: number) {
    this.index = index
    this.offset = offset
  }
}

class MyPreference {
  private preference: preferences.Preferences | null = null

  init(context: Context): Promise<void> {
    return preferences.getPreferences(context, 'MyPreference').then((preference) => {
      this.preference = preference
      return Promise.resolve()
    })
  }

  setFontSize(fontSize: number): Promise<void> {
    this.preference?.putSync('fontSize', fontSize)
    return this.flush()
  }

  getFontSize(): number {
    if (!!this.preference) {
      return this.preference.getSync('fontSize', Constants.DEFAULT_FONT_SIZE) as number
    }
    return Constants.DEFAULT_FONT_SIZE
  }

  setLineHeightRatio(ratio: number): Promise<void> {
    this.preference?.putSync('lineHeightRatio', ratio)
    return this.flush()
  }

  getLineHeightRatio(): number {
    if (!!this.preference) {
      return this.preference.getSync('lineHeightRatio', Constants.DEFAULT_LINE_HEIGHT_RATIO) as number
    }
    return Constants.DEFAULT_LINE_HEIGHT_RATIO
  }

  setBgColorIndex(index: number): Promise<void> {
    this.preference?.putSync('bgColorIndex', index)
    return this.flush()
  }

  getBgColorIndex(): number {
    if (!!this.preference) {
      return this.preference.getSync('bgColorIndex', Constants.DEFAULT_BGCOLOR_INDEX) as number
    }
    return Constants.DEFAULT_BGCOLOR_INDEX
  }

  setFontFamilyIndex(index: number): Promise<void> {
    this.preference?.putSync('fontFamilyIndex', index)
    return this.flush()
  }

  getFontFamilyIndex(): number {
    if (!!this.preference) {
      return this.preference.getSync('fontFamilyIndex', Constants.DEFAULT_FONT_FAMILY_INDEX) as number
    }
    return Constants.DEFAULT_FONT_FAMILY_INDEX
  }

  setBookMark(path: string, mark: BookMark): Promise<void> {
    const bookMark: object = this.preference?.getSync('bookMark', null) as object
    if (bookMark) {
      bookMark[path] = mark
      this.preference?.putSync('bookMark', bookMark)
    } else {
      const newBookMark: Record<string, BookMark> = {}
      newBookMark[path] = mark
      this.preference?.putSync('bookMark', newBookMark)
    }
    return this.flush()
  }

  getBookMark(path?: string): BookMark {
    const defaultMark = new BookMark(0, 0)
    if (!!this.preference && !!path) {
      const bookMark: object = this.preference.getSync('bookMark', null) as object
      if (bookMark === null) {
        return defaultMark
      }
      return bookMark[path] ?? defaultMark
    }
    return defaultMark
  }

  delete(key: string): Promise<void> {
    this.preference?.deleteSync(key)
    return this.flush()
  }

  flush(): Promise<void> {
    return this.preference ? this.preference.flush() : Promise.reject()
  }

  onDataChange(keys: Array<string>, callback: Callback<Record<string, preferences.ValueType>>) {
    this.preference?.on('dataChange', keys, callback)
  }
}

export { BookMark }
export const myPreference = new MyPreference()