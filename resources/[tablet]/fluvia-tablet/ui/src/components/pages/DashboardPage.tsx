import React from 'react'

export default function DashboardPage() {
  return (
    <div>
      <div className="page-header">
        <h1 className="page-title">Dashboard</h1>
      </div>

      <div className="stats-grid">
        <div className="stat-card">
          <div className="stat-value" id="stat-players">—</div>
          <div className="stat-label">Joueurs</div>
        </div>
        <div className="stat-card">
          <div className="stat-value" style={{ color: 'var(--success)' }}>✓</div>
          <div className="stat-label">Serveur en ligne</div>
        </div>
        <div className="stat-card">
          <div className="stat-value" style={{ color: 'var(--warning)' }}>—</div>
          <div className="stat-label">Uptime</div>
        </div>
      </div>

      <div className="card">
        <div className="card-row">
          <span style={{ fontWeight: 700, color: 'var(--primary)' }}>FluviaRP Framework</span>
          <span className="card-meta">v1.0.0</span>
        </div>
        <p style={{ color: 'var(--muted)', fontSize: '0.8rem', marginTop: '0.5rem' }}>
          Tablette de gestion administrative. Utilisez la navigation à gauche pour accéder aux modules.
        </p>
      </div>

      <div className="card" style={{ marginTop: '0.5rem' }}>
        <div className="section-title">Raccourcis</div>
        <ul style={{ paddingLeft: '1rem', color: 'var(--muted)', fontSize: '0.82rem', lineHeight: 2 }}>
          <li><strong>SUPPR</strong> → Menu admin overlay (joueurs, véhicules, actions rapides)</li>
          <li><strong>F8</strong> → Cette tablette</li>
          <li><strong>Q/Z</strong> en noclip → Monter/Descendre</li>
          <li><strong>Shift</strong> en noclip → Vitesse rapide</li>
          <li><strong>Ctrl</strong> en noclip → Vitesse lente</li>
        </ul>
      </div>
    </div>
  )
}
