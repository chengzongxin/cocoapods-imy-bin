SKIP_UNRELEASED_VERSIONS = false

# Specify your gem's dependencies in cocoapods-imy-bin.gemspec


def cp_gem(name, repo_name, branch = 'master', path: false, absolute_path: nil)
  return gem name if SKIP_UNRELEASED_VERSIONS
  opts = if absolute_path
           { :path => absolute_path }
         elsif path
           { :path => "../#{repo_name}" }
         else 
           url = "https://github.com/CocoaPods/#{repo_name}.git"
           { :git => url, :branch => branch }
         end
  gem name, opts
  p "cp_gem"
  p opts
end

source 'https://rubygems.org'


group :development do

  cp_gem 'cocoapods'                             '',false,absolute_path: '/Users/joe.cheng/cocoapods_debug/CocoaPods'
  gem 'xcodeproj'
  cp_gem 'cocoapods-imy-bin',                'cocoapods-imy-bin',path: 'cocoapods-imy-bin'

  gem 'cocoapods-generate'
  gem 'mocha'
  gem 'bacon'
  gem 'mocha-on-bacon'
  gem 'prettybacon'
  gem 'ruby-debug-ide'
  gem 'debase', '0.2.5.beta2'
end
