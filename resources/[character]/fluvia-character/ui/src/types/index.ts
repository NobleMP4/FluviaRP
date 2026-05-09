export interface CharacterSlot {
  id: number
  slot: number
  first_name: string
  last_name: string
  dob: string
  nationality: string
  gender: 0 | 1
}

export interface AppearanceData {
  // Head blend
  parentFaceIndex: number
  parentSkinIndex: number
  faceShapeMix: number
  skinColorMix: number
  // Eyes
  eyeColor: number
  // Hair
  hairStyle: number
  hairColor: number
  hairHighlightColor: number
  // Overlays
  beardStyle: number
  beardColor: number
  beardOpacity: number
  eyebrowStyle: number
  eyebrowColor: number
  eyebrowOpacity: number
  ageingStyle: number
  ageingOpacity: number
  makeupStyle: number
  makeupOpacity: number
  makeupColor: number
  chestHairStyle: number
  chestHairColor: number
  chestHairOpacity: number
  blemishStyle: number
  blemishOpacity: number
  // Face features (morphologie)
  noseWidth: number
  noseHeight: number
  noseBridge: number
  noseTip: number
  noseBridgeShift: number
  browHeight: number
  earSize: number
  lipThickness: number
  jawWidth: number
  jawHeight: number
  chinLength: number
  chinPosition: number
  chinWidth: number
  chinShape: number
  neckThickness: number
  cheekboneHeight: number
  cheekboneWidth: number
  cheeksWidth: number
  eyeOpening: number
  lipThicknessLower: number
}

export const defaultAppearance: AppearanceData = {
  parentFaceIndex: 0,
  parentSkinIndex: 0,
  faceShapeMix: 0.5,
  skinColorMix: 0.5,
  eyeColor: 0,
  hairStyle: 0,
  hairColor: 0,
  hairHighlightColor: 0,
  beardStyle: 255,
  beardColor: 0,
  beardOpacity: 0,
  eyebrowStyle: 0,
  eyebrowColor: 0,
  eyebrowOpacity: 1,
  ageingStyle: 255,
  ageingOpacity: 0,
  makeupStyle: 255,
  makeupOpacity: 0,
  makeupColor: 0,
  chestHairStyle: 255,
  chestHairColor: 0,
  chestHairOpacity: 0,
  blemishStyle: 255,
  blemishOpacity: 0,
  noseWidth: 0,
  noseHeight: 0,
  noseBridge: 0,
  noseTip: 0,
  noseBridgeShift: 0,
  browHeight: 0,
  earSize: 0,
  lipThickness: 0,
  jawWidth: 0,
  jawHeight: 0,
  chinLength: 0,
  chinPosition: 0,
  chinWidth: 0,
  chinShape: 0,
  neckThickness: 0,
  cheekboneHeight: 0,
  cheekboneWidth: 0,
  cheeksWidth: 0,
  eyeOpening: 0,
  lipThicknessLower: 0,
}

export interface CharacterCreateData {
  slot: number
  firstName: string
  lastName: string
  dob: string
  nationality: string
  gender: 0 | 1
  appearance: AppearanceData
}
