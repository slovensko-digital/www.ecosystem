class HealthController < ApplicationController
  def all_env_set
    env_content = Rails.root.join('.env').read
    required_env = env_content.
      lines.
      select(&:present?).
      reject { |line| line.start_with?('export') }.
      map { |name| name.split('=', 2).first }

    required_env << 'DATABASE_URL'
    no_values = required_env.select { |variable_name| ENV[variable_name].blank? }
    if no_values.any?
      raise "Missing required ENV variables: #{no_values.join(', ')}"
    else
      render html: 'ok'
    end
  end

  def services
    # check db
    PgCatalog::PgTable.find_by_schema('datahub')

    render html: 'ok'
  end

  private

  def all_schemas
    ActiveRecord::Base.connection.execute('SELECT schema_name FROM information_schema.schemata').map{ |row| row.fetch('schema_name') }
  end
end
