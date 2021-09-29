require 'uri'

module IKE
  module Artifactory

    class DockerCleaner
      attr_accessor :repo_url
      attr_accessor :days_old
      attr_accessor :images_exclude_list
      attr_accessor :repo_name
      attr_accessor :repo_key

      def initialize(repo_url:, days_old:, images_exclude_list:, user:, password:)
        @repo_url = repo_url
        @days_old = days_old
        @images_exclude_list = images_exclude_list

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

      end
    end
  end
end
