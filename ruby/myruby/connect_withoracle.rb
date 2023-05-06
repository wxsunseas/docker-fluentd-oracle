require 'active_record'
# ActiveRecord::Base.establish_connection(:adapter=>"oracle_enhanced", :database=>"//39.108.50.33:49161/XE", :username=>"ATW2", :password=>"ATW2")
ActiveRecord::Base.establish_connection(:adapter=>"oracle_enhanced", :host=>"39.108.50.33", :port=>"49161", :database=>"xe" , :username=>"ATW2", :password=>"ATW2")

#     host: localhost
#   port: 1521
#   database: xe
#   username: user
#   password: secret
# class  BAFBFDIT < ActiveRecord::Base

# end

class Employee < ActiveRecord::Base
    # specify schema and table name
    self.table_name = "v$sql"
    self.primary_key = "sql_id"
  end
#newclient=T4.new
#newclient.id=16
#newclient.name="3this is a test"
#newclient.save
#a=T4.find(13)
#puts a.id
#puts a.name

#20.upto(30) do |number|
#    new_item=T4.new()
#    new_item.id=number
#    new_item.name="#{number} hello"
#    new_item.save
#end

#a=T4.find(:first,:conditions => ["name=?","20 hello"])
data  =  Employee.where("sql_id = ?", "bmsuwk0uac0jq")

puts(data[0][:sql_fulltext])