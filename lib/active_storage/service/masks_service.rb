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
      delegate_service.send(method, *args, **options, &block)
    end
  end

  private

  def delegate_service
    service = install.setting(:integration, :storage)
    config = install.setting(:integration, service.underscore)

    ActiveStorage::Service.configure(
      service,
      { service => { service:, **config } },
    )
  end

  def install
    Masks.installation.reload
  end
end
