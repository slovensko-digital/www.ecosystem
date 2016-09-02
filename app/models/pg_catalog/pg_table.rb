# == Schema Information
#
# Table name: pg_catalog.pg_tables
#
#  schemaname  :string
#  tablename   :string
#  tableowner  :string
#  tablespace  :string
#  hasindexes  :boolean
#  hasrules    :boolean
#  hastriggers :boolean
#  rowsecurity :boolean
#

class PgCatalog::PgTable < ActiveRecord::Base
  def self.find_by_schema(schemaname)
    where(schemaname: schemaname).order(:tablename)
  end

  def attributes
    PgCatalog::PgAttribute.find_by_table(self)
  end
end
