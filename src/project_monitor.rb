require 'status_report'

module CCPanel
  class ProjectMonitor
    attr_reader :sources

    def initialize(*urls)
      @sources = []
      urls.each { |url| @sources << StatusReport.new(url) }
    end

    def update
      @prev_status = status_activity
      expire_memoized_vars
      sources.each { |source| source.update }
    end

    def unsorted_projects
      sources.map {|source| source.projects }.flatten.compact
    end

    def projects
      sorted = unsorted_projects.sort { |a,b| a.name.downcase <=> b.name.downcase }
      if block_given?
        sorted.each { |proj| yield proj }
      else
        sorted
      end
    end

    def highest_priority
      return @highest_priority if @highest_priority
      sorted = unsorted_projects.sort { |a,b|
        a.status_priority <=> b.status_priority
      }
      @highest_priority = sorted.last
    end

    def status
      highest_priority && highest_priority.status
    end

    def status_activity
      highest_priority && highest_priority.status_activity
    end

    def notify
      if status_activity =~ /failure/ && @prev_status =~ /success/
        notify_send :error, 'A recent check-in has broken the build'
      elsif status_activity =~ /success/ && @prev_status =~ /failure/
        notify_send :info, 'Build has been fixed'
      elsif status_activity == 'failure' && @prev_status == 'failure-building'
        notify_send :error, 'Build is still broken'
      elsif status_activity == 'success' && @prev_status == 'success-building'
        notify_send :info, 'Another successful build'
      end
    end

    private

    def expire_memoized_vars
      @highest_priority = nil
    end

    # type should be one of :error, :warning, :info
    # TODO: auto-detect or allow preference for notify-send location
    def notify_send(type, message)
      @notify_send ||= '/usr/bin/notify-send'
      puts "#@notify_send -i gtk-dialog-#{type} 'CruiseControl' \"#{message}\""
      `#@notify_send -i gtk-dialog-#{type} 'CruiseControl' \"#{message}\"`
    end
  end
end
