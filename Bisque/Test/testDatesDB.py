import sys,os,requests,re
from Upload.UploadHandler import UploadHandler
from DB.DBHandler import DBHandler

def main():

        uh = UploadHandler(config_file=".ConfigOptions", debug=True)
        dbh = DBHandler(config_file=".ConfigOptions", debug=True)

        table = 'microImage'
        p_key = 'sample'
	
        col = dbh.search_col(table, p_key, '013SLBp01wD1')

	print col
main()
