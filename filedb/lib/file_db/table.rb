require 'json'

module FileDb
  class Table
    attr_reader :table

    def initialize(database, table_name)
      @database = database
      @table_name = table_name
      @table = @database[@table_name].map{|row| row.transform_keys(&:to_sym)}
    end

    def select(where: nil)
      where.nil? ? @table : self.where(where)
    end

    def insert(row)
      row_id = @table.last[:id] + 1
      row[:id] = row_id
      @table << row
      self.save

      row
    end

    def find(id)
      row = @table.find{|row| row[:id] == id}
      FileDb::Row.new(@database, @table_name, row)
    end

    def where(attributes)
      @table.select do |row|
        attributes_matched = attributes.map do |attribute|
          row[attribute.first] == attribute.last
        end
        row unless attributes_matched.include?(false)
      end
    end

    def joins(join_table_name)
      join_table = @database["#{join_table_name}s"]
      @table.map do |row|
        join_table_row_id = row["#{join_table_name}_id".to_sym]
        join_table_row = join_table.find{|row| row['id'] == join_table_row_id}
        join_table_row.keys.reject{|attribute| attribute == 'id'}.each do |attribute|
          row[attribute.to_sym] = join_table_row[attribute]
        end

        row
      end
    end

    private

    def save
      @database[@table_name] = self.table

      File.open('fixtures/data.json','w') do |f|
        f.write(JSON.pretty_generate(@database))
      end
    end
  end
end
