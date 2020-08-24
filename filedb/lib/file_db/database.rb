require 'json'

module FileDb
  class Database
    attr_reader :database

    def initialize(data_file)
      @database = JSON.parse(File.read(data_file))
    end

    def table_names
      @database.keys.sort
    end

    def table(table_name)
      FileDb::Table.new(@database, table_name)
    end
  end
end
