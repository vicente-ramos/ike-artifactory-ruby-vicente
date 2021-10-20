require 'uri'
require 'logger'

module IKE
  module Artifactory

    class DockerCleaner
      attr_accessor :repo_url
      attr_accessor :days_old
      attr_accessor :images_exclude_list
      attr_accessor :repo_name
      attr_accessor :repo_key

      attr_reader :client  # is not tested
      attr_reader :most_recent_images  # is not tested
      attr_reader :logger  # is not tested. Used for testing
      attr_reader :actually_delete

      REJECTED_FOLDERS = %w[cache _uploads]

      def initialize(repo_url:,days_old:, images_exclude_list:,
                     user:, password:, most_recent_images:,
                     log_level: ::Logger::INFO, actually_delete: false)

        @repo_url = repo_url
        @days_old = days_old
        @images_exclude_list = images_exclude_list
        @most_recent_images = most_recent_images

        @repo_name = repo_url.split("/")[-2..-1].join('/')
        @repo_key = repo_url.split("/")[-3]

        @actually_delete = actually_delete

        uri = URI(repo_url)
        @client = IKE::Artifactory::Client.new(
          :server => uri.host,
          :repo_key => repo_key,
          :folder_path => repo_name,
          :user => user,
          :password => password
        )

        @logger = Logger.new(STDOUT)
        logger.level = log_level
      end

      def cleanup!
        deleted_images = []
        tags = client.get_children(repo_name)
          .reject { |(folder, age)| REJECTED_FOLDERS.include?(folder) }
          .sort_by {|_key, value| value}.to_h

        too_new_to_delete = tags.keys[0...most_recent_images]

        logger_prefix = "#{repo_url}"

        tags.each do | tag, tag_days_old |

          logger.debug "#{logger_prefix}: examining #{tag}"

          if images_exclude_list.include?(tag)
            logger.info "#{logger_prefix}: tag #{tag} is explicitly excluded from cleanup"
            next
          end

          if too_new_to_delete.include?(tag)
            logger.info "#{logger_prefix}: tag #{tag} is one of the #{most_recent_images} most recent tags, preserving"
            next
          end

          if tag_days_old < days_old
            logger.info "#{logger_prefix}: tag #{tag} is less than #{days_old} days old, preserving"
            next
          end

          logger.info "#{logger_prefix}: removing tag #{tag}"
          if actually_delete
            client.delete_object "#{repo_name}/#{tag}"
          else
            logger.info("#{logger_prefix}: Not actually deleting #{tag} because actually_delete is falsy")
          end
          deleted_images.append(tag)
        end
        deleted_images
      end
    end
  end
end
