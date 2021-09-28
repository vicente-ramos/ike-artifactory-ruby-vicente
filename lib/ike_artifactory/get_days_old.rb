require 'time'

module IKE
  module Artifactory
    class Client
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
    end
  end
end

