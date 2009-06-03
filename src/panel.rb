require 'gtk2'
require 'resource'
require 'project_monitor'
require 'status_report'
require 'preferences'

module CCPanel
  class Panel < Gtk::StatusIcon
    def initialize
      super
      self.file = R.inactive
      self.tooltip = 'starting up'

      @prefs = Preferences.new

      if @prefs.servers
        @project_monitor = ProjectMonitor.new(*@prefs.servers)
      else
        @prefs.set
        @project_monitor = ProjectMonitor.new(*@prefs.servers)
      end
      update_status
      signal_connect('popup-menu') do |icon, button, time|
        ccmenu.popup nil, nil, button, time
      end
      signal_connect('activate') do ||
        @prefs.set
      end
    end

    def update_status
      @project_monitor.update
      if @project_monitor.status
        self.tooltip = @project_monitor.status
        self.file = R.status_image(@project_monitor.status_activity)
        @project_monitor.notify
      end
    end

    def update_status_loop
      while true
        sleep @prefs.interval
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
      pref_item.signal_connect("activate"){ @prefs.set }
      exit_item = Gtk::MenuItem.new("Exit CCPanel")
      exit_item.signal_connect("activate"){ Gtk.main_quit }
      menu.append pref_item
      menu.append exit_item
      menu.show_all
      menu
    end
  end
end
