import React, { useState, useCallback, useEffect } from 'react'
import { useNuiCallback, useNuiMessage } from '../../hooks/useNui'
import { AdminRole } from '../../types'
import PermissionsGrid from '../roles/PermissionsGrid'

type Modal = 'none' | 'create' | 'edit' | 'assign'

interface RolesMsg { action: string; data: AdminRole[] }

export default function RolesPage() {
  const nuiCallback = useNuiCallback()
  const [roles, setRoles] = useState<AdminRole[]>([])
  const [modal, setModal] = useState<Modal>('none')
  const [editingRole, setEditingRole] = useState<AdminRole | null>(null)

  // Form state
  const [roleName, setRoleName] = useState('')
  const [roleLabel, setRoleLabel] = useState('')
  const [selectedPerms, setSelectedPerms] = useState<string[]>([])
  const [isWildcard, setIsWildcard] = useState(false)
  const [assignIdentifier, setAssignIdentifier] = useState('')
  const [assignRoleId, setAssignRoleId] = useState<number | null>(null)

  useNuiMessage<RolesMsg>('roles', msg => setRoles(msg.data || []))

  useEffect(() => {
    nuiCallback('getRoles', {})
  }, [])

  const openCreate = () => {
    setRoleName(''); setRoleLabel(''); setSelectedPerms([]); setIsWildcard(false)
    setModal('create')
  }

  const openEdit = (role: AdminRole) => {
    setEditingRole(role)
    const perms: string[] = typeof role.permissions === 'string'
      ? JSON.parse(role.permissions)
      : role.permissions

    const wc = perms.includes('*')
    setIsWildcard(wc)
    setSelectedPerms(wc ? [] : perms)
    setRoleLabel(role.label)
    setModal('edit')
  }

  const handleCreate = useCallback(() => {
    if (!roleName || !roleLabel) return
    const perms = isWildcard ? ['*'] : selectedPerms
    nuiCallback('createRole', { name: roleName, label: roleLabel, permissions: perms })
    setModal('none')
    setTimeout(() => nuiCallback('getRoles', {}), 500)
  }, [nuiCallback, roleName, roleLabel, selectedPerms, isWildcard])

  const handleUpdate = useCallback(() => {
    if (!editingRole) return
    const perms = isWildcard ? ['*'] : selectedPerms
    nuiCallback('updateRole', { id: editingRole.id, label: roleLabel, permissions: perms })
    setModal('none')
    setTimeout(() => nuiCallback('getRoles', {}), 500)
  }, [nuiCallback, editingRole, roleLabel, selectedPerms, isWildcard])

  const handleDelete = useCallback((roleId: number) => {
    if (!confirm('Supprimer ce rôle ?')) return
    nuiCallback('deleteRole', { id: roleId })
    setTimeout(() => nuiCallback('getRoles', {}), 500)
  }, [nuiCallback])

  const handleAssign = useCallback(() => {
    if (!assignIdentifier || !assignRoleId) return
    nuiCallback('assignRole', { identifier: assignIdentifier, roleId: assignRoleId })
    setModal('none')
    setAssignIdentifier('')
  }, [nuiCallback, assignIdentifier, assignRoleId])

  return (
    <div>
      <div className="page-header">
        <h1 className="page-title">Rôles Admin</h1>
        <div style={{ display: 'flex', gap: '0.5rem' }}>
          <button className="btn btn-secondary btn-sm" onClick={() => setModal('assign')}>
            Assigner un rôle
          </button>
          <button className="btn btn-primary btn-sm" onClick={openCreate}>
            + Créer un rôle
          </button>
        </div>
      </div>

      {roles.length === 0 && <div className="empty-state">Aucun rôle configuré.</div>}

      {roles.map(role => {
        const perms: string[] = typeof role.permissions === 'string'
          ? JSON.parse(role.permissions)
          : role.permissions
        const wc = perms.includes('*')

        return (
          <div key={role.id} className="card">
            <div className="card-row">
              <span className="card-label">{role.label}</span>
              <span className="card-meta" style={{ marginRight: 'auto' }}>
                [{role.name}]
              </span>
              {wc && (
                <span className="badge badge-legal" style={{ marginRight: '0.5rem' }}>
                  Superadmin
                </span>
              )}
              <span className="card-meta" style={{ marginRight: '0.75rem' }}>
                {wc ? 'Toutes les permissions' : `${perms.length} permission(s)`}
              </span>
              {role.name !== 'superadmin' && (
                <>
                  <button className="btn btn-secondary btn-sm" onClick={() => openEdit(role)}>
                    Éditer
                  </button>
                  <button
                    className="btn btn-danger btn-sm"
                    style={{ marginLeft: '0.35rem' }}
                    onClick={() => handleDelete(role.id)}
                  >
                    Suppr.
                  </button>
                </>
              )}
            </div>
          </div>
        )
      })}

      {/* Modal : Créer un rôle */}
      {modal === 'create' && (
        <div className="modal-overlay" onClick={() => setModal('none')}>
          <div className="modal" onClick={e => e.stopPropagation()}>
            <div className="modal-title">Créer un rôle</div>

            <div className="form-group">
              <label className="form-label">Identifiant (ex: moderateur)</label>
              <input className="form-input" value={roleName}
                onChange={e => setRoleName(e.target.value)} placeholder="mon_role" />
            </div>
            <div className="form-group">
              <label className="form-label">Label affiché</label>
              <input className="form-input" value={roleLabel}
                onChange={e => setRoleLabel(e.target.value)} placeholder="Mon Rôle" />
            </div>

            <div className="form-group">
              <label className="form-label">Permissions</label>
              <PermissionsGrid
                selected={selectedPerms}
                isWildcard={isWildcard}
                onChange={setSelectedPerms}
                onWildcardChange={setIsWildcard}
              />
            </div>

            <div className="modal-footer">
              <button className="btn btn-secondary" onClick={() => setModal('none')}>Annuler</button>
              <button className="btn btn-primary" onClick={handleCreate}>Créer</button>
            </div>
          </div>
        </div>
      )}

      {/* Modal : Éditer un rôle */}
      {modal === 'edit' && editingRole && (
        <div className="modal-overlay" onClick={() => setModal('none')}>
          <div className="modal" onClick={e => e.stopPropagation()}>
            <div className="modal-title">Éditer : {editingRole.name}</div>

            <div className="form-group">
              <label className="form-label">Label affiché</label>
              <input className="form-input" value={roleLabel}
                onChange={e => setRoleLabel(e.target.value)} />
            </div>

            <div className="form-group">
              <label className="form-label">Permissions</label>
              <PermissionsGrid
                selected={selectedPerms}
                isWildcard={isWildcard}
                onChange={setSelectedPerms}
                onWildcardChange={setIsWildcard}
              />
            </div>

            <div className="modal-footer">
              <button className="btn btn-secondary" onClick={() => setModal('none')}>Annuler</button>
              <button className="btn btn-primary" onClick={handleUpdate}>Sauvegarder</button>
            </div>
          </div>
        </div>
      )}

      {/* Modal : Assigner un rôle */}
      {modal === 'assign' && (
        <div className="modal-overlay" onClick={() => setModal('none')}>
          <div className="modal" onClick={e => e.stopPropagation()}>
            <div className="modal-title">Assigner un rôle</div>

            <div className="form-group">
              <label className="form-label">Identifier du joueur (license:...)</label>
              <input className="form-input" value={assignIdentifier}
                onChange={e => setAssignIdentifier(e.target.value)}
                placeholder="license:abc123..." />
            </div>

            <div className="form-group">
              <label className="form-label">Rôle à assigner</label>
              <select className="form-select" value={assignRoleId ?? ''}
                onChange={e => setAssignRoleId(parseInt(e.target.value))}>
                <option value="">Sélectionner...</option>
                {roles.map(r => (
                  <option key={r.id} value={r.id}>{r.label} [{r.name}]</option>
                ))}
              </select>
            </div>

            <div className="modal-footer">
              <button className="btn btn-secondary" onClick={() => setModal('none')}>Annuler</button>
              <button className="btn btn-primary" onClick={handleAssign}>Assigner</button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
