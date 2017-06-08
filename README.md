# Rails Templates

Quickly generate a rails app using [Rails Templates](http://guides.rubyonrails.org/rails_application_templates.html).


## Minimal

*Improved [Le Wagon](http://www.lewagon.org) default configuration:*
- Updated `gemfile` for `Rails 5.1.1`

Get a minimal rails 5 app ready to be deployed on Heroku with Bootstrap, Simple form and debugging gems.

```bash
rails new \
  -T --database postgresql \
  -m https://raw.githubusercontent.com/adesurirey/rails-templates/master/minimal.rb \
  CHANGE_THIS_TO_YOUR_RAILS_APP_NAME
```

## Devise

*Improved [Le Wagon](http://www.lewagon.org) default configuration:*
- Updated `gemfile` for `Rails 5.1.1`
- Automaticaly `annotate` your models when running `rails db:migrate`

Same as minimal **plus** a Devise install with a generated `User` model.


```bash
rails new \
  -T --database postgresql \
  -m https://raw.githubusercontent.com/adesurirey/rails-templates/master/devise.rb \
  CHANGE_THIS_TO_YOUR_RAILS_APP_NAME
```

## Semantic-UI

**TO DO :** Same as Devise **without** Le Wagon's components **plus** `Semantic-UI` integration.

# Testing

*Improved [Le Wagon](http://www.lewagon.org) default configuration :*

- Includes `$ Rubocop` with default configuration
- Continuously run your tests with `$ guard`
- Perfomance monitoring with [Rack-mini-profiler](https://github.com/MiniProfiler/rack-mini-profiler)

These templates are generated without a `test` folder (thanks to the `-T` flag). Starting from here, you can add Minitest & Capybara with the following procedure:

```ruby
# config/application.rb
require "rails/test_unit/railtie" # Un-comment this line
```

```bash
# In the terminal, run:
folders=(controllers fixtures helpers integration mailers models)
for dir in "${folders[@]}"; do mkdir -p "test/$dir" && touch "test/$dir/.keep"; done
cat >test/test_helper.rb <<RUBY
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  fixtures :all
end
RUBY
```

```bash
brew install phantomjs  # on OSX only
                        # Linux: see https://gist.github.com/julionc/7476620
```

```ruby
# Gemfile
group :development, :test do
  gem 'rubocop', require: false

  gem 'guard'
  gem 'guard-minitest'

  gem 'capybara', require: false
  gem 'capybara-screenshot', require: false
  gem 'poltergeist', require: false
  gem 'launchy', require: false
  gem 'minitest-reporters'

  gem 'rack-mini-profiler', require: false

  # [...]
end
```

```bash
$ bundle install
$ guard init
```

```ruby
# test/test_helper.rb
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/reporters'
Minitest::Reporters.use! [Minitest::Reporters::SpecReporter.new]

class ActiveSupport::TestCase
  fixtures :all
end

require 'capybara/rails'
class ActionDispatch::IntegrationTest
  include Capybara::DSL
  def teardown
    Capybara.reset_sessions!
    Capybara.use_default_driver
    Warden.test_reset!
  end
end

require 'capybara/poltergeist'
Capybara.default_driver = :poltergeist

include Warden::Test::Helpers
Warden.test_mode!
```

```ruby
# Guardfile
guard :minitest, spring: true do
  # with Minitest::Unit
  watch(%r{^test/(.*)\/?test_(.*)\.rb$})
  watch(%r{^lib/(.*/)?([^/]+)\.rb$})     { |m| "test/#{m[1]}test_#{m[2]}.rb" }
  watch(%r{^test/test_helper\.rb$})      { 'test' }

  # with Minitest::Spec
  # watch(%r{^spec/(.*)_spec\.rb$})
  # watch(%r{^lib/(.+)\.rb$})         { |m| "spec/#{m[1]}_spec.rb" }
  # watch(%r{^spec/spec_helper\.rb$}) { 'spec' }

  # Rails 4
  # watch(%r{^app/(.+)\.rb$})                               { |m| "test/#{m[1]}_test.rb" }
  # watch(%r{^app/controllers/application_controller\.rb$}) { 'test/controllers' }
  # watch(%r{^app/controllers/(.+)_controller\.rb$})        { |m| "test/integration/#{m[1]}_test.rb" }
  # watch(%r{^app/views/(.+)_mailer/.+})                    { |m| "test/mailers/#{m[1]}_mailer_test.rb" }
  # watch(%r{^lib/(.+)\.rb$})                               { |m| "test/lib/#{m[1]}_test.rb" }
  # watch(%r{^test/.+_test\.rb$})
  # watch(%r{^test/test_helper\.rb$}) { 'test' }

  # Rails < 4
  watch(%r{^app/controllers/(.*)\.rb$}) { |m| "test/functional/#{m[1]}_test.rb" }
  watch(%r{^app/helpers/(.*)\.rb$})     { |m| "test/helpers/#{m[1]}_test.rb" }
  watch(%r{^app/models/(.*)\.rb$})      { |m| "test/unit/#{m[1]}_test.rb" }
end
```

```ruby
# config/initializers/rack_profiler.rb
if Rails.env == 'development'
  require 'rack-mini-profiler'

  # initialization is skipped so trigger it
  Rack::MiniProfilerRails.initialize!(Rails.application)
end
```

```YAML
# .rubocop.yml
AllCops:
  TargetRubyVersion: 2.3
  Include:
    - '**/Rakefile'
    - '**/config.ru'
  Exclude:
    - 'lib/tasks/auto_annotate_models.rake'
    - 'db/**/*'
    - 'config/**/*'
    - 'script/**/*'
    - 'bin/**/*'
    - !ruby/regexp /old_and_unused\.rb$/
    - 'app/admin/*'
    - 'tmp/*'
    - Guardfile
    - Gemfile

Documentation:
  Enabled: false

FrozenStringLiteralComment:
  Enabled: false

ClassAndModuleChildren:
  Enabled: false

Metrics/BlockLength:
  Enabled: true
  Exclude:
    - lib/tasks/**/*

TrailingCommaInLiteral:
  Enabled: false

StringLiterals:
  Enabled: false

AsciiComments:
  Enabled: false

AlignParameters:
  Enabled: false

Metrics/LineLength:
  Max: 100

Style/Lambda:
  Enabled: false

Style/SignalException:
  Enabled: false

Style/NumericLiteralPrefix:
  Enabled: false

Style/NumericLiterals:
  Enabled: false

Style/SymbolArray:
  Enabled: false
```

# CI with Wercker

Continuous integration with Wercker

```ruby
# wercker requirements
gem 'execjs'
gem 'therubyracer'
```

```YAML
# wercker.yml
box: ruby:2.3.3

# You can also use services such as databases. Read more on our dev center:
# http://devcenter.wercker.com/docs/services/index.html
services:
    - redis
    - id: postgres
      env:
       POSTGRES_PASSWORD: ourlittlesecret
       POSTGRES_USER: testuser
# services:
    # - postgres
    # http://devcenter.wercker.com/docs/services/postgresql.html

    # - mongo
    # http://devcenter.wercker.com/docs/services/mongodb.html

# This is the build pipeline. Pipelines are the core of wercker
# Read more about pipelines on our dev center
# http://devcenter.wercker.com/docs/pipelines/index.html
build:
    # Steps make up the actions in your pipeline
    # Read more about steps on our dev center:
    # http://devcenter.wercker.com/docs/steps/index.html
    steps:
        - adesurirey/install-phantomjs@0.0.5
        - rails-database-yml
        - script:
          name: nokogiri tricks
          code: bundle config build.nokogiri --use-system-libraries
        - bundle-install
        - script:
          name: run migration
          code: rake db:migrate RAILS_ENV=test
        - script:
          name: load fixture
          code: rake db:fixtures:load RAILS_ENV=test
        - script:
            name: run rubocop
            code: bundle exec rubocop
        - script:
            name: test
            code: bundle exec rake test RAILS_ENV=test
```

