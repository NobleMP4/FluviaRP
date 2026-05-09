import React, { useState, useCallback, useEffect } from 'react'
import { useNuiCallback, useNuiMessage } from '../../hooks/useNui'
import { Faction, FactionGrade, FactionOutfit, ServicePoint } from '../../types'

type Modal = 'none' | 'create' | 'edit' | 'grades' | 'outfits' | 'servicepoints'

interface FactionsMsg    { action: string; data: Faction[]       }
interface GradesMsg      { action: string; data: FactionGrade[]  }
interface OutfitsMsg     { action: string; data: FactionOutfit[] }
interface SPointsMsg     { action: string; data: ServicePoint[]  }

const FACTION_TYPES = [
  { value: 'legal',    label: 'Légale'    },
  { value: 'illegal',  label: 'Illégale'  },
  { value: 'civilian', label: 'Civile'    },
]

export default function FactionsPage() {
  const nuiCallback = useNuiCallback()
  const [factions, setFactions] = useState<Faction[]>([])
  const [selectedFaction, setSelectedFaction] = useState<Faction | null>(null)
  const [grades, setGrades] = useState<FactionGrade[]>([])
  const [outfits, setOutfits] = useState<FactionOutfit[]>([])
  const [spoints, setSpoints] = useState<ServicePoint[]>([])
  const [modal, setModal] = useState<Modal>('none')

  // Form state
  const [fName, setFName] = useState('')
  const [fLabel, setFLabel] = useState('')
  const [fType, setFType] = useState('legal')
  const [fBlipSprite, setFBlipSprite] = useState(1)
  const [fBlipColor, setFBlipColor] = useState(0)

  // Grade form
  const [gradeLabel, setGradeLabel] = useState('')
  const [gradeIsBoss, setGradeIsBoss] = useState(false)

  // Outfit form
  const [outfitLabel, setOutfitLabel] = useState('')
  const [outfitGender, setOutfitGender] = useState(0)
  const [outfitGradeId, setOutfitGradeId] = useState<number | null>(null)

  // Service point form
  const [spLabel, setSpLabel] = useState('')

  useNuiMessage<FactionsMsg>('factions',          msg => setFactions(msg.data || []))
  useNuiMessage<GradesMsg>('factionGrades',       msg => setGrades(msg.data || []))
  useNuiMessage<OutfitsMsg>('factionOutfits',     msg => setOutfits(msg.data || []))
  useNuiMessage<SPointsMsg>('factionServicePoints', msg => setSpoints(msg.data || []))

  useEffect(() => { nuiCallback('getFactions', {}) }, [])

  const selectFaction = (f: Faction) => {
    setSelectedFaction(f)
    nuiCallback('getFactionGrades',       { factionId: f.id })
    nuiCallback('getFactionOutfits',      { factionId: f.id })
    nuiCallback('getFactionServicePoints',{ factionId: f.id })
  }

  const openCreate = () => {
    setFName(''); setFLabel(''); setFType('legal'); setFBlipSprite(1); setFBlipColor(0)
    setModal('create')
  }

  const openEdit = (f: Faction) => {
    setSelectedFaction(f); setFLabel(f.label); setFType(f.type)
    setFBlipSprite(f.blip_sprite); setFBlipColor(f.blip_color)
    setModal('edit')
  }

  const handleCreate = useCallback(() => {
    if (!fName || !fLabel) return
    nuiCallback('createFaction', { name: fName, label: fLabel, type: fType, blipSprite: fBlipSprite, blipColor: fBlipColor })
    setModal('none')
    setTimeout(() => nuiCallback('getFactions', {}), 600)
  }, [nuiCallback, fName, fLabel, fType, fBlipSprite, fBlipColor])

  const handleUpdate = useCallback(() => {
    if (!selectedFaction) return
    nuiCallback('updateFaction', { id: selectedFaction.id, label: fLabel, type: fType, blipSprite: fBlipSprite, blipColor: fBlipColor })
    setModal('none')
    setTimeout(() => nuiCallback('getFactions', {}), 600)
  }, [nuiCallback, selectedFaction, fLabel, fType, fBlipSprite, fBlipColor])

  const handleDelete = useCallback((factionId: number) => {
    if (!confirm('Supprimer cette faction et toutes ses données ?')) return
    nuiCallback('deleteFaction', { id: factionId })
    setSelectedFaction(null)
    setTimeout(() => nuiCallback('getFactions', {}), 600)
  }, [nuiCallback])

  const handleAddGrade = useCallback(() => {
    if (!selectedFaction || !gradeLabel) return
    nuiCallback('addGrade', { factionId: selectedFaction.id, label: gradeLabel, isBoss: gradeIsBoss })
    setGradeLabel(''); setGradeIsBoss(false)
    setTimeout(() => nuiCallback('getFactionGrades', { factionId: selectedFaction.id }), 500)
  }, [nuiCallback, selectedFaction, gradeLabel, gradeIsBoss])

  const handleCaptureOutfit = useCallback(() => {
    if (!selectedFaction || !outfitLabel) return
    nuiCallback('captureAndSaveOutfit', {
      factionId: selectedFaction.id,
      gradeId: outfitGradeId,
      label: outfitLabel,
      gender: outfitGender,
    })
    setOutfitLabel('')
    setTimeout(() => nuiCallback('getFactionOutfits', { factionId: selectedFaction.id }), 500)
  }, [nuiCallback, selectedFaction, outfitLabel, outfitGender, outfitGradeId])

  const handlePlaceServicePoint = useCallback(() => {
    if (!selectedFaction || !spLabel) return
    nuiCallback('placeServicePoint', { factionId: selectedFaction.id, label: spLabel })
    setSpLabel('')
    setTimeout(() => nuiCallback('getFactionServicePoints', { factionId: selectedFaction.id }), 500)
  }, [nuiCallback, selectedFaction, spLabel])

  const getBadge = (type: string) => {
    if (type === 'legal')    return 'badge-legal'
    if (type === 'illegal')  return 'badge-illegal'
    return 'badge-civilian'
  }

  return (
    <div style={{ display: 'flex', gap: '1rem', height: '100%' }}>
      {/* Liste des factions */}
      <div style={{ flex: 1 }}>
        <div className="page-header">
          <h1 className="page-title">Factions</h1>
          <button className="btn btn-primary btn-sm" onClick={openCreate}>+ Créer</button>
        </div>

        {factions.length === 0 && <div className="empty-state">Aucune faction.</div>}

        {factions.map(f => (
          <div
            key={f.id}
            className={`card ${selectedFaction?.id === f.id ? 'selected' : ''}`}
            style={{ cursor: 'pointer', borderColor: selectedFaction?.id === f.id ? 'var(--primary)' : undefined }}
            onClick={() => selectFaction(f)}
          >
            <div className="card-row">
              <span className="card-label">{f.label}</span>
              <span className={`badge ${getBadge(f.type)}`}>{f.type}</span>
              <span className="card-meta">{f.member_count} membres</span>
              <button className="btn btn-secondary btn-sm"
                onClick={e => { e.stopPropagation(); openEdit(f) }}>✏️</button>
              <button className="btn btn-danger btn-sm"
                onClick={e => { e.stopPropagation(); handleDelete(f.id) }}>✕</button>
            </div>
          </div>
        ))}
      </div>

      {/* Détail de la faction sélectionnée */}
      {selectedFaction && (
        <div style={{ width: 280, flexShrink: 0, borderLeft: '1px solid var(--border)', paddingLeft: '1rem' }}>
          <div className="section-title">{selectedFaction.label}</div>

          {/* Grades */}
          <div style={{ marginBottom: '1rem' }}>
            <div className="section-title" style={{ fontSize: '0.7rem' }}>Grades</div>
            {grades.map(g => (
              <div key={g.id} className="card" style={{ padding: '0.4rem 0.6rem', marginBottom: '0.25rem' }}>
                <div className="card-row">
                  <span style={{ fontSize: '0.78rem' }}>{g.grade}. {g.label}</span>
                  {g.is_boss === 1 && <span className="badge badge-legal" style={{ fontSize: '0.62rem' }}>Chef</span>}
                </div>
              </div>
            ))}
            <div style={{ display: 'flex', gap: '0.35rem', marginTop: '0.35rem' }}>
              <input className="form-input" placeholder="Nouveau grade..."
                value={gradeLabel} onChange={e => setGradeLabel(e.target.value)}
                style={{ fontSize: '0.75rem', padding: '0.3rem 0.5rem' }} />
              <button className="btn btn-primary btn-sm" onClick={handleAddGrade}>+</button>
            </div>
          </div>

          {/* Tenues */}
          <div style={{ marginBottom: '1rem' }}>
            <div className="section-title" style={{ fontSize: '0.7rem' }}>Tenues</div>
            {outfits.map(o => (
              <div key={o.id} className="card" style={{ padding: '0.4rem 0.6rem', marginBottom: '0.25rem' }}>
                <span style={{ fontSize: '0.78rem' }}>{o.label}</span>
              </div>
            ))}
            <div style={{ display: 'flex', flexDirection: 'column', gap: '0.3rem', marginTop: '0.35rem' }}>
              <input className="form-input" placeholder="Nom de la tenue..."
                value={outfitLabel} onChange={e => setOutfitLabel(e.target.value)}
                style={{ fontSize: '0.75rem', padding: '0.3rem 0.5rem' }} />
              <select className="form-select" value={outfitGender}
                onChange={e => setOutfitGender(parseInt(e.target.value))}
                style={{ fontSize: '0.75rem', padding: '0.3rem 0.5rem' }}>
                <option value={0}>Homme</option>
                <option value={1}>Femme</option>
              </select>
              <button className="btn btn-secondary btn-sm" onClick={handleCaptureOutfit}
                title="Capture la tenue actuelle de votre ped">
                📸 Capturer ma tenue
              </button>
            </div>
          </div>

          {/* Points de service */}
          <div>
            <div className="section-title" style={{ fontSize: '0.7rem' }}>Points de service</div>
            {spoints.map(sp => (
              <div key={sp.id} className="card" style={{ padding: '0.4rem 0.6rem', marginBottom: '0.25rem' }}>
                <div className="card-row">
                  <span style={{ fontSize: '0.78rem' }}>📍 {sp.label}</span>
                  <button className="btn btn-danger btn-sm"
                    onClick={() => {
                      nuiCallback('deleteServicePoint', { id: sp.id })
                      setTimeout(() => nuiCallback('getFactionServicePoints', { factionId: selectedFaction.id }), 500)
                    }}>✕</button>
                </div>
                <div className="card-meta">
                  x:{sp.x.toFixed(1)} y:{sp.y.toFixed(1)} z:{sp.z.toFixed(1)}
                </div>
              </div>
            ))}
            <div style={{ display: 'flex', gap: '0.35rem', marginTop: '0.35rem' }}>
              <input className="form-input" placeholder="Nom du point..."
                value={spLabel} onChange={e => setSpLabel(e.target.value)}
                style={{ fontSize: '0.75rem', padding: '0.3rem 0.5rem' }} />
              <button className="btn btn-primary btn-sm" onClick={handlePlaceServicePoint}
                title="Pose le point à votre position actuelle">
                📌
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Modal : Créer faction */}
      {modal === 'create' && (
        <div className="modal-overlay" onClick={() => setModal('none')}>
          <div className="modal" onClick={e => e.stopPropagation()}>
            <div className="modal-title">Créer une faction</div>
            <div className="form-group">
              <label className="form-label">Identifiant (ex: lspd)</label>
              <input className="form-input" value={fName} onChange={e => setFName(e.target.value)} placeholder="lspd" />
            </div>
            <div className="form-group">
              <label className="form-label">Nom affiché</label>
              <input className="form-input" value={fLabel} onChange={e => setFLabel(e.target.value)} placeholder="LSPD" />
            </div>
            <div className="form-group">
              <label className="form-label">Type</label>
              <select className="form-select" value={fType} onChange={e => setFType(e.target.value)}>
                {FACTION_TYPES.map(t => <option key={t.value} value={t.value}>{t.label}</option>)}
              </select>
            </div>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '0.5rem' }}>
              <div className="form-group">
                <label className="form-label">Sprite blip</label>
                <input className="form-input" type="number" min={1} value={fBlipSprite}
                  onChange={e => setFBlipSprite(parseInt(e.target.value))} />
              </div>
              <div className="form-group">
                <label className="form-label">Couleur blip</label>
                <input className="form-input" type="number" min={0} value={fBlipColor}
                  onChange={e => setFBlipColor(parseInt(e.target.value))} />
              </div>
            </div>
            <div className="modal-footer">
              <button className="btn btn-secondary" onClick={() => setModal('none')}>Annuler</button>
              <button className="btn btn-primary" onClick={handleCreate}>Créer</button>
            </div>
          </div>
        </div>
      )}

      {/* Modal : Éditer faction */}
      {modal === 'edit' && selectedFaction && (
        <div className="modal-overlay" onClick={() => setModal('none')}>
          <div className="modal" onClick={e => e.stopPropagation()}>
            <div className="modal-title">Éditer : {selectedFaction.name}</div>
            <div className="form-group">
              <label className="form-label">Nom affiché</label>
              <input className="form-input" value={fLabel} onChange={e => setFLabel(e.target.value)} />
            </div>
            <div className="form-group">
              <label className="form-label">Type</label>
              <select className="form-select" value={fType} onChange={e => setFType(e.target.value)}>
                {FACTION_TYPES.map(t => <option key={t.value} value={t.value}>{t.label}</option>)}
              </select>
            </div>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '0.5rem' }}>
              <div className="form-group">
                <label className="form-label">Sprite blip</label>
                <input className="form-input" type="number" min={1} value={fBlipSprite}
                  onChange={e => setFBlipSprite(parseInt(e.target.value))} />
              </div>
              <div className="form-group">
                <label className="form-label">Couleur blip</label>
                <input className="form-input" type="number" min={0} value={fBlipColor}
                  onChange={e => setFBlipColor(parseInt(e.target.value))} />
              </div>
            </div>
            <div className="modal-footer">
              <button className="btn btn-secondary" onClick={() => setModal('none')}>Annuler</button>
              <button className="btn btn-primary" onClick={handleUpdate}>Sauvegarder</button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
