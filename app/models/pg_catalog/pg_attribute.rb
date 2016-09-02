class PgCatalog::PgAttribute < ActiveRecord::Base
  self.table_name = 'pg_attribute'

  def self.find_by_table(table)
    select('pg_attribute.*, y.*, fa.attname AS fattname, ft.relname AS frelname, fs.nspname AS fnspname').
      where('s.nspname = ? AND t.relname = ? AND pg_attribute.attnum > 0 AND NOT pg_attribute.attisdropped', table.schemaname, table.tablename).
      order("CASE WHEN pg_attribute.attname IN ('created_at', 'updated_at') THEN 1 ELSE 0 END, pg_attribute.attnum").
      joins(<<-SQL)
      JOIN pg_catalog.pg_class t ON pg_attribute.attrelid = t.oid AND t.relkind = 'r'
      JOIN pg_catalog.pg_namespace s ON t.relnamespace = s.oid
      JOIN pg_catalog.pg_type y ON pg_attribute.atttypid = y.oid
      LEFT JOIN pg_catalog.pg_constraint f ON f.connamespace = s.oid AND f.conrelid = t.oid AND f.conkey[1] = pg_attribute.attnum
      LEFT JOIN pg_catalog.pg_attribute fa ON f.confrelid = fa.attrelid AND f.confkey[1] = fa.attnum
      LEFT JOIN pg_catalog.pg_class ft ON f.confrelid = ft.oid
      LEFT JOIN pg_catalog.pg_namespace fs ON ft.relnamespace = fs.oid
    SQL
  end
end
