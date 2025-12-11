export interface RealtimePayload<T = any> {
  eventType: 'INSERT' | 'UPDATE' | 'DELETE'
  new: T
  old: T
  schema: string
  table: string
  commit_timestamp: string
}

export type RealtimeCallback<T = any> = (payload: RealtimePayload<T>) => void
