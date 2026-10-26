class ImportDvfJob < ApplicationJob
  queue_as :default

  def perform(import)
    import.update!(status: "running", started_at: Time.current)
    result = Dvf::Importer.new.call
    import.update!(status: "done", finished_at: Time.current, sales_count: result.count,
                   data_from: result.data_from, data_until: result.data_until)
  rescue StandardError => e
    import.update!(status: "failed", finished_at: Time.current, error_message: e.message)
    raise
  end
end
