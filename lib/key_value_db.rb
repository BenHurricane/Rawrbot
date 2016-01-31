class KeyValueDatabase
  # A wrapper class around another database provider to act as a
  # simple key-value store.
  class SQLite
    require 'sqlite3'

    def initialize(filename, key_type = String, value_type = String)
      @db = SQLite3::Database.new(filename)
      init_db(key_type, value_type)
    end

    def close
      @db.close
    end

    def []=(key, value)
      set(key, value)
    end

    def set(key, val)
      @db.transaction do |txn|
        if get(key).nil?
          txn.execute('INSERT INTO data (key,val) VALUES (?,?)', key, val)
        else
          txn.execute('UPDATE data SET val=? WHERE key=?', val, key)
        end
      end
    end

    def [](key)
      get(key)
    end

    def get(key)
      @db.get_first_value('SELECT val FROM data WHERE key=?', key)
    end

    def delete(key)
      @db.transaction do |txn|
        txn.execute('DELETE FROM data WHERE key=?', key)
      end
    end

    private

    def init_db(key_type, value_type)
      @db.execute('CREATE TABLE IF NOT EXISTS data('\
                      "key #{to_sql_type(key_type)} PRIMARY KEY, "\
                      "val #{to_sql_type(value_type)})")
    end

    def to_sql_type(type)
      map = {
        String => 'TEXT',
        Integer => 'INT'
      }
      fail("Unsupported type #{type}") if map[type].nil?
      map[type]
    end
  end
end
