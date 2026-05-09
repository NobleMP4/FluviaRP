import React from 'react'

interface Props {
  label: string
  min: number
  max: number
  step: number
  value: number
  onChange: (v: number) => void
}

export default function SliderControl({ label, min, max, step, value, onChange }: Props) {
  return (
    <div className="slider-control">
      <div className="slider-row">
        <span className="slider-label">{label}</span>
        <input
          className="slider-input"
          type="range"
          min={min}
          max={max}
          step={step}
          value={value}
          onChange={e => onChange(parseFloat(e.target.value))}
        />
        <span className="slider-value">
          {step < 1 ? value.toFixed(2) : value}
        </span>
      </div>
    </div>
  )
}
