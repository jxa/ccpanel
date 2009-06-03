require 'gtk2'
require 'gconf2'
require 'uri'

module CCPanel
  class Preferences

    def initialize
      @gconf = GConf::Client.default
      @gconf.add_dir("/apps/ccpanel")
    end

    def set
      @dialog = Gtk::Dialog.new("Preferences", 
                                nil,
                                Gtk::Dialog::MODAL,
                                [ Gtk::Stock::OK, Gtk::Dialog::RESPONSE_OK ],
                                [ Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL ])
      @dialog.default_response = Gtk::Dialog::RESPONSE_OK
      label1 = Gtk::Label.new("Server 1")
      label2 = Gtk::Label.new("Server 2")
      label3 = Gtk::Label.new("Server 3")
      label4 = Gtk::Label.new("Server 4")

      server1 = Gtk::Entry.new
      server2 = Gtk::Entry.new
      server3 = Gtk::Entry.new
      server4 = Gtk::Entry.new
      
      s = servers
      unless s.nil? || s.empty?
        server1.text = s[0]
        server2.text = s[1] || ''
        server3.text = s[2] || ''
        server4.text = s[3] || ''
      end

      # user.text = (GLib::user_name)
      # real.text = (GLib::real_name)
      # home.text = (GLib::home_dir)
      # host.text = (GLib::host_name)

      table = Gtk::Table.new(4, 2, false)
      table.attach_defaults(label1,  0, 1, 0, 1)
      table.attach_defaults(label2,  0, 1, 1, 2)
      table.attach_defaults(label3,  0, 1, 2, 3)
      table.attach_defaults(label4,  0, 1, 3, 4) 
      table.attach_defaults(server1, 1, 2, 0, 1)
      table.attach_defaults(server2, 1, 2, 1, 2)
      table.attach_defaults(server3, 1, 2, 2, 3)
      table.attach_defaults(server4, 1, 2, 3, 4)
      table.row_spacings = 5
      table.column_spacings = 5
      table.border_width = 10

      @dialog.vbox.add(table)
      @dialog.show_all

      # Run the dialog and output the data if user okays it
      valid = false
      until valid
        @dialog.run do |response|
          if response == Gtk::Dialog::RESPONSE_OK
            servers = [server1.text, server2.text, server3.text, server4.text]
            servers.delete_if { |s| s == '' }
            if servers.empty?
              #error_message "You must provide the URI of at least one server to monitor"
              @gconf["/apps/ccpanel/servers"] = '' && valid = true
            elsif servers.all? { |s| valid_uri? s }
              valid = true
              @gconf["/apps/ccpanel/servers"] = servers
            else
              error_message "There is an error in one of your server URIs. ccpanel currently only accepts basic auth via https. Example: https://user:pass@example.com/XmlStatusReport.aspx"
            end
          else
            valid = true
          end
        end
      end
      @dialog.destroy
    end

    def error_message(message)
      msg = Gtk::MessageDialog.new(@dialog, 
                                   Gtk::Dialog::DESTROY_WITH_PARENT,
                                   Gtk::MessageDialog::ERROR,
                                   Gtk::MessageDialog::BUTTONS_CLOSE,
                                   message)
      msg.run
      msg.destroy
    end

    def servers
      @gconf["/apps/ccpanel/servers"]
    end

    def interval
      30
    end

    private
    def valid_uri?(str)
      u = URI.parse(str)
      u.scheme == 'https' && u.userinfo
    rescue
      false
    end
  end
end
