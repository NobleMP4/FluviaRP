import React from 'react'
import { ALL_PERMISSIONS } from '../../types'

interface Props {
  selected: string[]
  isWildcard: boolean
  onChange: (perms: string[]) => void
  onWildcardChange: (v: boolean) => void
}

export default function PermissionsGrid({ selected, isWildcard, onChange, onWildcardChange }: Props) {
  const toggle = (node: string) => {
    const next = selected.includes(node)
      ? selected.filter(p => p !== node)
      : [...selected, node]
    onChange(next)
  }

  return (
    <div>
      <label className="wildcard-row">
        <input
          type="checkbox"
          checked={isWildcard}
          onChange={e => onWildcardChange(e.target.checked)}
        />
        Superadmin — toutes les permissions (*)
      </label>

      {!isWildcard && (
        <div className="perms-grid" style={{ marginTop: '0.5rem' }}>
          {ALL_PERMISSIONS.map(p => (
            <label key={p.node} className="perm-item">
              <input
                type="checkbox"
                checked={selected.includes(p.node)}
                onChange={() => toggle(p.node)}
              />
              {p.label}
            </label>
          ))}
        </div>
      )}
    </div>
  )
}
