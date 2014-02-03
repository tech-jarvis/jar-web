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

FactoryGirl.define do
  factory :source_map do
    association :environment
    revision '7f9ef6977510b3487483cf834ea02d3e6d7f6f13'
    map GemSourceMap::Map.from_json(Rails.root.join('spec', 'fixtures', 'mapping.json').read)
    from 'hosted'
    to 'original'
  end
end
