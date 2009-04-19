test_dir = File.expand_path(File.dirname(__FILE__))
$:.unshift test_dir
$:.unshift File.join(test_dir, '..', 'src')
require 'test/unit'
require 'rubygems'
require 'flexmock/test_unit'

require 'project_monitor_test'
require 'project_test'
require 'status_report_test'

