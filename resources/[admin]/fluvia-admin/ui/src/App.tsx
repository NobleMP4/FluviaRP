import React, { useState, useCallback } from 'react'
import { useNuiMessage, useNuiCallback } from './hooks/useNui'
import AdminMenu from './components/AdminMenu/AdminMenu'

export default function App() {
  const [visible, setVisible] = useState(false)
  const nuiCallback = useNuiCallback()

  const handleOpen  = useCallback(() => setVisible(true),  [])
  const handleClose = useCallback(() => {
    setVisible(false)
    nuiCallback('closeMenu', {})
  }, [nuiCallback])

  useNuiMessage('open',  handleOpen)
  useNuiMessage('close', () => setVisible(false))

  if (!visible) return null

  return <AdminMenu onClose={handleClose} />
}
