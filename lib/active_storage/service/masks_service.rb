class ActiveStorage::Service::MasksService < ActiveStorage::Service
  %i[
    upload
    download
    download_chunk
    compose
    delete
    delete_prefixed
    exist?
    private_url
    public_url
    url_for_direct_upload
    custom_metadata_headers
  ].each do |method|
    define_method method do |*args, **options, &block|
      disk_service.send(method, *args, **options, &block)
    end
  end

  private

  delegate :installation, to: Masks

  def disk_service
    ActiveStorage::Service.configure(
      :disk,
      { disk: { service: "Disk", root: Rails.root.join("storage") } },
    )
  end
end
