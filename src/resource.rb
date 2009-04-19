module CCPanel
  STATUSES = %w{ building-failed failure failure-building 
                 inactive pause success success-building }
  class Resource
    class << self
      STATUSES.each do |status|
        define_method(status) { status_image(status) }
      end 
      def status_image(name)
        File.expand_path(File.join(File.dirname(__FILE__), '..', 'images', "icon-#{name}.png"))
      end
    end
  end
  R = Resource
end
