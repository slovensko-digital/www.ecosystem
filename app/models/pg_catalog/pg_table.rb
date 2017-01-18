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
    # TODO remove table filtering hack
    where(schemaname: schemaname).where('tablename <> ?', 'ar_internal_metadata').order(:tablename)
  end

  def attributes
    PgCatalog::PgAttribute.find_by_table(self)
  end
end
