require 'json'

module FileDb
  class Row
    def initialize(database, table_name, row)
      @database = database
      @table_name = table_name
      @row = row
    end

    def update(attributes)
      attributes.keys.map do |attribute|
        @row[attribute] = attributes[attribute]
      end
      self.save

      @row
    end

    def delete
      @database[@table_name].reject!{|row| row == @row}
      self.save
    end

    private

    def save
      File.open('fixtures/data.json','w') do |f|
        f.write(JSON.pretty_generate(@database))
      end
    end
  end
end
