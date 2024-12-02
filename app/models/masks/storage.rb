module Masks
  class Storage < ActiveStorage::Service
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
      define_method method do |*args, **options|
        disk_service.send(method, *args, **options)
      end
    end

    private

    def disk_service
      ActiveStorage::Service.configure(
        :disk,
        { local: { service: "Disk", root: Rails.root.join("storage") } },
      )
    end
  end
end
