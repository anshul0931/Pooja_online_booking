# frozen_string_literal: true

require "active_storage/service/disk_service"

module ActiveStorage
  class Service::DatabaseService < Service::DiskService
    def initialize(root:, **options)
      super(root: root, **options)
    end

    def upload(key, io, checksum: nil, **options)
      instrument :upload, key: key, checksum: checksum do
        data = io.read

        # Store in the database
        blob = ActiveStorage::Blob.find_by!(key: key)
        blob.update!(data: data)

        # Write to the local cache directory so it's immediately available to DiskController
        write_to_local_cache(key, data)
      end
    end

    def download(key, &block)
      if block_given?
        instrument :streaming_download, key: key do
          yield data_for(key)
        end
      else
        instrument :download, key: key do
          data_for(key)
        end
      end
    end

    def download_chunk(key, range)
      instrument :download_chunk, key: key, range: range do
        data_for(key)[range]
      end
    end

    def exist?(key)
      instrument :exist, key: key do |payload|
        exists = ActiveStorage::Blob.where(key: key).where.not(data: nil).exists?
        payload[:exist] = exists
        exists
      end
    end

    def delete(key)
      instrument :delete, key: key do
        # Nullify database data
        blob = ActiveStorage::Blob.find_by(key: key)
        blob.update!(data: nil) if blob

        # Delete local cache file if it exists
        begin
          File.delete(path_for_raw_key(key))
        rescue Errno::ENOENT
        end
      end
    end

    def path_for(key)
      ensure_local_cache(key)
      path_for_raw_key(key)
    end

    private

    def data_for(key)
      blob = ActiveStorage::Blob.find_by!(key: key)
      blob.data || raise(ActiveStorage::FileNotFoundError)
    end

    def path_for_raw_key(key)
      # DiskService's path_for
      super(key)
    end

    def ensure_local_cache(key)
      cache_path = path_for_raw_key(key)
      unless File.exist?(cache_path)
        blob = ActiveStorage::Blob.find_by(key: key)
        if blob && blob.data
          write_to_local_cache(key, blob.data)
        end
      end
    end

    def write_to_local_cache(key, data)
      cache_path = path_for_raw_key(key)
      FileUtils.mkdir_p(File.dirname(cache_path))
      File.binwrite(cache_path, data)
    end
  end
end
