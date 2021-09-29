require 'time'
require 'json'
require 'rest-client'
require 'uri'
require 'pry-byebug'

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
        raise IKEArtifactoryClientNotReady.new(msg = 'Required attributes are missing. IKEArtifactoryGem not ready.') unless self.ready?

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

      def get_directories(path = nil)
        directories = []
        raise IKEArtifactoryClientNotReady.new(msg = 'Required attributes are missing. IKEArtifactoryGem not ready.') unless self.ready?

        if path.nil?
          path = @folder_path
        end

        RestClient::Request.execute(
          :method => :get,
          :url => 'https://' + @server + '/artifactory/api/storage/' + @repo_key + '/' + path + '/',
          :user => @user,
          :password => @password
        ) do |response, request, result|
          if response.code == 200
            answer = JSON.parse response.to_str
            return directories unless answer.key?('children')

            answer['children'].each do |child|
              if child['folder']
                directories.append child['uri'][1..]
              end
            end
            return directories
          end
        end
      end

      def get_days_old(object_path)
        raise IKEArtifactoryClientNotReady.new(msg='Required attributes are missing. IKEArtifactoryGem not ready.') unless self.ready?

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
        raise IKEArtifactoryClientNotReady.new(msg = 'Required attributes are missing. IKEArtifactoryGem not ready.') unless self.ready?

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

      def get_objects_by_days_old(path)
        objects = {}
        raise IKEArtifactoryClientNotReady.new(msg = 'Required attributes are missing. IKEArtifactoryGem not ready.') unless self.ready?
        RestClient::Request.execute(
          :method => :get,
          :url => 'https://' + @server + '/artifactory/api/storage/' + @repo_key + '/' + path,
          :user => @user,
          :password => @password
        )do |response, request, result|
          if response.code == 200
            hash_path = JSON.parse response.to_str
            hash_path['children'].each do | child |
              object_info = self.get_object_info path + child['uri']
              days_old = ( ( Time.now - Time.iso8601(object_info['lastModified']) ) / (24*60*60) ).to_int
              objects[object_info['path'].split('/')[-1]] = days_old
            end
          else
            return nil
          end
        end
        objects
      end

      def get_children(path)
        objects = {}
        raise IKEArtifactoryClientNotReady.new(msg = 'Required attributes are missing. IKEArtifactoryGem not ready.') unless self.ready?
        RestClient::Request.execute(
          :method => :get,
          :url => "https://#{@server}:443/ui/api/v1/ui/nativeBrowser/#{@repo_key}/#{path}",
        ) do |response, request, result|
          if response.code == 200
            hash_path = JSON.parse response.to_str
            hash_path['children'].each do | child |
              days_old = ( ( Time.now.to_i - (child['lastModified']/1000) ) / (24*60*60) ).to_int
              objects[child['name']] = days_old
            end
          else
            return nil
          end
        end
        objects
      end
    end
  end
end
