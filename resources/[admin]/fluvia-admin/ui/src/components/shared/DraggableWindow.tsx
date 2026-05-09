import React, { useState, useRef, useCallback, ReactNode } from 'react'

interface Props {
  children: ReactNode
  onClose: () => void
}

export default function DraggableWindow({ children, onClose }: Props) {
  const [pos, setPos] = useState({ x: 20, y: 60 })
  const dragging = useRef(false)
  const offset   = useRef({ x: 0, y: 0 })

  const onMouseDown = useCallback((e: React.MouseEvent) => {
    dragging.current = true
    offset.current = { x: e.clientX - pos.x, y: e.clientY - pos.y }
  }, [pos])

  const onMouseMove = useCallback((e: React.MouseEvent) => {
    if (!dragging.current) return
    setPos({ x: e.clientX - offset.current.x, y: e.clientY - offset.current.y })
  }, [])

  const onMouseUp = useCallback(() => {
    dragging.current = false
  }, [])

  return (
    <div
      className="admin-overlay"
      onMouseMove={onMouseMove}
      onMouseUp={onMouseUp}
    >
      <div
        className="admin-window"
        style={{ top: pos.y, left: pos.x, position: 'absolute' }}
      >
        <div className="admin-header" onMouseDown={onMouseDown}>
          <span className="admin-title">Menu Admin</span>
          <button className="admin-close" onClick={onClose}>✕</button>
        </div>
        {children}
      </div>
    </div>
  )
}
