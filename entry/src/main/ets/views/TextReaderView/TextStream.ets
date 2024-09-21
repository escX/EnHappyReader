import fs from '@ohos.file.fs'
import { buffer } from '@kit.ArkTS'

class TextStream {
  public arrayBuffer: ArrayBuffer | null = null

  constructor(filePath: string) {
    let fileSize: number = 0

    fs.stat(filePath)
      .then((stat: fs.Stat) => {
        fileSize = stat.size
        return stat.size
      })
      .then((fileSize: number) => {
        this.arrayBuffer = new ArrayBuffer(fileSize)
        return fs.createStream(filePath, 'r')
      })
      .then(async (stream: fs.Stream) => {
        await stream.read(this.arrayBuffer, {
          offset: 0,
          length: fileSize
        })

        return stream.close()
      })
      .catch((err: Error) => {})
  }

  getLineText(start: number, end: number) {
    if (this.arrayBuffer) {
      return buffer.from(this.arrayBuffer, start, end - start).toString()
    } else {
      return ''
    }
  }
}

export default TextStream