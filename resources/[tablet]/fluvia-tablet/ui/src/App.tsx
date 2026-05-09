import React, { useState, useCallback } from 'react'
import { useNuiMessage } from './hooks/useNui'
import TabletFrame from './components/Tablet/TabletFrame'
import DashboardPage from './components/pages/DashboardPage'
import RolesPage from './components/pages/RolesPage'
import FactionsPage from './components/pages/FactionsPage'

type Page = 'dashboard' | 'roles' | 'factions'

export default function App() {
  const [visible, setVisible] = useState(false)
  const [page, setPage] = useState<Page>('dashboard')

  useNuiMessage('open',  useCallback(() => setVisible(true), []))
  useNuiMessage('close', useCallback(() => setVisible(false), []))

  if (!visible) return null

  return (
    <TabletFrame page={page} onNavigate={p => setPage(p as Page)}>
      {page === 'dashboard' && <DashboardPage />}
      {page === 'roles'     && <RolesPage />}
      {page === 'factions'  && <FactionsPage />}
    </TabletFrame>
  )
}
