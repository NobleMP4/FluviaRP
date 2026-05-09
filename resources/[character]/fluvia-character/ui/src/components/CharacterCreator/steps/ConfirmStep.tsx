import React from 'react'
import { CharacterCreateData } from '../../../types'

interface Props {
  data: CharacterCreateData
}

export default function ConfirmStep({ data }: Props) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '0.75rem' }}>
      <div className="section-title">Récapitulatif</div>
      <div className="confirm-summary">
        <div className="confirm-row">
          <span className="confirm-key">Prénom</span>
          <span className="confirm-value">{data.firstName || '—'}</span>
        </div>
        <div className="confirm-row">
          <span className="confirm-key">Nom</span>
          <span className="confirm-value">{data.lastName || '—'}</span>
        </div>
        <div className="confirm-row">
          <span className="confirm-key">Date de naissance</span>
          <span className="confirm-value">{data.dob || '—'}</span>
        </div>
        <div className="confirm-row">
          <span className="confirm-key">Nationalité</span>
          <span className="confirm-value">{data.nationality || '—'}</span>
        </div>
        <div className="confirm-row">
          <span className="confirm-key">Genre</span>
          <span className="confirm-value">{data.gender === 1 ? 'Femme' : 'Homme'}</span>
        </div>
        <div className="confirm-row">
          <span className="confirm-key">Slot</span>
          <span className="confirm-value">{data.slot}</span>
        </div>
      </div>
      <p style={{ color: 'var(--color-muted)', fontSize: '0.82rem', marginTop: '0.5rem' }}>
        Attention : une fois créé, le personnage ne peut pas être supprimé sans contacter un administrateur.
      </p>
    </div>
  )
}
