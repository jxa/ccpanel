require 'status_report'

module CCPanel
  class Project
    SLEEPING = 'Sleeping'
    BUILDING = 'Building'
    CHECKING = 'CheckingModifications'

    SUCCESS = 'Success'
    FAILURE = 'Failure'

    attr_accessor :name, :status, :activity, :url, :status_report

    def initialize(attributes = {})
      update_attributes attributes
    end

    def update_attributes(attributes)
      attributes.each do |attr, value|
        self.send "#{attr}=", value
      end      
    end

    # integer which represents order among status an activity combinations
    # higher number means higher priority
    # i.e. a failing build is higher priority than a successful build
    def status_priority
      case status_activity
      when 'success' : 1
      when 'success-building' : 2
      when 'failure' : 3
      when 'failure-building' : 4
      end
    end

    # corresponds to image names
    def status_activity
      if activity == BUILDING
        "#{status.downcase}-building"
      else
        status.downcase
      end
    end
  end
end
