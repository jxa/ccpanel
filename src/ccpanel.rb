require 'gtk2'
$:.unshift(File.expand_path(File.dirname(__FILE__)))
require 'panel'

=begin
TODO:
- validate urls
- (maybe) cherry-pick projects to monitor
=end

ccpanel = CCPanel::Panel.new
thread = Thread.new do
  ccpanel.update_status_loop
end

Gtk.main
