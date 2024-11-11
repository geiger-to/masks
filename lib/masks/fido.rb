module Masks
  module Fido
    class << self
      def mds
        @mds ||= FidoMetadata::Store.new
      end

      def find(aaguid: nil, attestation_certificate_key_id: nil, **_args)
        metadata_statement =
          if aaguid
            mds.fetch_statement(aaguid: aaguid)
          else
            mds.fetch_statement(
              attestation_certificate_key_id: attestation_certificate_key_id,
            )
          end

        metadata_statement&.attestation_root_certificates || []
      end

      def aaguid_name(aaguid)
        return unless aaguid
        mds_data = mds.fetch_statement(aaguid:)
        mds_data&.description || aaguids.dig(aaguid, "name")
      end

      private

      def aaguids
        @aaguids ||=
          JSON.parse(
            File.read(Rails.root.join("aaguids", "combined_aaguid.json").to_s),
          )
      end
    end
  end
end
