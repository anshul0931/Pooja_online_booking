# frozen_string_literal: true

require "active_storage/service"

module ActiveStorage
  class Service::DatabaseService < Service
    def initialize(**options)
      # Accept any configuration options (like root) from storage.yml
      Rails.logger.info "[DatabaseService] Initialized"
    end

    def upload(key, io, checksum: nil, **options)
      instrument :upload, key: key, checksum: checksum do
        Rails.logger.info "[DatabaseService] Uploading key: #{key}"
        
        io.rewind if io.respond_to?(:rewind)
        data = io.read
        
        Rails.logger.info "[DatabaseService] Upload key: #{key}, read #{data&.bytesize || 0} bytes"

        blob = ActiveStorage::Blob.find_by!(key: key)
        blob.update!(data: data)

        Rails.logger.info "[DatabaseService] Database blob updated for key: #{key}"
      end
    end

    def download(key, &block)
      Rails.logger.info "[DatabaseService] Download called for key: #{key} (block given: #{block_given?})"
      
      blob = ActiveStorage::Blob.find_by!(key: key)
      data = blob.data || raise(ActiveStorage::FileNotFoundError)

      if block_given?
        instrument :streaming_download, key: key do
          yield data
        end
      else
        instrument :download, key: key do
          data
        end
      end
    end

    def download_chunk(key, range)
      Rails.logger.info "[DatabaseService] Download chunk called for key: #{key}, range: #{range}"
      
      blob = ActiveStorage::Blob.find_by!(key: key)
      data = blob.data || raise(ActiveStorage::FileNotFoundError)

      instrument :download_chunk, key: key, range: range do
        data.byteslice(range)
      end
    end

    def exist?(key)
      instrument :exist, key: key do |payload|
        exists = ActiveStorage::Blob.where(key: key).where.not(data: nil).exists?
        Rails.logger.info "[DatabaseService] Exist? for key: #{key} returned: #{exists}"
        payload[:exist] = exists
        exists
      end
    end

    def delete(key)
      Rails.logger.info "[DatabaseService] Delete called for key: #{key}"
      instrument :delete, key: key do
        blob = ActiveStorage::Blob.find_by(key: key)
        blob.update!(data: nil) if blob
      end
    end

    def delete_prefixed(prefix)
      Rails.logger.info "[DatabaseService] Delete prefixed called for prefix: #{prefix}"
      instrument :delete_prefixed, prefix: prefix do
        ActiveStorage::Blob.where("key LIKE ?", "#{prefix}%").update_all(data: nil)
      end
    end

    def url(key, expires_in:, filename:, disposition:, content_type:, **options)
      Rails.logger.info "[DatabaseService] Generating URL for key: #{key}"
      
      blob = ActiveStorage::Blob.find_by!(key: key)
      
      # Use Rails' built-in route helper to generate proxy/redirect url
      url_options = (ActiveStorage::Current.url_options || {}).reverse_merge(
        host: Rails.application.config.action_controller.default_url_options[:host]
      )

      Rails.application.routes.url_helpers.rails_storage_proxy_url(
        blob,
        host: url_options[:host],
        protocol: url_options[:protocol],
        port: url_options[:port],
        disposition: disposition
      )
    end
  end
end
