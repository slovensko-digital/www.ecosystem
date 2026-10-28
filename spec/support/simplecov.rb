require 'simplecov'

SimpleCov.start do
  unless ENV['CC_TEST_REPORTER_ID']
    coverage_dir File.expand_path('../../tmp/coverage', __dir__)
  end
end
