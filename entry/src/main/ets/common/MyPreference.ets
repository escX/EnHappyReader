import { preferences } from '@kit.ArkData'
import Constants from './Constants'

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

export const myPreference = new MyPreference()