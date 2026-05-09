import React from 'react'
import { AppearanceData } from '../../../types'
import SliderControl from '../../shared/SliderControl'
import ColorPicker from '../../shared/ColorPicker'

interface Props {
  appearance: AppearanceData
  onChange: (key: keyof AppearanceData, value: number) => void
}

export default function HairStep({ appearance, onChange }: Props) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '0.75rem' }}>
      <div className="section-title">Coiffure</div>
      <SliderControl label="Style de cheveux" min={0} max={74} step={1}
        value={appearance.hairStyle} onChange={v => onChange('hairStyle', v)} />

      <div className="section-title">Couleur des cheveux</div>
      <ColorPicker
        value={appearance.hairColor}
        onChange={v => onChange('hairColor', v)}
        label="Couleur principale"
      />
      <ColorPicker
        value={appearance.hairHighlightColor}
        onChange={v => onChange('hairHighlightColor', v)}
        label="Reflets"
      />
    </div>
  )
}
