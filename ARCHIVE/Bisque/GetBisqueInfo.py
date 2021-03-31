import sys
sys.path.insert(0, "/mnt/data27/wisser/drmaize/compvision/Bisque/Includes")

import os,requests,re, time
from itertools import izip
from Upload.UploadHandler import UploadHandler
from DB.DBHandler import DBHandler

def GetBisqueInfo():

	if len(sys.argv) != 2:
		print "Usage: python GetBisqueInfo.py <image_file>"
		
	else:
	
		image_file = sys.argv[1].replace('\'','').encode("utf8")

		# Setup BisqueHandlers
		script_path = os.path.dirname(os.path.realpath(__file__))
		config_path = os.path.join(script_path, ".ConfigOptions")
		uh = UploadHandler(config_file=config_path, debug=True)
		dbh = DBHandler(config_file=config_path, debug=True)
		
		#######################################################
		## 1) Check to see all parameters are included for DB #
		#######################################################
		
		# Set the MicroImageSet DB info
		microImageSet_table = 'microImageSets'
		microImageSet_key = 'microImageSet_id'
		microImageSet_headers = dbh.get_columns(microImageSet_table)
		
		# Get info from filename
		file_basename = os.path.basename(image_file)
		regex = re.compile('(e)(.*?)(p)(.*?)(_.*?)(.....)\.')
		matches = regex.match(file_basename)
		dataset_name = matches.group(2)
		microImage_id = matches.group(1) + matches.group(2) + matches.group(3) + matches.group(4) + matches.group(5)
		reconstructedImage = microImage_id
		imageChannel = matches.group(6)
		microImageSet_id = reconstructedImage + imageChannel
				
		############################################################
		## 4) Search for this entry in the MicroImageSets Database #
		############################################################
		
		# Search for existing entry
		search_dict = {microImageSet_key:microImageSet_id}
		try:
			print "Searching for: ", search_dict
			microImageSet_row = dbh.search_col(microImageSet_table, search_dict)[0]
			print "=> microImageSet entry", microImageSet_row
			return microImageSet_row
		except IndexError:
			# If entry doesn't exist, attempt to add entry
			print ">>> microImageSet entry doesn't exist... returning -1"
			return -1

if __name__ == "__main__":
	requests.packages.urllib3.disable_warnings()
	retval = GetBisqueInfo()
	print retval 