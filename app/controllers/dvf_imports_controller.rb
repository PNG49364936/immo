class DvfImportsController < ApplicationController
  def create
    import = DvfImport.latest
    unless import&.in_progress?
      import = DvfImport.create!
      ImportDvfJob.perform_later(import)
    end

    render turbo_stream: turbo_stream.replace("dvf_import_status", partial: "dvf_imports/status",
                                                                   locals: { import: import })
  end
end
