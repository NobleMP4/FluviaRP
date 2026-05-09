import React from 'react'
import { CharacterCreateData } from '../../../types'

interface Props {
  data: CharacterCreateData
  nationalities: string[]
  onChange: (key: keyof CharacterCreateData, value: string | number) => void
  onGenderChange: (gender: 0 | 1) => void
}

export default function InfoStep({ data, nationalities, onChange, onGenderChange }: Props) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
      <div className="section-title">Identité</div>

      {/* Genre */}
      <div className="form-group">
        <label className="form-label">Genre</label>
        <div className="gender-toggle">
          <button
            className={`gender-btn ${data.gender === 0 ? 'active' : ''}`}
            onClick={() => { onChange('gender', 0); onGenderChange(0) }}
          >
            Homme
          </button>
          <button
            className={`gender-btn ${data.gender === 1 ? 'active' : ''}`}
            onClick={() => { onChange('gender', 1); onGenderChange(1) }}
          >
            Femme
          </button>
        </div>
      </div>

      {/* Prénom */}
      <div className="form-group">
        <label className="form-label">Prénom</label>
        <input
          className="form-input"
          type="text"
          placeholder="Jean"
          maxLength={50}
          value={data.firstName}
          onChange={e => onChange('firstName', e.target.value)}
        />
      </div>

      {/* Nom */}
      <div className="form-group">
        <label className="form-label">Nom de famille</label>
        <input
          className="form-input"
          type="text"
          placeholder="Dupont"
          maxLength={50}
          value={data.lastName}
          onChange={e => onChange('lastName', e.target.value)}
        />
      </div>

      {/* Date de naissance */}
      <div className="form-group">
        <label className="form-label">Date de naissance</label>
        <input
          className="form-input"
          type="date"
          value={data.dob}
          onChange={e => onChange('dob', e.target.value)}
        />
      </div>

      {/* Nationalité */}
      <div className="form-group">
        <label className="form-label">Nationalité</label>
        <select
          className="form-select"
          value={data.nationality}
          onChange={e => onChange('nationality', e.target.value)}
        >
          <option value="">Sélectionner...</option>
          {nationalities.map(n => (
            <option key={n} value={n}>{n}</option>
          ))}
        </select>
      </div>
    </div>
  )
}
