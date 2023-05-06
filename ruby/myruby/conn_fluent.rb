require 'active_record'
#   @base_model = Class.new(ActiveRecord::Base) do
#     # base model doesn't have corresponding phisical table
#     self.abstract_class = true
#   end

#   config = {
#     adapter: "oracle_enhanced",
#     # host: @host,
#     # port: @port,
#     database: "//39.108.50.33:49161/XE",
#     username: "AWT2",
#     password: "ATW2"
#   }

#   @base_model.establish_connection(:adapter=>"oracle_enhanced", :database=>"//39.108.50.33:49161/XE", :username=>"ATW2", :password=>"ATW2")

  class ClassFactory
    def self.create_class(new_class, table, db_connection)
      c = Class.new(ActiveRecord::Base) do
        db = db_connection
        self.table_name = table
      end
  
      Module.const_set new_class, c
      c.establish_connection(config).connection
      c.find(:all)
    end
  end