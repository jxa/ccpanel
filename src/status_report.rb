require 'uri'
require 'net/http'
require 'net/https'
require 'rexml/document'
require 'project'

module CCPanel
  class StatusReport
    def initialize(uri)
      @uri = URI.parse(uri)
      @projects = {}
    end

    def update
      doc = REXML::Document.new(get_report)
      doc.elements.each('Projects/Project') do |project|
        a = project.attributes
        proj = {
          :name     => a['name'],
          :url      => a['webUrl'],
          :activity => a['activity'],
          :status   => a['lastBuildStatus'],
          :status_report => self }

        if @projects.has_key?(proj[:name])
          @projects[proj[:name]].update_attributes(proj)
        else
          @projects[proj[:name]] = Project.new(proj)
        end
      end
    rescue Timeout::Error
      # TODO: if projects are present, set status to inactive
      # else create a blank project with the server name
      # and set status to inactive.
      # blank project might create problems. is there a better way?
    end

    def projects
      @projects.values
    end

    private

    def get_report
      get_https_with_basic_auth
    end

    def get_https_with_basic_auth
      username, password = @uri.userinfo.split(':')
      http = Net::HTTP.new(@uri.host, @uri.port)
      http.open_timeout = 5
      path = @uri.path == '' ? '/XmlStatusReport.aspx' : @uri.path
      req = Net::HTTP::Get.new(path)
      http.use_ssl = true

      # quiet HTTPS warning messages
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      req.basic_auth username, password
      response = http.request(req)
      return response.body
    end
  end
end
