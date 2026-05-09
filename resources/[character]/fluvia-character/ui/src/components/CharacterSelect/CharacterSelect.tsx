import React from 'react'
import { CharacterSlot } from '../../types'
import { useNuiCallback } from '../../hooks/useNui'

interface Props {
  slots: CharacterSlot[]
  maxSlots: number
}

export default function CharacterSelect({ slots, maxSlots }: Props) {
  const nuiCallback = useNuiCallback()

  const handleSelect = (charId: number) => {
    nuiCallback('selectCharacter', { charId })
  }

  const handleCreate = (slot: number) => {
    nuiCallback('openCreator', { slot })
  }

  // Construire un tableau de maxSlots entrées
  const cards: Array<CharacterSlot | null> = []
  for (let i = 1; i <= maxSlots; i++) {
    const char = slots.find(s => s.slot === i) || null
    cards.push(char)
  }

  return (
    <div className="character-select-wrapper">
      <h1 className="character-select-title">Choisir un Personnage</h1>
      <div className="character-slots">
        {cards.map((char, idx) => {
          const slotNum = idx + 1
          if (char) {
            return (
              <div key={slotNum} className="character-card">
                <div className="char-avatar">
                  {char.gender === 1 ? '👩' : '👨'}
                </div>
                <div className="char-name">
                  {char.first_name} {char.last_name}
                </div>
                <div className="char-info">
                  Slot {char.slot} &bull; {char.nationality || 'Inconnu'}
                </div>
                <div className="char-info">
                  Né(e) le {char.dob}
                </div>
                <button
                  className="char-slot-btn play"
                  onClick={() => handleSelect(char.id)}
                >
                  Jouer
                </button>
              </div>
            )
          }
          return (
            <div key={slotNum} className="character-card empty">
              <div className="char-avatar">+</div>
              <div className="char-name">Slot {slotNum}</div>
              <div className="char-info">Vide</div>
              <button
                className="char-slot-btn create"
                onClick={() => handleCreate(slotNum)}
              >
                Créer un personnage
              </button>
            </div>
          )
        })}
      </div>
    </div>
  )
}
