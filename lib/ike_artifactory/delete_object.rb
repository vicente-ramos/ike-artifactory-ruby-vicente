require 'pry-byebug'

module IKE
  module Artifactory
    class Client
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
    end
  end
end

