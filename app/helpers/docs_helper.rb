module DocsHelper
  def docs_table_dom_id(table)
    [table.schemaname, table.tablename].join('.')
  end

  def docs_attribute_dom_id(table, attr)
    [table.schemaname, table.tablename, attr.attname].join('.')
  end

  def docs(path)
    translate "docs.#{path.join('.')}", default: ''
  end
end
