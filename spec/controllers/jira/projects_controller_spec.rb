# Copyright 2014 Square Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.

require 'rails_helper'

RSpec.describe Jira::ProjectsController, type: :controller do
  describe "#index" do
    it "should a list of known projects" do
      FakeWeb.register_uri :get,
                           jira_url("/rest/api/2/project"),
                           response: Rails.root.join('spec', 'fixtures', 'jira_projects.json')

      get :index, format: 'json'
      expect(response.status).to eql(200)
      body = JSON.parse(response.body)
      expect(body.map { |st| st['name'] }).
          to eql(["Alert", "Android", "Bugs", "Business Intelligence",
                      "Checker", "Coffee Bar", "Compliance"].sort)
    end
  end
end unless Squash::Configuration.jira.disabled?
