require 'simplecov'

SimpleCov.start do
  if ENV['CIRCLE_ARTIFACTS']
    coverage_dir File.join(ENV['CIRCLE_ARTIFACTS'], 'coverage')
  else
    coverage_dir File.join(Rails.root, 'tmp', 'coverage')
  end
end

puts "----"
puts File.join(ENV['CIRCLE_ARTIFACTS'], 'coverage')
puts "----"
