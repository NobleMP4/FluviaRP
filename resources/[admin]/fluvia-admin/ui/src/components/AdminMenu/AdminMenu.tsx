import React, { useState, useCallback } from 'react'
import { AdminPlayer, Vehicle } from '../../types'
import { useNuiCallback, useNuiMessage } from '../../hooks/useNui'
import DraggableWindow from '../shared/DraggableWindow'

type Tab = 'players' | 'vehicles' | 'actions'

interface Props {
  onClose: () => void
}

export default function AdminMenu({ onClose }: Props) {
  const nuiCallback = useNuiCallback()
  const [tab, setTab] = useState<Tab>('players')
  const [players, setPlayers] = useState<AdminPlayer[]>([])
  const [vehicles, setVehicles] = useState<Vehicle[]>([])
  const [selected, setSelected] = useState<AdminPlayer | null>(null)
  const [noclipOn, setNoclipOn] = useState(false)
  const [godOn, setGodOn] = useState(false)

  // Modals pour kick/ban
  const [kickReason, setKickReason] = useState('')
  const [banReason, setBanReason] = useState('')
  const [banDuration, setBanDuration] = useState('')
  const [vehicleKey, setVehicleKey] = useState('')

  useNuiMessage<{ action: string; data: AdminPlayer[] }>('playerList', (msg) => {
    setPlayers(msg.data || [])
  })

  useNuiMessage<{ action: string; state: boolean }>('noclipState', (msg) => {
    setNoclipOn(msg.state)
  })

  useNuiMessage<{ action: string; state: boolean }>('godState', (msg) => {
    setGodOn(msg.state)
  })

  const refreshPlayers = useCallback(() => {
    nuiCallback('requestPlayerList', {})
  }, [nuiCallback])

  const loadVehicles = useCallback(async () => {
    const res = await nuiCallback('getVehicleList', {}) as { ok: boolean; vehicles: Vehicle[] }
    if (res?.vehicles) setVehicles(res.vehicles)
    setTab('vehicles')
  }, [nuiCallback])

  const getPingClass = (ping: number) => {
    if (ping < 80) return 'ping-good'
    if (ping < 150) return 'ping-medium'
    return 'ping-bad'
  }

  return (
    <DraggableWindow onClose={onClose}>
      <div className="admin-tabs">
        <button className={`admin-tab ${tab === 'players' ? 'active' : ''}`}
          onClick={() => { setTab('players'); refreshPlayers() }}>
          Joueurs ({players.length})
        </button>
        <button className={`admin-tab ${tab === 'vehicles' ? 'active' : ''}`}
          onClick={loadVehicles}>
          Véhicules
        </button>
        <button className={`admin-tab ${tab === 'actions' ? 'active' : ''}`}
          onClick={() => setTab('actions')}>
          Actions
        </button>
      </div>

      <div className="admin-body">

        {/* ── Tab : Actions rapides ── */}
        {tab === 'actions' && (
          <>
            <div className="section-title">Actions rapides</div>
            <div className="quick-actions">
              <button
                className={`quick-btn ${noclipOn ? 'active' : ''}`}
                onClick={() => nuiCallback('toggleNoclip', {})}
              >
                {noclipOn ? '✓ ' : ''}Noclip
              </button>
              <button
                className={`quick-btn ${godOn ? 'active-god' : ''}`}
                onClick={() => nuiCallback('toggleSelfGod', {})}
              >
                {godOn ? '✓ ' : ''}God Mode
              </button>
              <button
                className="quick-btn"
                onClick={() => nuiCallback('teleportToWaypoint', {})}
              >
                TP Waypoint
              </button>
              <button
                className="quick-btn"
                onClick={refreshPlayers}
              >
                Actualiser
              </button>
            </div>
          </>
        )}

        {/* ── Tab : Véhicules ── */}
        {tab === 'vehicles' && (
          <>
            <div className="section-title">Spawner un véhicule</div>
            <div className="vehicle-list">
              {vehicles.map(v => (
                <div
                  key={v.model}
                  className="vehicle-item"
                  onClick={() => nuiCallback('spawnVehicle', { model: v.model })}
                >
                  <span>{v.label}</span>
                  <span className="vehicle-cat">{v.category}</span>
                </div>
              ))}
              {vehicles.length === 0 && (
                <div style={{ color: 'var(--muted)', textAlign: 'center', padding: '1rem' }}>
                  Chargement...
                </div>
              )}
            </div>
          </>
        )}

        {/* ── Tab : Joueurs ── */}
        {tab === 'players' && (
          <>
            <div className="section-title">Joueurs en ligne</div>
            <div className="player-list">
              {players.map(p => (
                <div
                  key={p.source}
                  className={`player-item ${selected?.source === p.source ? 'selected' : ''}`}
                  onClick={() => setSelected(selected?.source === p.source ? null : p)}
                >
                  <span className="player-name">{p.name}</span>
                  <span className="player-src">ID {p.source}</span>
                  <span className={`ping-badge ${getPingClass(p.ping)}`}>{p.ping}ms</span>
                </div>
              ))}
              {players.length === 0 && (
                <div style={{ color: 'var(--muted)', textAlign: 'center', padding: '1rem' }}>
                  Aucun joueur en ligne
                </div>
              )}
            </div>

            {/* Actions sur le joueur sélectionné */}
            {selected && (
              <div className="player-actions">
                <div className="player-actions-title">
                  {selected.name} (ID {selected.source})
                </div>

                <div className="action-grid">
                  <button className="action-btn"
                    onClick={() => nuiCallback('teleportToPlayer', { source: selected.source })}>
                    TP à lui
                  </button>
                  <button className="action-btn"
                    onClick={() => nuiCallback('teleportPlayerToMe', { source: selected.source })}>
                    TP à moi
                  </button>
                  <button className="action-btn"
                    onClick={() => nuiCallback('setPlayerGod', { source: selected.source, state: true })}>
                    God ON
                  </button>
                  <button className="action-btn"
                    onClick={() => nuiCallback('setPlayerGod', { source: selected.source, state: false })}>
                    God OFF
                  </button>
                </div>

                {/* Kick */}
                <div className="action-input-row">
                  <input
                    className="action-input"
                    placeholder="Raison du kick..."
                    value={kickReason}
                    onChange={e => setKickReason(e.target.value)}
                  />
                  <button className="action-btn danger"
                    onClick={() => {
                      nuiCallback('kickPlayer', { source: selected.source, reason: kickReason || 'Aucune raison' })
                      setKickReason('')
                    }}>
                    Kick
                  </button>
                </div>

                {/* Ban */}
                <div className="action-input-row">
                  <input
                    className="action-input"
                    placeholder="Raison du ban..."
                    value={banReason}
                    onChange={e => setBanReason(e.target.value)}
                  />
                  <input
                    className="action-input"
                    placeholder="Durée (min)"
                    style={{ maxWidth: 80 }}
                    value={banDuration}
                    onChange={e => setBanDuration(e.target.value)}
                    type="number"
                    min="0"
                  />
                  <button className="action-btn danger"
                    onClick={() => {
                      nuiCallback('banPlayer', {
                        source: selected.source,
                        reason: banReason || 'Aucune raison',
                        duration: parseInt(banDuration) || 0,
                      })
                      setBanReason('')
                      setBanDuration('')
                    }}>
                    Ban
                  </button>
                </div>

                {/* Clé de véhicule */}
                <div className="action-input-row">
                  <input
                    className="action-input"
                    placeholder="Plaque du véhicule..."
                    value={vehicleKey}
                    onChange={e => setVehicleKey(e.target.value.toUpperCase())}
                    maxLength={8}
                  />
                  <button className="action-btn"
                    onClick={() => {
                      if (vehicleKey) {
                        nuiCallback('giveVehicleKey', { source: selected.source, plate: vehicleKey })
                        setVehicleKey('')
                      }
                    }}>
                    Clé
                  </button>
                </div>
              </div>
            )}
          </>
        )}
      </div>
    </DraggableWindow>
  )
}
