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

require 'spec_helper'

describe EnvironmentsController do
  describe "#update" do
    before(:each) { @environment = FactoryGirl.create(:environment, sends_emails: true) }

    it "should require a logged-in user" do
      patch :update, polymorphic_params(@environment, false, environment: {sends_emails: false}, format: 'json')
      expect(response.status).to eql(401)
      expect(@environment.reload.sends_emails?).to be_true
    end

    context '[authenticated]' do
      before(:each) { login_as @environment.project.owner }

      it "should allow admins to alter the environment" do
        user = FactoryGirl.create(:membership, project: @environment.project, admin: true).user
        login_as user

        patch :update, polymorphic_params(@environment, false, environment: {sends_emails: false}, format: 'json')
        expect(response.status).to eql(200)
        expect(@environment.reload.sends_emails?).to be_false
      end

      it "should not allow members to alter the environment" do
        login_as FactoryGirl.create(:membership, project: @environment.project, admin: false).user
        patch :update, polymorphic_params(@environment, false, environment: {sends_emails: false}, format: 'json')
        expect(response.status).to eql(403)
        expect(@environment.reload.sends_emails?).to be_true
      end

      it "should allow owners to alter the environment" do
        patch :update, polymorphic_params(@environment, false, environment: {sends_emails: false}, format: 'json')
        expect(response.status).to eql(200)
        expect(@environment.reload.sends_emails?).to be_false
        expect(response.body).to eql(@environment.to_json)
      end

      it "should not allow protected fields to be set" do
        expect { patch :update, polymorphic_params(@environment, false, environment: {bugs_count: 128}, format: 'json') }.not_to change(@environment, :bugs_count)
        expect(response.status).to eql(400)
      end
    end
  end
end
