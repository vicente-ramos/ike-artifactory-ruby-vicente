module IKE
  module Artifactory
    class IKEArtifactoryClientNotReady < StandardError
      def initialize(msg="Unknown.")
        super
      end
    end
  end
end