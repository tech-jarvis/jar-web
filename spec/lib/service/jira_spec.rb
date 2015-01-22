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

RSpec.describe Service::JIRA do
  describe ".new_issue_link" do
    it "should return a proper issue link" do
      expect(Service::JIRA.new_issue_link(foo: 'bar')).
          to eql(Squash::Configuration.jira.api_host +
                         Squash::Configuration.jira.api_root +
                         Squash::Configuration.jira.create_issue_details +
                         '?foo=bar'
                 )
    end
  end

  describe ".issue" do
    it "should locate a JIRA issue by key" do
      FakeWeb.register_uri :get,
                           jira_url("/rest/api/2/issue/FOO-123"),
                           response: Rails.root.join('spec', 'fixtures', 'jira_issue.json')

      issue = Service::JIRA.issue('FOO-123')
      expect(issue.key).to eql('FOO-123')
      expect(issue.summary).to eql("Double RTs on coffee bar Twitter monitor")
    end

    it "should return nil for an unknown issue" do
      FakeWeb.register_uri :get,
                           jira_url("/rest/api/2/issue/FOO-124"),
                           response: Rails.root.join('spec', 'fixtures', 'jira_issue_404.json')

      expect(Service::JIRA.issue('FOO-124')).to be_nil
    end
  end

  describe ".statuses" do
    it "should return all known issue statuses" do
      FakeWeb.register_uri :get,
                           jira_url("/rest/api/2/status"),
                           response: Rails.root.join('spec', 'fixtures', 'jira_statuses.json')

      statuses = Service::JIRA.statuses
      expect(statuses.map(&:name)).
          to eql(["Open", "In Progress", "Reopened", "Resolved", "Closed",
                      "Needs Review", "Approved", "Hold Pending Info", "IceBox",
                      "Not Yet Started", "Started", "Finished", "Delivered",
                      "Accepted", "Rejected", "Allocated", "Build", "Verify",
                      "Pending Review", "Stabilized", "Post Mortem Complete"])
    end
  end

  describe ".projects" do
    it "should return all known projects" do
      FakeWeb.register_uri :get,
                           jira_url("/rest/api/2/project"),
                           response: Rails.root.join('spec', 'fixtures', 'jira_projects.json')

      projects = Service::JIRA.projects
      expect(projects.map(&:name)).
          to eql(["Alert", "Android", "Bugs", "Business Intelligence",
                      "Checker", "Coffee Bar", "Compliance"])
    end
  end
end unless Squash::Configuration.jira.disabled?
