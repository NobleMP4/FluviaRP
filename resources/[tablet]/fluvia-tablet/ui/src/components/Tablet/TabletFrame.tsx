import React, { ReactNode } from 'react'
import { useNuiCallback } from '../../hooks/useNui'

type Page = 'dashboard' | 'roles' | 'factions'

interface Props {
  page: Page
  onNavigate: (p: Page) => void
  children: ReactNode
}

const NAV_ITEMS: { id: Page; icon: string; label: string }[] = [
  { id: 'dashboard', icon: '📊', label: 'Dashboard'   },
  { id: 'roles',     icon: '🔑', label: 'Rôles Admin' },
  { id: 'factions',  icon: '🏛️', label: 'Factions'    },
]

export default function TabletFrame({ page, onNavigate, children }: Props) {
  const nuiCallback = useNuiCallback()

  return (
    <div className="tablet-backdrop">
      <div className="tablet-device">
        <div className="tablet-notch">
          <div className="tablet-notch-dot" />
        </div>

        <div className="tablet-screen">
          {/* Sidebar */}
          <div className="tablet-sidebar">
            <div className="tablet-logo">FluviaRP</div>

            <nav className="tablet-nav-items">
              {NAV_ITEMS.map(item => (
                <div
                  key={item.id}
                  className={`tablet-nav-item ${page === item.id ? 'active' : ''}`}
                  onClick={() => onNavigate(item.id)}
                >
                  <span className="tablet-nav-icon">{item.icon}</span>
                  {item.label}
                </div>
              ))}
            </nav>

            <button
              className="tablet-close-btn"
              onClick={() => nuiCallback('closeTablet', {})}
            >
              ✕ Fermer
            </button>
          </div>

          {/* Content */}
          <div className="tablet-content">
            {children}
          </div>
        </div>
      </div>
    </div>
  )
}
