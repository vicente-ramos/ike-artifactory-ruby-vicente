module IKE
  module Artifactory
    class Client
      def ready?
        if ([@server, @repo_key, @folder_path].include? nil ) || ([@user, @password].include? nil )
          return false
        end
        true
      end
    end
  end
end
