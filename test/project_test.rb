require 'project'

class TestProject < Test::Unit::TestCase
  def test_init_sets_attributes
    attrs = {:name => "project", :status => 'Success', 
             :activity => 'Sleeping', :url => 'http://cruise.com/project',
             :status_report => :sr}
    proj = CCPanel::Project.new attrs
    assert_equal attrs[:name], proj.name
    assert_equal attrs[:status], proj.status
    assert_equal attrs[:activity], proj.activity
    assert_equal attrs[:url], proj.url
    assert_equal attrs[:status_report], proj.status_report
  end

  def test_status_priority
    assert_equal(1, CCPanel::Project.new(:status => 'Success', :activity => 'Sleeping').status_priority)
    assert_equal(2, CCPanel::Project.new(:status => 'Success', :activity => 'Building').status_priority)
    assert_equal(3, CCPanel::Project.new(:status => 'Failure', :activity => 'Sleeping').status_priority)
    assert_equal(4, CCPanel::Project.new(:status => 'Failure', :activity => 'Building').status_priority)
  end

  def test_status_activity
    assert_equal('success', CCPanel::Project.new(:status => 'Success', :activity => 'Sleeping').status_activity)
    assert_equal('success-building', CCPanel::Project.new(:status => 'Success', :activity => 'Building').status_activity)
    assert_equal('failure', CCPanel::Project.new(:status => 'Failure', :activity => 'Sleeping').status_activity)
    assert_equal('failure-building', CCPanel::Project.new(:status => 'Failure', :activity => 'Building').status_activity)
  end
end
