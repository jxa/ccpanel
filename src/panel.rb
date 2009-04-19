require 'gtk2'
require 'resource'
require 'project_monitor'
require 'status_report'

module CCPanel
  class Panel < Gtk::StatusIcon
    STATUS_REPORT = 'https://user:password@example.com/XmlStatusReport.aspx'

    def initialize
      super
      self.file = R.inactive
      self.tooltip = 'starting up'

      @project_monitor = ProjectMonitor.new(STATUS_REPORT)
      update_status
      signal_connect('popup-menu') do |icon, button, time|
        ccmenu.popup nil, nil, button, time
      end
      signal_connect('activate') do ||
        puts "connect preferences menu to this signal"
      end
    end

    def update_status
      @project_monitor.update
      self.tooltip = @project_monitor.status
      self.file = R.status_image(@project_monitor.status_activity)
      @project_monitor.notify
    end

    def update_status_loop
      while true
        sleep 30
        update_status
      end
    end

    def ccmenu
      menu = Gtk::Menu.new
      @project_monitor.projects do |proj|
        item = Gtk::ImageMenuItem.new(proj.name)
        item.signal_connect("activate"){ `firefox '#{proj.url}'` }
        item.image = Gtk::Image.new(R.status_image(proj.status_activity))
        menu.append item
      end
      pref_item = Gtk::MenuItem.new("Preferences")
      pref_item.signal_connect("activate"){ puts "connect preferences menu to this signal" }
      exit_item = Gtk::MenuItem.new("Exit CCPanel")
      exit_item.signal_connect("activate"){ Gtk.main_quit }
      menu.append pref_item
      menu.append exit_item
      menu.show_all
      menu
    end
  end
end
