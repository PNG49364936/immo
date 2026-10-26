class DvfImport < ApplicationRecord
  STATUSES = %w[pending running done failed].freeze

  validates :status, inclusion: { in: STATUSES }

  scope :finished, -> { where(status: "done") }

  def self.latest = order(created_at: :desc).first
  def self.latest_done = finished.order(finished_at: :desc).first

  def in_progress? = status.in?(%w[pending running])

  # Diffuse le nouveau statut à tous les navigateurs ouverts (Turbo Streams).
  after_update_commit do
    broadcast_replace_to "dvf_imports", target: "dvf_import_status",
                         partial: "dvf_imports/status", locals: { import: self }
  end
end
