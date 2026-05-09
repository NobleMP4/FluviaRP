import { useEffect, useCallback } from 'react'

export function useNuiMessage<T = unknown>(action: string, handler: (payload: T) => void) {
  useEffect(() => {
    const listener = (event: MessageEvent) => {
      if (event.data?.action === action) {
        handler(event.data as T)
      }
    }
    window.addEventListener('message', listener)
    return () => window.removeEventListener('message', listener)
  }, [action, handler])
}

export function useNuiCallback() {
  const resourceName =
    (window as Window & { GetParentResourceName?: () => string })
      .GetParentResourceName?.() ?? 'fluvia-tablet'

  return useCallback(async (event: string, data: unknown = {}): Promise<unknown> => {
    try {
      const res = await fetch(`https://${resourceName}/${event}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data),
      })
      return res.json()
    } catch {
      return { ok: false }
    }
  }, [resourceName])
}
