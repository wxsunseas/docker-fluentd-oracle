# connect.rb: Create connections to Oracle
# require 'config.rb'
require 'oci8'

begin
	# login as normal user
	conn = OCI8.new("ATW2", "ATW2", "//39.108.50.33:49161/XE")
	puts "login as normal user succeeded."


	# parse and exec the statement
	cursor = conn.parse("select * from BAFBFDIT")
	cursor.exec

	# output column names
	puts cursor.getColNames.join(",")

	# output rows
	while r = cursor.fetch 
		puts r.join(",")
	end

	# close the cursor and logoff
	cursor.close
	conn.logoff
	puts "logoff succeeded."	
	puts

	# login as DBA
	# conn2 = OCI8.new('sys', 'oracle', DB_SERVER, :SYSDBA)
	# puts "login with DBA privilege succeeded."
	# conn2.logoff
	# puts "logoff succeeded."

rescue OCIError
	# display the error message
	puts "OCIError occured!"
	puts "Code: " + $!.code.to_s
	puts "Desc: " + $!.message

end

puts '-'*80