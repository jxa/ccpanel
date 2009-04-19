require 'gtk2'
$:.unshift(File.expand_path(File.dirname(__FILE__)))
require 'panel'

=begin
TODO:
- set preferences through menu
  - http://ruby-gnome2.sourceforge.jp/hiki.cgi?tut-gconf
- handle left click by popping up preferences
- drop nokogiri for rexml (one less thing to install)
- (maybe) cherry-pick projects to monitor
=end

ccpanel = CCPanel::Panel.new
thread = Thread.new do
  ccpanel.update_status_loop
end

Gtk.main
