require 'mongo'

module DBConn
  include Mongo
  def self.getdb(dbname)
    conn = Connection.new
    db = conn.db(dbname)
  end
end
