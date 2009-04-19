require 'uri'
require 'net/http'
require 'net/https'
require 'rubygems'
require 'nokogiri'
require 'project'

module CCPanel
  class StatusReport
    def initialize(uri)
      @uri = URI.parse(uri)
      @projects = {}
    end

    def update
      doc = Nokogiri::XML(get_report)
      doc.css('Project').each do |proj|
        a = proj.attributes
        proj = {
          :name     => a['name'].content,
          :url      => a['webUrl'].content,
          :activity => a['activity'].content,
          :status   => a['lastBuildStatus'].content,
          :status_report => self }

        if @projects.has_key?(proj[:name])
          @projects[proj[:name]].update_attributes(proj)
        else
          @projects[a['name'].content] = Project.new(proj)
        end
      end
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
      req = Net::HTTP::Get.new(@uri.path)
      http.use_ssl = true
      req.basic_auth username, password
      response = http.request(req)
      return response.body
    end
  end
end
