import React, { useState, useCallback } from 'react'
import { useNuiMessage } from './hooks/useNui'
import { CharacterSlot } from './types'
import CharacterSelect from './components/CharacterSelect/CharacterSelect'
import CharacterCreator from './components/CharacterCreator/CharacterCreator'

type Screen = 'hidden' | 'select' | 'creator'

interface SelectPayload {
  action: string
  slots: CharacterSlot[]
  maxSlots: number
}

interface CreatorPayload {
  action: string
  slot: number
  nationalities: string[]
}

export default function App() {
  const [screen, setScreen] = useState<Screen>('hidden')
  const [slots, setSlots] = useState<CharacterSlot[]>([])
  const [creatorSlot, setCreatorSlot] = useState(1)
  const [nationalities, setNationalities] = useState<string[]>([])
  const [maxSlots, setMaxSlots] = useState(3)

  const handleSelectOpen = useCallback((payload: SelectPayload) => {
    setSlots(payload.slots || [])
    setMaxSlots(payload.maxSlots || 3)
    setScreen('select')
  }, [])

  const handleCreatorOpen = useCallback((payload: CreatorPayload) => {
    setCreatorSlot(payload.slot || 1)
    setNationalities(payload.nationalities || [])
    setScreen('creator')
  }, [])

  const handleClose = useCallback(() => {
    setScreen('hidden')
  }, [])

  useNuiMessage<SelectPayload>('openCharacterSelect', handleSelectOpen)
  useNuiMessage<CreatorPayload>('openCreator', handleCreatorOpen)
  useNuiMessage('closeAll', handleClose)

  if (screen === 'hidden') return null

  return (
    <>
      {screen === 'select' && (
        <CharacterSelect slots={slots} maxSlots={maxSlots} />
      )}
      {screen === 'creator' && (
        <CharacterCreator slot={creatorSlot} nationalities={nationalities} />
      )}
    </>
  )
}
