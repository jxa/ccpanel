require 'project_monitor'

class CCPanel::ProjectMonitor
  def notify_send(type, message)
    return type, message
  end
end

class TestProjectMonitor < Test::Unit::TestCase
  def test_initialize
    mock_sr = flexmock(CCPanel::StatusReport)
    mock_sr.should_receive(:new).with("project1url").once.and_return(:sr1)
    mock_sr.should_receive(:new).with("project2url").once.and_return(:sr2)
    monit = CCPanel::ProjectMonitor.new("project1url", "project2url")
    assert_equal [:sr1, :sr2], monit.sources
  end

  def test_update
    mock_sr = flexmock("StatusReport", :projects => [])
    mock_sr.should_receive(:update).once
    monit = CCPanel::ProjectMonitor.new
    flexmock(monit, :sources => [mock_sr])
    monit.update
  end

  def test_notification_integration
    source = CCPanel::StatusReport.new ''
    monit = CCPanel::ProjectMonitor.new
    flexmock(monit, :sources => [source])

    flexmock(source) do |s| 
      s.should_receive(:get_report).and_return(
        fixture(:all_success),
        fixture(:building),
        fixture(:fail),
        fixture(:building_after_fail),
        fixture(:fail),
        fixture(:building_after_fail),
        fixture(:all_success),
        fixture(:building),
        fixture(:all_success))
    end

    # success
    monit.update
    assert_nil monit.notify

    # building
    monit.update
    assert_nil monit.notify

    # fail
    monit.update
    assert_equal [:error, 'A recent check-in has broken the build'], monit.notify

    # building
    monit.update
    assert_nil monit.notify
    
    # fail again
    monit.update
    assert_equal [:error, 'Build is still broken'], monit.notify

    # building
    monit.update
    assert_nil monit.notify

    # success
    monit.update
    assert_equal [:info, 'Build has been fixed'], monit.notify

    # building
    monit.update
    assert_nil monit.notify

    # success
    monit.update
    assert_equal [:info, 'Another successful build'], monit.notify
  end

  def fixture(name)
    file = File.open(File.join(File.dirname(__FILE__), 'fixtures', "#{name.to_s}.aspx"))
    contents = file.read
    file.close
    contents
  end
end
