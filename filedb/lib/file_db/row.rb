require 'json'

module FileDb
  class Row
    attr_reader :row

    def initialize(database, table_name, row)
      @database = database
      @table_name = table_name
      @row = row
    end

    def update(attributes)
      attributes.keys.map do |attribute|
        @row[attribute.to_sym] = attributes[attribute]
      end
      @database[@table_name].map!{|row| row['id'] == @row[:id] ? @row : row}
      self.save

      @row
    end

    def delete
      @database[@table_name].reject!{|row| row['id'] == @row[:id]}
      self.save

      @row
    end

    private

    def save
      File.open('fixtures/data.json','w') do |f|
        f.write(JSON.pretty_generate(@database))
      end
    end
  end
end
