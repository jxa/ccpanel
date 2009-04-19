require 'status_report'

class TestStatusReport < Test::Unit::TestCase
  def fixture_file(name)
    File.expand_path(File.join(File.dirname(__FILE__), 'fixtures', name))
  end

  def test_https_with_basic_auth
    sr = CCPanel::StatusReport.new("https://uname:password@example.com/XmlStatusReport.aspx")
    flexmock(sr) {|mock| mock.should_receive(:get_https_with_basic_auth).once.and_return(:xml) }
    assert_equal :xml, sr.send(:get_report)
  end

  def test_update_all_success
    file = File.open(fixture_file('all_success.aspx'), 'r')
    sr = CCPanel::StatusReport.new("https://uname:password@example.com/XmlStatusReport.aspx")
    flexmock(sr) {|mock| mock.should_receive(:get_https_with_basic_auth).and_return(file) }
    sr.update

    assert_equal 3, sr.projects.size
    sr.projects.each {|p| assert_equal "Success", p.status }
    file.close
  end
end
