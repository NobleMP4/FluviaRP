import { useEffect, useCallback } from 'react'

export interface NuiMessage<T = unknown> {
  action: string
  data?: T
  [key: string]: unknown
}

// Écoute les messages Lua → React via window.addEventListener('message')
export function useNuiMessage<T = unknown>(
  action: string,
  handler: (payload: T) => void
) {
  useEffect(() => {
    const listener = (event: MessageEvent<NuiMessage>) => {
      if (event.data?.action === action) {
        handler((event.data as unknown as T))
      }
    }
    window.addEventListener('message', listener)
    return () => window.removeEventListener('message', listener)
  }, [action, handler])
}

// Envoie un callback NUI vers Lua (React → Lua)
export function useNuiCallback() {
  const resourceName =
    (window as Window & { GetParentResourceName?: () => string })
      .GetParentResourceName?.() ?? 'fluvia-character'

  return useCallback(
    async (event: string, data: unknown = {}): Promise<unknown> => {
      try {
        const res = await fetch(`https://${resourceName}/${event}`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(data),
        })
        return res.json()
      } catch {
        // En dev browser, le fetch échoue normalement
        return { ok: false }
      }
    },
    [resourceName]
  )
}
