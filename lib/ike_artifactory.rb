require 'ike_artifactory/delete_object'
require 'ike_artifactory/evaluate_container_image'
require 'ike_artifactory/exceptions'
require 'ike_artifactory/get_days_old'
require 'ike_artifactory/get_object_info'
require 'ike_artifactory/ready'
require 'ike_artifactory/version'
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
    end
  end
end
