require 'time'

module IKE
  module Artifactory
    class Client
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


