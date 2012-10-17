# Copyright 2012 Square Inc.
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

require 'spec_helper'

describe Deploy do
  context "[hooks]" do
    it "should queue up a DeployFixMarker job" do
      if RSpec.configuration.use_transactional_fixtures
        pending "This is done in an after_commit hook, and it can't be tested with transactional fixtures (which are always rolled back)"
      end

      Project.where(repository_url: "https://github.com/RISCfuture/better_caller.git").delete_all
      project     = FactoryGirl.create(:project, repository_url: "https://github.com/RISCfuture/better_caller.git")
      environment = FactoryGirl.create(:environment, project: project)
      deploy      = FactoryGirl.build(:deploy, environment: environment)

      dfm = mock('DeployFixMarker')
      DeployFixMarker.should_receive(:new).once.with(deploy).and_return(dfm)
      dfm.should_receive(:perform).once

      deploy.save!
    end
  end
end
