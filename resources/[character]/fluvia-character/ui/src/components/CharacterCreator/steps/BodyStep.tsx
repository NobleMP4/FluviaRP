import React from 'react'
import { AppearanceData } from '../../../types'
import SliderControl from '../../shared/SliderControl'
import ColorPicker from '../../shared/ColorPicker'

interface Props {
  appearance: AppearanceData
  gender: 0 | 1
  onChange: (key: keyof AppearanceData, value: number) => void
}

export default function BodyStep({ appearance, gender, onChange }: Props) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '0.75rem' }}>

      <div className="section-title">Sourcils</div>
      <SliderControl label="Style" min={0} max={33} step={1}
        value={appearance.eyebrowStyle} onChange={v => onChange('eyebrowStyle', v)} />
      <SliderControl label="Opacité" min={0} max={1} step={0.01}
        value={appearance.eyebrowOpacity} onChange={v => onChange('eyebrowOpacity', v)} />
      <ColorPicker value={appearance.eyebrowColor} onChange={v => onChange('eyebrowColor', v)}
        label="Couleur" />

      {gender === 0 && (
        <>
          <div className="section-title">Barbe</div>
          <SliderControl label="Style" min={0} max={28} step={1}
            value={appearance.beardStyle} onChange={v => onChange('beardStyle', v)} />
          <SliderControl label="Opacité" min={0} max={1} step={0.01}
            value={appearance.beardOpacity} onChange={v => onChange('beardOpacity', v)} />
          <ColorPicker value={appearance.beardColor} onChange={v => onChange('beardColor', v)}
            label="Couleur" />

          <div className="section-title">Poils de poitrine</div>
          <SliderControl label="Style" min={0} max={16} step={1}
            value={appearance.chestHairStyle} onChange={v => onChange('chestHairStyle', v)} />
          <SliderControl label="Opacité" min={0} max={1} step={0.01}
            value={appearance.chestHairOpacity} onChange={v => onChange('chestHairOpacity', v)} />
          <ColorPicker value={appearance.chestHairColor} onChange={v => onChange('chestHairColor', v)}
            label="Couleur" />
        </>
      )}

      {gender === 1 && (
        <>
          <div className="section-title">Maquillage</div>
          <SliderControl label="Style" min={0} max={74} step={1}
            value={appearance.makeupStyle} onChange={v => onChange('makeupStyle', v)} />
          <SliderControl label="Opacité" min={0} max={1} step={0.01}
            value={appearance.makeupOpacity} onChange={v => onChange('makeupOpacity', v)} />
          <ColorPicker value={appearance.makeupColor} onChange={v => onChange('makeupColor', v)}
            label="Couleur" />
        </>
      )}

      <div className="section-title">Vieillissement & imperfections</div>
      <SliderControl label="Style vieillissement" min={0} max={14} step={1}
        value={appearance.ageingStyle} onChange={v => onChange('ageingStyle', v)} />
      <SliderControl label="Opacité vieillissement" min={0} max={1} step={0.01}
        value={appearance.ageingOpacity} onChange={v => onChange('ageingOpacity', v)} />
      <SliderControl label="Style imperfections" min={0} max={23} step={1}
        value={appearance.blemishStyle} onChange={v => onChange('blemishStyle', v)} />
      <SliderControl label="Opacité imperfections" min={0} max={1} step={0.01}
        value={appearance.blemishOpacity} onChange={v => onChange('blemishOpacity', v)} />
    </div>
  )
}
