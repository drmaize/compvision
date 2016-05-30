
import MySQLdb
import os, logging, uuid, ConfigParser
import numbers

cf = "../.ConfigOptions"

class DBHandler(object):

	def __init__(self, config_file=cf, database=None, debug=False):
		config = ConfigParser.ConfigParser()
		config.read(config_file)

		# Setup logging and debugging for this module
		self.logger = logging.getLogger(__name__)
		self.debug = debug

		# Credentials and session info
		self.username = config.get('mysql', 'username')
		self.password = config.get('mysql', 'password')
		self.host = config.get('mysql', 'host')
		if database is None:
			self.db = config.get('mysql', 'database')
		else:
			self.db = database
		
		
	def _connect(self):
		self.conn = MySQLdb.connect(host=self.host,
					user=self.username,
					passwd=self.password,
					db=self.db)
		return self.conn.cursor()
		
	def insert_into(self, table, values):
		values = ','.join([ "{}".format(value) if isinstance( value,  numbers.Number ) else "'{}'".format(value) for value in values])
		query = "INSERT into " + table + " VALUES (" + values + ");"
		cursor = self._connect()
		try:
			cursor.execute(query)
			self.conn.commit()
		except Exception,e:
			print "Failed: " + query
			print str(e)
			self.conn.rollback()
			
	def search_col(self, table, col, search, mode=1):
		'''
		@mode: '1' = anywhere in string ('%<search_term>%')
			   '2' = prefix ('<search_term>%')
			   '3' = suffix ('%<search_term>')
		'''
		if mode == 1:
			search = "%" + search + "%"
		elif mode == 2:
			search = search + "%"
		elif mode == 3:
			search = "%" + search
			
		query = "SELECT * FROM " + table + " WHERE " + col + " LIKE \'" + search + "\';"
		cursor = self._connect()
		try:
			cursor.execute(query)
			self.conn.commit()
		except Exception,e:
			print "Failed: " + query
			print str(e)
			self.conn.rollback()
			
		return [row for row in cursor.fetchall()]
		#select * from inventory where sample like '013SLB%';
	
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
	
	for table in dbh.get_tables():
		print "Table " + table + ":"
		for col_name in dbh.get_columns(table):
			print "\t" + col_name
	
	#srch = dbh.search_col("inventory", "sample", "013SLB")
	#print srch
