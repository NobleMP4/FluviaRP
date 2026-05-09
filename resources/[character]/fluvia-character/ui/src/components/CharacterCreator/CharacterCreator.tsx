import React, { useState, useCallback } from 'react'
import { CharacterCreateData, AppearanceData, defaultAppearance } from '../../types'
import { useNuiCallback } from '../../hooks/useNui'
import InfoStep from './steps/InfoStep'
import FaceStep from './steps/FaceStep'
import BodyStep from './steps/BodyStep'
import HairStep from './steps/HairStep'
import ConfirmStep from './steps/ConfirmStep'

interface Props {
  slot: number
  nationalities: string[]
}

const STEPS = ['Identité', 'Visage', 'Corps', 'Cheveux', 'Confirmation']

export default function CharacterCreator({ slot, nationalities }: Props) {
  const nuiCallback = useNuiCallback()
  const [step, setStep] = useState(0)

  const [charData, setCharData] = useState<CharacterCreateData>({
    slot,
    firstName: '',
    lastName: '',
    dob: '',
    nationality: '',
    gender: 0,
    appearance: { ...defaultAppearance },
  })

  const handleInfoChange = useCallback((key: keyof CharacterCreateData, value: string | number) => {
    setCharData(prev => ({ ...prev, [key]: value }))
  }, [])

  const handleGenderChange = useCallback((gender: 0 | 1) => {
    setCharData(prev => ({ ...prev, gender }))
    nuiCallback('changeGender', { gender })
  }, [nuiCallback])

  const handleAppearanceChange = useCallback((key: keyof AppearanceData, value: number) => {
    setCharData(prev => {
      const updated = { ...prev.appearance, [key]: value }
      nuiCallback('previewAppearance', updated)
      return { ...prev, appearance: updated }
    })
  }, [nuiCallback])

  const handleCancel = () => {
    nuiCallback('cancelCreator', {})
  }

  const handleCreate = () => {
    if (!charData.firstName || !charData.lastName || !charData.dob) {
      alert('Veuillez remplir tous les champs obligatoires (prénom, nom, date de naissance).')
      return
    }
    nuiCallback('createCharacter', charData)
  }

  const isLastStep = step === STEPS.length - 1

  return (
    <div className="creator-wrapper">
      <div className="creator-panel">
        <div className="creator-header">
          <h2>Créer un personnage</h2>
          <span style={{ marginLeft: 'auto', color: 'var(--color-muted)', fontSize: '0.8rem' }}>
            Slot {slot}
          </span>
        </div>

        {/* Step navigation */}
        <div className="step-nav">
          {STEPS.map((name, i) => (
            <button
              key={name}
              className={`step-pill ${i === step ? 'active' : i < step ? 'done' : 'pending'}`}
              onClick={() => setStep(i)}
            >
              {name}
            </button>
          ))}
        </div>

        <div className="creator-body">
          {step === 0 && (
            <InfoStep
              data={charData}
              nationalities={nationalities}
              onChange={handleInfoChange}
              onGenderChange={handleGenderChange}
            />
          )}
          {step === 1 && (
            <FaceStep appearance={charData.appearance} onChange={handleAppearanceChange} />
          )}
          {step === 2 && (
            <BodyStep appearance={charData.appearance} gender={charData.gender} onChange={handleAppearanceChange} />
          )}
          {step === 3 && (
            <HairStep appearance={charData.appearance} onChange={handleAppearanceChange} />
          )}
          {step === 4 && (
            <ConfirmStep data={charData} />
          )}
        </div>

        <div className="creator-footer">
          <button className="btn btn-danger" onClick={handleCancel}>
            Annuler
          </button>
          {step > 0 && (
            <button className="btn btn-secondary" onClick={() => setStep(s => s - 1)}>
              Précédent
            </button>
          )}
          {!isLastStep ? (
            <button className="btn btn-primary" onClick={() => setStep(s => s + 1)}>
              Suivant
            </button>
          ) : (
            <button className="btn btn-primary" onClick={handleCreate}>
              Créer le personnage
            </button>
          )}
        </div>
      </div>
    </div>
  )
}
