module Masks
  module Entries
    class Authentication < Masks::Entry
      def session_key
        raw_params[:id]
      end

      def client_id
        raw_params[:id]&.split(":").first
      end

      def session_lifetime
        client.expires_at(:authorization)
      end

      def client
        @client ||= (Masks::Client.find_by!(key: client_id) if client_id)
      end

      def path
        @path ||= session.bag(:entries)[:path]
      end

      def params
        @params ||= session.bag(:entries)[:params]&.with_indifferent_access
      end

      def event
        raw_params[:event]
      end

      def updates
        raw_params[:updates]
      end

      def enter
        oauth_request
      end
    end
  end
end
