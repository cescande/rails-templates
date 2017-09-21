run "pgrep spring | xargs kill -9"

# GEMFILE
########################################
run "rm Gemfile"
file 'Gemfile', <<-RUBY
source 'https://rubygems.org'
ruby '#{RUBY_VERSION}'

gem 'rails', '#{Rails.version}'
gem 'puma'
gem 'pg'
gem 'figaro'
gem 'jbuilder', '~> 2.0'
gem 'devise', git: 'https://github.com/gogovan/devise.git', branch: 'rails-5.1'
gem 'erubis'
gem 'redis'

gem 'sass-rails'
gem 'jquery-rails'
gem 'uglifier'
gem 'semantic-ui-sass', git: 'https://github.com/doabit/semantic-ui-sass.git'
gem 'simple_form', github: 'elsurudo/simple_form', branch: 'rails-5.1.0'
gem 'autoprefixer-rails'

group :development, :test do
  gem 'binding_of_caller'
  #{Rails.version >= "5" ? nil : "gem 'quiet_assets'"}
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'spring'
  #{Rails.version >= "5" ? "gem 'listen', '~> 3.0.5'" : nil}
  #{Rails.version >= "5" ? "gem 'spring-watcher-listen', '~> 2.0.0'" : nil}
end

group :development do
  gem 'web-console'
  gem 'annotate'
  gem 'letter_opener_web'
end

#{Rails.version < "5" ? "gem 'rails_12factor', group: :production" : nil}
RUBY

# Ruby version
########################################
file ".ruby-version", RUBY_VERSION

# Procfile
########################################
file 'Procfile', <<-YAML
web: bundle exec puma -C config/puma.rb
YAML

# Spring conf file
########################################
inject_into_file 'config/spring.rb', before: ').each { |path| Spring.watch(path) }' do
  "  config/application.yml\n"
end

# Puma conf file
########################################
if Rails.version < "5"
puma_file_content = <<-RUBY
threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }.to_i

threads     threads_count, threads_count
port        ENV.fetch("PORT") { 3000 }
environment ENV.fetch("RAILS_ENV") { "development" }
RUBY

file 'config/puma.rb', puma_file_content, force: true
end

# Assets
########################################
run "rm -rf app/assets/stylesheets"
run "curl -L https://github.com/adesurirey/rails-stylesheets/archive/master.zip > stylesheets.zip"
run "unzip stylesheets.zip -d app/assets && rm stylesheets.zip && mv app/assets/rails-stylesheets-master app/assets/stylesheets"

run 'rm app/assets/javascripts/application.js'
file 'app/assets/javascripts/application.js', <<-JS
//= require jquery
//= require jquery_ujs
//= require semantic-ui
//= require_tree .
JS

file 'app/assets/javascripts/semantic_initializers.js', <<-JS
// All semantic JS you use must be initialized here
// See "usage" tab in semantic-doc to find initializers

// Dismisable message
$('.message .close')
  .on('click', function() {
    $(this)
      .closest('.message')
      .transition('fade')
    ;
  })
;

// Dropdowns
// See https://semantic-ui.com/modules/dropdown.html#/usage
///////////////////////////////////////////////////////////
// $('.ui.dropdown')
//   .dropdown()
// ;

// Modal
// See https://semantic-ui.com/modules/modal.html#/usage
///////////////////////////////////////////////////////////
// $('.ui.modal')
//   .modal()
// ;

// Add your initializers here
JS

# Dev environment
########################################
gsub_file('config/environments/development.rb', /config\.assets\.debug.*/, 'config.assets.debug = false')

# Layout
########################################
run 'rm app/views/layouts/application.html.erb'
file 'app/views/layouts/application.html.erb', <<-HTML
<!DOCTYPE html>
<html>
  <head>
    <title>TODO</title>
    <%= csrf_meta_tags %>
    #{Rails.version >= "5" ? "<%= action_cable_meta_tag %>" : nil}
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <%= stylesheet_link_tag    'application', media: 'all' %>
  </head>
  <body>
    <%= render 'shared/navbar' %>
    <%= semantic_flash %>
    <%= yield %>
    <%= javascript_include_tag 'application' %>
  </body>
</html>
HTML

# Navbar
run "mkdir app/views/shared"
run "curl -L https://gist.githubusercontent.com/adesurirey/15488eadd6cef9988f223e7203043588/raw/898d51a067f8dcd467fd096b7b92db1480c26213/semantic_navbar.html.erb > app/views/shared/_navbar.html.erb"
run "curl -L https://raw.githubusercontent.com/lewagon/rails-templates/master/logo.png > app/assets/images/logo.png"

# README
########################################
markdown_file_content = <<-MARKDOWN
Rails app generated with [adesurirey/rails-templates](https://github.com/adesurirey/rails-templates), based on [Le Wagon coding bootcamp](https://www.lewagon.com) team template.
MARKDOWN
file 'README.md', markdown_file_content, force: true

# Generators
########################################
generators = <<-RUBY
config.generators do |generate|
      generate.assets false
      generate.helper false
    end
RUBY

environment generators

########################################
# AFTER BUNDLE
########################################
after_bundle do
  # Generators: db + simple form + pages controller
  ########################################
  rake 'db:drop db:create db:migrate'
  generate('simple_form:install')
  generate(:controller, 'pages', 'home', '--no-helper', '--no-assets', '--skip-routes')

  # Routes
  ########################################
  route(
    "root to: 'pages#home'

    if Rails.env.development?
      mount LetterOpenerWeb::Engine, at: '/letter_opener'
    end"
  )

  # Git ignore
  ########################################
  run "rm .gitignore"
  file '.gitignore', <<-TXT
.bundle
log/*.log
tmp/**/*
tmp/*
*.swp
.DS_Store
public/assets
TXT

  # simple_form initializer x semantic-ui
  # see https://medium.com/@pranav7/integrating-rails-simple-form-with-semantic-ui-c2b40e917b27
  ########################################
  run 'rm config/initializers/simple_form.rb'
  run "curl -L https://gist.githubusercontent.com/pranav7/996f917c6372dbbd98c0d38c85158b9b/raw/8ae574009f661a109112f123eec9bc4d756ef514/simple_form.rb > config/initializers/simple_form.rb"

  # Annotate
  ########################################
  generate('annotate:install')

  # Devise install + user
  ########################################
  generate('devise:install')
  generate('devise', 'User')

  # App controller
  ########################################
  run 'rm app/controllers/application_controller.rb'
  file 'app/controllers/application_controller.rb', <<-RUBY
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!
end
RUBY

  # migrate + devise views
  ########################################
  rake 'db:migrate'
  generate('devise:views')

  # Pages Controller
  ########################################
  run 'rm app/controllers/pages_controller.rb'
  file 'app/controllers/pages_controller.rb', <<-RUBY
class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]

  def home; end
end
RUBY

  # Environments
  ########################################
  environment 'config.action_mailer.delivery_method = :letter_opener_web',  env: 'development'
  environment 'config.action_mailer.default_url_options = { host: "http://localhost:3000" }', env: 'development'
  environment 'config.action_mailer.default_url_options = { host: "http://TODO_PUT_YOUR_DOMAIN_HERE" }', env: 'production'

  # Figaro
  ########################################
  run "bundle binstubs figaro"
  run "figaro install"
  file 'config/application.sample.yml',
    <<~HEREDOC
      # This is a template file for application.yml, which should contain the list
      # of required keys, but NOT the secret values.

      # Please, maintain this file up to date with the list of required keys for the application,
      # with non-secret values, this way your collaborators will known when
      # a new key is required in their own application.yml.

      # Because this is file is shared,
      # DO NOT PUT ANY SECRET VALUE HERE, ONLY THE LIST OF REQUIRED KEYS and public values.
      # Use application.yml to set the whole key + values.

      # Examples:
      #
      # CLOUDINARY_URL: "" # This means \"You need a secret CLOUDINARY_URL in your application.yml\"
      #
      # development:
      #   HOST: 'localhost:3000' # This is not a secret value, I can write it.
      #
      "
    HEREDOC

  # Git
  ########################################
  git :init
  git add: "."
  git commit: %Q{ -m 'Initial commit with Semantic-UI template from https://github.com/adesurirey/rails-templates' }
end
