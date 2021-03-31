
import MySQLdb
import os, logging, uuid, ConfigParser
import numbers

class DBHandler(object):

	def __init__(self, config_file, database=None, debug=False):
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
	
		values = ','.join([ "{}".format(value) if isinstance(value,  numbers.Number) or value.lower()=='null' else "'{}'".format(value) for value in values])
		query = "INSERT into " + table + " VALUES (" + values + ");"
		
		cursor = self._connect()
		try:
			cursor.execute(query)
			self.conn.commit()
		except Exception,e:
			print "Failed: " + query
			print str(e)
			self.conn.rollback()
			
	def update_entry(self, table, set_dict, where_dict):
	
		'''
		UPDATE Customers
		SET ContactName='Alfred Schmidt', City='Hamburg'
		WHERE CustomerName='Alfreds Futterkiste';
		'''
		
		set_string = "SET "
		second = False
		for k,value in set_dict.iteritems():
			set_string += k + "="
			if second:
				set_string += ','
			if isinstance( value,  numbers.Number ):
				set_string += "{}".format(value) 
			else:
				set_string += "'{}'".format(value)
			second = True
		
		where_string = "WHERE"
		second = False;
		for col, search in where_dict.iteritems():
			if second:
				where_string += ' AND';
			where_string += ' ' + col + " LIKE \'" + search + "\'"
			second = True;
		
		query = "UPDATE " + str(table) + " " + set_string + " " + where_string + ";"
		
		cursor = self._connect()
		try:
			cursor.execute(query)
			self.conn.commit()
		except Exception,e:
			print "Failed: " + query
			print str(e)
			self.conn.rollback()
			
		return [row for row in cursor.fetchall()]

	def search_col(self, table, searches, mode=1):
		'''
		@mode: '1' = anywhere in string ('%<search_term>%')
			   '2' = prefix ('<search_term>%')
			   '3' = suffix ('%<search_term>')
			   '4' = exact ('<search_term>')
		'''
		
		query = "SELECT * FROM " + table + " WHERE" 
		second = False;
		for col, search in searches.iteritems():
			if second:
				query += ' AND ';
			if mode == 1:
				search_str = "%" + search + "%"
			elif mode == 2:
				search_str = search + "%"
			elif mode == 3:
				search_str = "%" + search
			elif mode == 4:
				search_str = search
			query += ' ' + col + " LIKE \'" + search_str + "\'"
			second = True;
			
		query += ';'
			
		cursor = self._connect()
		try:
			cursor.execute(query)
			self.conn.commit()
		except Exception,e:
			print "Failed: " + query
			print str(e)
			self.conn.rollback()
			
		return [row for row in cursor.fetchall()]

	
	def get_tables(self):
		cursor = self._connect()
		cursor.execute("SHOW TABLES")
		return [table_name for (table_name,) in cursor.fetchall()]
		
		
	def get_columns(self,table):
		cursor = self._connect()
		cursor.execute("SHOW COLUMNS FROM "+table+";")
		return [col_descriptor[0] for col_descriptor in cursor.fetchall()]
		
		
		
if __name__ == "__main__":
	script_path = os.path.dirname(os.path.realpath(__file__))
	config_path = os.path.join(script_path, "..", ".ConfigOptions")
	dbh = DBHandler(config_file=config_path)
	
	for table in dbh.get_tables():
		print "Table " + table + ":"
		for col_name in dbh.get_columns(table):
			print "\t" + col_name
	
	srch = dbh.search_col("inventory", {"sample":"013SLB"})
	print srch
