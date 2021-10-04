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
      attr_accessor :client  # is not tested
      attr_accessor :most_recent_images  # is not tested
      attr_accessor :tags  # is not tested. Used for testing
      attr_accessor :most_recent_tags  # is not tested. Used for testing
      attr_accessor :logger  # is not tested. Used for testing

      def initialize(repo_url:, days_old:, images_exclude_list:, user:, password:, most_recent_images:)

        @repo_url = repo_url
        @days_old = days_old
        @images_exclude_list = images_exclude_list
        @most_recent_images = most_recent_images

        @repo_name = @repo_url.split("/")[-2..-1].join('/')
        @repo_key = @repo_url.split("/")[-3]

        uri = URI(@repo_url)
        @client = IKE::Artifactory::Client.new(
          :server => uri.host,
          :repo_key => @repo_key,
          :folder_path => @repo_name,
          :user => user,
          :password => password
        )

        @logger = Logger.new(STDOUT)
        @logger.level = Logger::DEBUG
      end

      def cleanup!
        deleted_images = []
        self.tags = client.get_children(@repo_name)
        self.tags = self.tags.sort_by {|_key, value| value}.to_h
        _most_recent_images = tags.keys[0...most_recent_images]

        self.tags.each do | tag, tag_days_old |
          logger.info "Working with tag #{tag}."
          # binding.pry

          if images_exclude_list.include?(tag)
            logger.info "Tag #{tag} is excluded."
            next
          end

          if _most_recent_images.include?(tag)
            logger.info "Tag #{tag} is a recent image."
            next
          end
          if tag_days_old > @days_old
            logger.info "Removing container image: #{tag}."
            client.delete_object "#{@repo_name}/#{tag}"
            deleted_images.append(tag)
          end
        end
        deleted_images
      end
    end
  end
end
