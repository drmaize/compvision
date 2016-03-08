
import MySQLdb
import os, logging, uuid, ConfigParser
import numbers

config_file = "../.ConfigOptions"

class DBHandler(object):

	def __init__(self, debug=False):		
		config = ConfigParser.ConfigParser()
		config.read(config_file)

		# Setup logging and debugging for this module
		self.logger = logging.getLogger(__name__)
		self.debug = debug

		# Credentials and session info
		self.username = config.get('mysql', 'username')
		self.password = config.get('mysql', 'password')
		self.host = config.get('mysql', 'host')
		self.db = config.get('mysql', 'database')
		
		
	def _connect(self):
		self.conn = MySQLdb.connect(host=self.host,
					user=self.username,
					passwd=self.password,
					db=self.db)
		return self.conn.cursor()
		
	def insert_into(self, table, values, id=False):
		values = ','.join([ "{}".format(value) if isinstance( value,  numbers.Number ) else "'{}'".format(value) for value in values])
		if id:
			values = "{},".format(id) + values
		else:
			values = "NULL," + values
			
		query = "INSERT into " + table + " VALUES (" + values + ");"
		print query
		'''
		cursor = self._connect()
		try:
			x.execute()
			conn.commit()
		except:
			conn.rollback()
		'''
	
	def get_tables(self):
		cursor = self._connect()
		cursor.execute("SHOW TABLES")
		return [table_name for (table_name,) in cursor.fetchall()]
		
		
	def get_columns(self,table):
		cursor = self._connect()
		cursor.execute("SHOW COLUMNS FROM "+table+";")
		return [col_descriptor[0] for col_descriptor in cursor.fetchall()]
		
		
		
if __name__ == "__main__":
	dbh = DBHandler()
	values = [1.0, "Test", "Col2"]
	table = "test_table"
	
	dbh.insert_into(table,values)
	dbh.insert_into(table,values, id=99)
	
	for table in dbh.get_tables():
		print "Table " + table + ":"
		for col_name in dbh.get_columns(table):
			print "\t" + col_name
