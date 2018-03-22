require 'simplecov'

SimpleCov.start do
  coverage_dir File.join(Rails.root, 'tmp', 'coverage')
end
