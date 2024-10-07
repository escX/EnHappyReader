import { distributedKVStore } from '@kit.ArkData'

class MyKVStore {
  private kvManager: distributedKVStore.KVManager | null = null
  public kvStore: distributedKVStore.SingleKVStore | null = null

  init(context: Context): Promise<void> {
    const kvManagerConfig: distributedKVStore.KVManagerConfig = {
      context,
      bundleName: 'com.example.enhappyreader'
    }
    this.kvManager = distributedKVStore.createKVManager(kvManagerConfig)

    const options: distributedKVStore.Options = {
      createIfMissing: true,
      encrypt: false,
      backup: false,
      autoSync: false,
      kvStoreType: distributedKVStore.KVStoreType.SINGLE_VERSION,
      securityLevel: distributedKVStore.SecurityLevel.S1
    }
    return this.kvManager.getKVStore<distributedKVStore.SingleKVStore>('MyKVStore', options).then(store => {
      this.kvStore = store
      return Promise.resolve()
    }).catch(() => {
      Promise.reject()
    })
  }
}

export const myKVStore = new MyKVStore()