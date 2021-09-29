require 'time'
require 'json'
require 'rest-client'

module IKE
  module Artifactory
    class Client
      attr_accessor :server
      attr_accessor :repo_key
      attr_accessor :folder_path
      attr_accessor :user
      attr_accessor :password

      def initialize(**args)
        @server = args[:server]
        @repo_key = args[:repo_key]
        @folder_path = args[:folder_path]
        @user = args[:user]
        @password = args[:password]
      end

      def log_end_task
        "IKEArtifactoryGem end it's tasks"
      end

      def ready?
        if ([@server, @repo_key, @folder_path].include? nil ) || ([@user, @password].include? nil )
          return false
        end
        true
      end

      def delete_object(object_path)
        raise IKEArtifactoryGemNotReady.new(msg = 'Required attributes are missing. IKEArtifactoryGem not ready.') unless self.ready?

        RestClient::Request.execute(
          :method => :delete,
          :url => 'https://' + @server + '/artifactory/' + @repo_key + '/' + object_path,
          :user => @user,
          :password => @password
        ) do |response, request, result|
          return true if response.code == 204
          return false
        end
      end

      def get_days_old(object_path)

        raise IKEArtifactoryGemNotReady.new(msg='Required attributes are missing. IKEArtifactoryGem not ready.') unless self.ready?

        RestClient::Request.execute(
          :method => :get,
          :url => 'https://' + @server + '/artifactory/api/storage/' + @repo_key + '/' + object_path,
          :user => @user,
          :password => @password
        ) do |response, request, result|
          if response.code == 200
            answer = JSON.parse response.to_str
            return ( ( Time.now - Time.iso8601(answer['lastModified']) ) / (24*60*60) ).to_int
          else
            return -1
          end
        end
      end

      def get_object_info(object_path)
        raise IKEArtifactoryGemNotReady.new(msg = 'Required attributes are missing. IKEArtifactoryGem not ready.') unless self.ready?

        RestClient::Request.execute(
          :method => :get,
          :url => 'https://' + @server + '/artifactory/api/storage/' + @repo_key + '/' + object_path,
          :user => @user,
          :password => @password
        ) do |response, request, result|
          if response.code == 200
            return JSON.parse response.to_str
          end
        end
      end
    end
  end
end