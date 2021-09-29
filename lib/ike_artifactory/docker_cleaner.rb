require 'uri'

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
      end

      def cleanup!
        tags = @client.get_objects_by_days_old(@repo_name)
        tags = tags.sort_by {|_key, value| value}.to_h
        most_recent_tags = tags.keys[1..@most_recent_images]

        tags.each do | tag, tag_days_old |
          puts "Working with tag #{tag}"

          if @images_exclude_list.include?(tag)
            puts "Tag #{tag} is excluded."
            next
          end

          if most_recent_tags.include?(tag)
            puts "Tag #{tag} is a recent image."
            next
          end

          if tag_days_old > @days_old
            puts "Removing container image: #{tag}."
            @client.delete_object "#{repo_name}/#{tag}"
          end
        end
      end
    end
  end
end
