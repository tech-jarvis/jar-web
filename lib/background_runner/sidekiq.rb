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

module BackgroundRunner

  # `BackgroundRunner` adapter for the Sidekiq job system. See the
  # `concurrency.yml` Configoro file for configuration options.
  #
  # If you are using Sidekiq, you will need to run `rake sidekiq:configure` as
  # part of your deploy process in order to generate the `config/sidekiq.yml`
  # file. To do this in Capistrano, add something like this to your
  # `config/deploy.rb` file:
  #
  # ```` ruby
  # namespace :sidekiq do
  #   task :configure do
  #     run "cd #{release_path} && rake sidekiq:configure RAILS_ENV=#{rails_env}"
  #   end
  # end
  # before 'sidekiq:restart', 'sidekiq:configure'
  # ````

  module Sidekiq
    def self.setup
      ::Sidekiq.configure_server do |config|
        config.redis = Squash::Configuration.concurrency.sidekiq.redis
      end

      ::Sidekiq.configure_client do |config|
        config.redis = Squash::Configuration.concurrency.sidekiq.redis
      end

      require 'sidekiq/testing/inline' if Rails.env.test?
    end

    def self.run(job_name, *arguments)
      job_name = job_name.constantize unless job_name.kind_of?(Class)
      job_name.const_get(:SidekiqAdapter).perform_async *arguments
    end

    def self.extend_job(mod)
      # this could be a subclass whose superclass already included
      # BackgroundRunner::Job; in that case, to ensure we define a sidekiq
      # adapter unique to this subclass, we remvoe and redefine the adapter
      mod.send :remove_const, :SidekiqAdapter rescue nil

      mod.class_eval <<-RUBY
        class SidekiqAdapter
          include ::Sidekiq::Worker
          options = Squash::Configuration.concurrency.sidekiq.worker_options[#{mod.to_s.inspect}]
          sidekiq_options(options.symbolize_keys) if options

          def perform(*args)
            #{mod.to_s}.perform *args
          end
        end
      RUBY
    end
  end
end
