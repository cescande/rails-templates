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
gem 'erubis'
gem 'redis'

gem 'sass-rails'
gem 'jquery-rails'
gem 'uglifier'
gem 'bootstrap-sass'
gem 'font-awesome-sass'
gem 'simple_form', github: 'elsurudo/simple_form', branch: 'rails-5.1.0'
gem 'autoprefixer-rails'
gem 'webpacker'

group :development, :test do
  gem 'binding_of_caller'
  #{Rails.version >= "5" ? nil : "gem 'quiet_assets'"}
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'spring'
  #{Rails.version >= "5" ? "gem 'listen', '~> 3.0.5'" : nil}
  #{Rails.version >= "5" ? "gem 'spring-watcher-listen', '~> 2.0.0'" : nil}
  gem 'faker'
end

group :development do
  gem 'web-console'
  gem 'annotate'
end

#{Rails.version < "5" ? "gem 'rails_12factor', group: :production" : nil}
RUBY

# Ruby version
########################################
file ".ruby-version", RUBY_VERSION

# Procfiles
########################################
file 'Procfile', <<-YAML
web: bundle exec puma -C config/puma.rb
YAML

file 'Procfile.dev', <<-YAML
web: bundle exec rails s
webpacker: ./bin/webpack-dev-server
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
run "curl -L https://github.com/lewagon/stylesheets/archive/master.zip > stylesheets.zip"
run "unzip stylesheets.zip -d app/assets && rm stylesheets.zip && mv app/assets/rails-stylesheets-master app/assets/stylesheets"

run 'rm app/assets/javascripts/application.js'
file 'app/assets/javascripts/application.js', <<-JS
//= require jquery
//= require jquery_ujs
//= require bootstrap-sprockets
//= require_tree .
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
    <%= yield %>
    <%= javascript_include_tag 'application' %>
  </body>
</html>
HTML

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
  generate('simple_form:install', '--bootstrap')
  generate(:controller, 'pages', 'home', '--no-helper', '--no-assets', '--skip-routes')

  # Webpack + React
  ########################################
  rails_command('webpacker:install')
  rails_command('webpacker:install:react')

  # Routes
  ########################################
  route(
    "root to: 'pages#home'

    # Simple hack to get react-router over rails routes
    # get '*path', to: 'site#index'"
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
/public/packs
/public/packs-test
/node_modules
TXT

  # Annotate
  ########################################
  generate('annotate:install')

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
    HEREDOC

  # Git
  ########################################
  git :init
  git add: "."
  git commit: %Q{ -m 'Initial commit with devise template from https://github.com/adesurirey/rails-templates' }
end
