# setting gems
add_source "http://ruby.taobao.org"
gem 'haml-rails'
gem 'bootstrap-generators'
gem 'bootstrap-sass'
gem 'simple_form', '~>3.1.0.rc1'
gem 'font-awesome-rails'
gem 'active_model_serializers'
gem 'draper'

gem_group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
end

gem_group :development, :test do
  gem 'pry-rails'
  gem 'pry-doc'
  gem 'pry-byebug'
end

gem_group :development, :test do
  gem 'rspec-rails'
  gem 'spring-commands-rspec'
  gem 'factory_girl_rails'
  gem 'capybara'
  gem 'rb-fsevent', require:false
  gem 'guard-rspec'
end

comment_lines 'Gemfile', /rubygems\.org/
comment_lines 'Gemfile', /jbuilder/i
uncomment_lines 'Gemfile', /gem.*bcrypt/
run '''
  spring stop
  bundle
  bundle exec spring binstub --all
'''

# setting view templates:
generate 'bootstrap:install'
generate 'simple_form:install --bootstrap -f'
remove_file 'app/views/layouts/application.html.erb'
gsub_file 'app/views/layouts/application.html.haml', /%title.*\n/, "%title #{@app_name}\n"
gsub_file 'app/views/layouts/application.html.haml', /(alert-\#{)(\s*name\s*==.*\?)/, '\1%w[alert error].include?(name.to_s) ?'
gsub_file 'app/views/layouts/application.html.haml', /^(\s+)span/, '\1%span'


# configure rspec & guard:
run '''
  rails g rspec:install
  bundle exec guard init rspec
'''

spec_require = <<-REQUIRE.strip_heredoc
  require 'capybara/rspec'
  require 'factory_girl'
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
REQUIRE
spec_config = <<-CONFIG
  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.order = "random"
  config.include Capybara::DSL
  config.include FactoryGirl::Syntax::Methods

CONFIG
insert_into_file 'spec/rails_helper.rb', spec_require, before: /^RSpec\.configure.*\n/
insert_into_file 'spec/rails_helper.rb', spec_config, after: /^RSpec\.configure.*\n/
comment_lines 'spec/rails_helper.rb', /fixture_path/
insert_into_file 'config/application.rb', "    config.generators.test_framework false\n",
                 after: /class Application <.*\n/

gsub_file 'Guardfile',/(^guard.*cmd:\s*)'.*'/, "\\1'spring rspec'"


# config git:
append_to_file '.gitignore', <<IGNORE.strip_heredoc
  /.idea/*
  .project
  *.swp
  *~
  .DS_Store
IGNORE
git :init
git add:'-A'
git commit:'-m "init commit"'
