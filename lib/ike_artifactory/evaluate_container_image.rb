module IKE
  module Artifactory
    class Client
      def evaluate_container_image image, tag, production_images, days_old
        return true if production_images.include? tag
        return true if (self.get_days_old "#{@folder_path}/#{image}/#{tag}") <= days_old
        false
      end
    end
  end
end

