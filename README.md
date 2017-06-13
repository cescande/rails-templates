# Rails Templates

Quickly generate a rails app using [Rails Templates](http://guides.rubyonrails.org/rails_application_templates.html).


## Minimal

Get a minimal rails 5 app ready to be deployed on Heroku with Bootstrap, Simple form and debugging gems.

*Improved [Le Wagon](http://www.lewagon.org) default configuration:*
- Updated `gemfile` for `Rails 5.1.1`

```bash
rails new \
  -T --database postgresql \
  -m https://raw.githubusercontent.com/adesurirey/rails-templates/master/minimal.rb \
  CHANGE_THIS_TO_YOUR_RAILS_APP_NAME
```

## Devise

Same as minimal **plus** a Devise install with a generated `User` model.

*Improved [Le Wagon](http://www.lewagon.org) default configuration:*
- Updated `gemfile` for `Rails 5.1.1`
- Automaticaly `annotate` your models when running `rails db:migrate`
- Include `faker` for nice seeds

```bash
rails new \
  -T --database postgresql \
  -m https://raw.githubusercontent.com/adesurirey/rails-templates/master/devise.rb \
  CHANGE_THIS_TO_YOUR_RAILS_APP_NAME
```
**Tip:** Devise additional translations [here](https://github.com/plataformatec/devise/wiki/I18n)

## Semantic-UI 🎉

This is a beta template, feel free to participate and feedback !

Same as Devise **with** [Semantic UI](https://semantic-ui.com/) full integration.

- Semantic components
- Custom `simple_form` initializer for Semantic UI
- Visibility helpers

```bash
rails new \
  -T --database postgresql \
  -m https://raw.githubusercontent.com/adesurirey/rails-templates/master/semantic-ui.rb \
  CHANGE_THIS_TO_YOUR_RAILS_APP_NAME
```

### Notice:

#### Responsive classes:

Semantic UI has responsive classes, however they're only applicable to grids, containers, rows and columns. Plus, there isn't any `mobile hidden`, `X hidden` class (like `hidden-xs` with Bootstrap).

This template is using the same class names and same approach plus a bit more to reproduce it outside of containers and rows. You'll find the code in `app/assets/stylsheets/config/_screens.scss`, it's based on https://github.com/Semantic-Org/Semantic-UI/issues/1114

You can use it like this:
```html
<body>
   <a class="tablet or lower hidden" />
   <b class="mobile tablet only" />
</body>
```

#### Javascript initializers:

All Semantic-UI `JS` must be initialized in `app/assets/javascripts/semantic_initializers.js`

Look for `Usage` tabs in [Semantic-UI documentation](https://semantic-ui.com/introduction/getting-started.html) to find the good ones.

### Tips:

- Use simple_form checkbox wrappers for great UI:

```ruby
simple_form_for @user do |f|
  f.input :admin, wrapper: :ui_toggle_checkbox
end
```

also availabe: `ui_slider_checkbox`

- Use semantic-ui helpers
  - Breadcrumbs: https://github.com/doabit/semantic-ui-sass#breadcrumbs-helper
  - icons: https://github.com/doabit/semantic-ui-sass#icon-helper

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

# Wercker

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

# Setup staging

Use [recipient_interceptor](https://github.com/croaky/recipient_interceptor) to catch emails

```ruby
# Gemfile
gem 'recipient_interceptor'
```

```YML
# application.yml
development:
 HOST: 'localhost:3000'

test:
 HOST: 'localhost:3000'

staging:
  HOST: 'http://TODO_PUT_YOUR_DOMAIN_HERE-staging'
  EMAIL_RECIPIENTS: "TODO_STAGING@EXAMPLE.COM"

production:
  HOST: 'http://TODO_PUT_YOUR_DOMAIN_HERE'
```

```ruby
# config/environments/production.rb
Rails.application.configure do
  # comment this line
  # config.action_mailer.default_url_options = { host: "http://TODO_PUT_YOUR_DOMAIN_HERE" }

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.default_url_options = { host: ENV["HOST"] }

  # [...]
end
```

```ruby
# config/environments/staging.rb
Rails.application.configure do
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.default_url_options = { host: ENV["HOST"] }
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Attempt to read encrypted secrets from `config/secrets.yml.enc`.
  # Requires an encryption key in `ENV["RAILS_MASTER_KEY"]` or
  # `config/secrets.yml.key`.
  config.read_encrypted_secrets = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = :uglifier
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # `config.assets.precompile` and `config.assets.version` have moved to config/initializers/assets.rb

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = 'http://assets.example.com'

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

  # Mount Action Cable outside main process or domain
  # config.action_cable.mount_path = nil
  # config.action_cable.url = 'wss://example.com/cable'
  # config.action_cable.allowed_request_origins = [ 'http://example.com', /http:\/\/example.*/ ]

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # Use the lowest log level to ensure availability of diagnostic information
  # when problems arise.
  config.log_level = :debug

  # Prepend all log lines with the following tags.
  config.log_tags = [ :request_id ]

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Use a real queuing backend for Active Job (and separate queues per environment)
  # config.active_job.queue_adapter     = :resque
  # config.active_job.queue_name_prefix = "DSD_#{Rails.env}"
  config.action_mailer.perform_caching = false

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Use a different logger for distributed setups.
  # require 'syslog/logger'
  # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new 'app-name')

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger = ActiveSupport::TaggedLogging.new(logger)
  end

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  Mail.register_interceptor RecipientInterceptor.new(ENV['EMAIL_RECIPIENTS'])
end
```

```YML
# config/secrets.yml
staging:
   secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>
```
