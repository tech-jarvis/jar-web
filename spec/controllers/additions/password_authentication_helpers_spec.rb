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

if Squash::Configuration.authentication.strategy == 'password'
  class FakeController
    def self.helper_method(*) end
    def logger(*) Rails.logger end

    include AuthenticationHelpers
    include PasswordAuthenticationHelpers
  end

  RSpec.describe PasswordAuthenticationHelpers, type: :model do
    before(:each) { @controller = FakeController.new }

    describe "#log_in" do
      before(:all) { @user = FactoryGirl.create(:user, password: 'password123') }

      it "should accept a valid username and password" do
        expect(@controller).to receive(:log_in_user).once.with(@user)
        expect(@controller.log_in(@user.username, 'password123')).to eql(true)
      end

      it "should not accept an unknown username" do
        expect(@controller).not_to receive :log_in_user
        expect(@controller.log_in('unknown', 'password123')).to eql(false)
      end

      it "should not accept an invalid password" do
        expect(@controller).not_to receive :log_in_user
        expect(@controller.log_in(@user.username, 'password-wrong')).to eql(false)
      end
    end
  end
end
