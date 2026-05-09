import React from 'react'
import { AppearanceData } from '../../../types'
import SliderControl from '../../shared/SliderControl'
import ColorPicker from '../../shared/ColorPicker'

interface Props {
  appearance: AppearanceData
  onChange: (key: keyof AppearanceData, value: number) => void
}

export default function FaceStep({ appearance, onChange }: Props) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '0.75rem' }}>

      <div className="section-title">Hérédité</div>
      <SliderControl label="Visage parent" min={0} max={45} step={1}
        value={appearance.parentFaceIndex} onChange={v => onChange('parentFaceIndex', v)} />
      <SliderControl label="Peau parente" min={0} max={45} step={1}
        value={appearance.parentSkinIndex} onChange={v => onChange('parentSkinIndex', v)} />
      <SliderControl label="Mélange visage" min={0} max={1} step={0.01}
        value={appearance.faceShapeMix} onChange={v => onChange('faceShapeMix', v)} />
      <SliderControl label="Mélange peau" min={0} max={1} step={0.01}
        value={appearance.skinColorMix} onChange={v => onChange('skinColorMix', v)} />

      <div className="section-title">Morphologie du visage</div>
      <SliderControl label="Largeur du nez" min={-1} max={1} step={0.01}
        value={appearance.noseWidth} onChange={v => onChange('noseWidth', v)} />
      <SliderControl label="Hauteur du nez" min={-1} max={1} step={0.01}
        value={appearance.noseHeight} onChange={v => onChange('noseHeight', v)} />
      <SliderControl label="Arête du nez" min={-1} max={1} step={0.01}
        value={appearance.noseBridge} onChange={v => onChange('noseBridge', v)} />
      <SliderControl label="Pointe du nez" min={-1} max={1} step={0.01}
        value={appearance.noseTip} onChange={v => onChange('noseTip', v)} />
      <SliderControl label="Décalage arête" min={-1} max={1} step={0.01}
        value={appearance.noseBridgeShift} onChange={v => onChange('noseBridgeShift', v)} />
      <SliderControl label="Hauteur des sourcils" min={-1} max={1} step={0.01}
        value={appearance.browHeight} onChange={v => onChange('browHeight', v)} />
      <SliderControl label="Taille des oreilles" min={-1} max={1} step={0.01}
        value={appearance.earSize} onChange={v => onChange('earSize', v)} />
      <SliderControl label="Épaisseur des lèvres" min={-1} max={1} step={0.01}
        value={appearance.lipThickness} onChange={v => onChange('lipThickness', v)} />
      <SliderControl label="Largeur de la mâchoire" min={-1} max={1} step={0.01}
        value={appearance.jawWidth} onChange={v => onChange('jawWidth', v)} />
      <SliderControl label="Hauteur de la mâchoire" min={-1} max={1} step={0.01}
        value={appearance.jawHeight} onChange={v => onChange('jawHeight', v)} />
      <SliderControl label="Longueur du menton" min={-1} max={1} step={0.01}
        value={appearance.chinLength} onChange={v => onChange('chinLength', v)} />
      <SliderControl label="Position du menton" min={-1} max={1} step={0.01}
        value={appearance.chinPosition} onChange={v => onChange('chinPosition', v)} />
      <SliderControl label="Largeur du menton" min={-1} max={1} step={0.01}
        value={appearance.chinWidth} onChange={v => onChange('chinWidth', v)} />
      <SliderControl label="Forme du menton" min={-1} max={1} step={0.01}
        value={appearance.chinShape} onChange={v => onChange('chinShape', v)} />
      <SliderControl label="Épaisseur du cou" min={-1} max={1} step={0.01}
        value={appearance.neckThickness} onChange={v => onChange('neckThickness', v)} />
      <SliderControl label="Hauteur des pommettes" min={-1} max={1} step={0.01}
        value={appearance.cheekboneHeight} onChange={v => onChange('cheekboneHeight', v)} />
      <SliderControl label="Largeur des pommettes" min={-1} max={1} step={0.01}
        value={appearance.cheekboneWidth} onChange={v => onChange('cheekboneWidth', v)} />
      <SliderControl label="Largeur des joues" min={-1} max={1} step={0.01}
        value={appearance.cheeksWidth} onChange={v => onChange('cheeksWidth', v)} />
      <SliderControl label="Ouverture des yeux" min={-1} max={1} step={0.01}
        value={appearance.eyeOpening} onChange={v => onChange('eyeOpening', v)} />

      <div className="section-title">Couleur des yeux</div>
      <ColorPicker type="eye" value={appearance.eyeColor} onChange={v => onChange('eyeColor', v)} />
    </div>
  )
}
