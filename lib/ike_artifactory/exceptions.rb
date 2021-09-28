module IKE
  module Artifactory
    class IKEArtifactoryGemNotReady < StandardError
      def initialize(msg="Unknown.")
        super
      end
    end
  end
end