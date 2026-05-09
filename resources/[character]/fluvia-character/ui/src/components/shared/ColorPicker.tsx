import React from 'react'

// Palette de couleurs cheveux GTA V (approximatif)
const HAIR_COLORS = [
  '#1a1a1a','#2c1e0f','#3b2408','#4a2f0c','#5c3a10','#6b4a18',
  '#8b5e25','#a87040','#c4935a','#d4a96e','#e8c98a','#f0d9a0',
  '#f5e6b5','#fffacd','#ffd700','#daa520','#cd853f','#8b4513',
  '#a0522d','#6b3a2a','#4a2520','#2d1515','#1a0a0a','#0d0505',
  '#ff6b6b','#ff4500','#dc143c','#8b0000','#4b0082','#6a0dad',
  '#1e90ff','#00bfff','#00ced1','#008080','#228b22','#32cd32',
  '#ffffff','#f5f5f5','#d3d3d3','#a9a9a9','#808080','#696969',
  '#4a4a4a','#333333','#1c1c1c','#000000','#ff69b4','#ff1493',
  '#c71585','#db7093','#ffa07a','#fa8072','#e9967a','#f08080',
  '#cd5c5c','#bc8f8f','#f4a460','#deb887','#d2b48c','#c0a882',
  '#b8860b','#8b7536','#6b5b45','#5c4a3a','#483c32','#3b2f27',
  '#2f2318','#1e160e',
]

const EYE_COLORS = [
  '#1a6e3a','#2e5fa3','#8b4513','#4a3728','#6b6b6b','#c8c8c8',
  '#5f9ea0','#6495ed','#7b68ee','#9370db','#3cb371','#20b2aa',
  '#ffd700','#ff6347','#dc143c','#ff1493','#00ced1','#7cfc00',
  '#ff8c00','#ff4500','#da70d6','#dda0dd','#b0e0e6','#87ceeb',
  '#4169e1','#0000cd','#00008b','#191970','#006400','#008000',
  '#228b22','#2e8b57','#3cb371','#66cdaa','#98fb98','#00ff7f',
  '#7fff00','#adff2f','#ffff00','#ffd700','#ffa500','#ff8c00',
  '#ff6347','#ff4500','#dc143c','#b22222','#8b0000','#800000',
  '#c71585','#db7093',
]

interface Props {
  type?: 'hair' | 'eye'
  count?: number
  value: number
  onChange: (v: number) => void
  label?: string
}

export default function ColorPicker({ type = 'hair', count, value, onChange, label }: Props) {
  const palette = type === 'eye' ? EYE_COLORS : HAIR_COLORS
  const colors = count ? palette.slice(0, count) : palette

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '0.4rem' }}>
      {label && <span className="form-label">{label}</span>}
      <div className="color-picker">
        {colors.map((color, i) => (
          <div
            key={i}
            className={`color-swatch ${value === i ? 'selected' : ''}`}
            style={{ background: color }}
            onClick={() => onChange(i)}
            title={`Couleur ${i}`}
          />
        ))}
      </div>
    </div>
  )
}
