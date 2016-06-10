import sys,os,requests,re
from itertools import izip
from Upload.UploadHandler import UploadHandler
from DB.DBHandler import DBHandler

# For iterating over pairs of elements
def pairwise(iterable):
    "s -> (s0, s1), (s2, s3), (s4, s5), ..."
    a = iter(iterable)
    return izip(a, a)

def UploadToBisque():

	if len(sys.argv) < 3:
		print "Usage: python UploadToBisque.py <image_file> <dataset_name> [<meta_tag> <meta_data> ...]"
	else:
		image_file = sys.argv[1]
		dataset_name = sys.argv[2]
		inp_metadata = sys.argv[3:]
		
		if len(inp_metadata) % 2 != 0:
			print "Error: Metadata needs to be passed in pairs (%2 == 0)"
			return
		
		print "\nPreparing to upload file", image_file
		
		# Setup metadict
		metadata = {"dataset":dataset_name}
		for tag, data in pairwise(inp_metadata):
			metadata[str(tag)] = str(data)
		print metadata
		
		# Setup BisqueHandlers
		uh = UploadHandler(config_file=".ConfigOptions", debug=True)
		dbh = DBHandler(config_file=".ConfigOptions", debug=True)
		
		#######################################################
		## 1) Search for this entry in the Inventory Database #
		#######################################################
		
		# Set the Inventory DB info
		inventory_table = 'inventory'
		inventory_key = 'sample'
		inventory_headers = dbh.get_columns(inventory_table)
		
		search_dict = {inventory_key:metadata[inventory_key]}
		try:
			inventory_row = dbh.search_col(inventory_table, search_dict)[0]
		except IndexError:
			print ":: inventory entry doesn't exist... adding"
		
		########################################################
		## 2) Search for this entry in the MicroImage Database #
		########################################################
		
		# Set the MicroImage DB info
		microImage_table = 'microImage'
		microImage_key = 'microImage_id'
		microImage_headers = dbh.get_columns(microImage_table)
		
		search_dict = {microImage_key:metadata[microImage_key]}
		try:
			microImage_row = dbh.search_col(microImage_table, search_dict)[0]
		except IndexError:
			print ":: microImage entry doesn't exist... adding"
		
		############################################################
		## 3) Search for this entry in the MicroImageSets Database #
		############################################################
		
		# Set the MicroImageSet DB info
		microImageSet_table = 'microImageSets'
		microImageSet_key_1 = 'reconstructedImage'
		microImageSet_key_2 = 'imageChannel'
		microImageSet_headers = dbh.get_columns(microImageSet_table)
		
		# Get info from filename
		file_basename = os.path.basename(image_file)
		regex = re.compile('(e.*?)(.....)\.')
		matches = regex.match(file_basename)
		reconstructedImage = matches.group(1)
		imageChannel = matches.group(2)
		
		# Gather MicroImageSets Row
		search_dict = {microImageSet_key_1 : reconstructedImage, microImageSet_key_2 : imageChannel}
		try:
			microImageSet_row = dbh.search_col(microImageSet_table, search_dict)[0]
		except IndexError:
			print ":: microImageSet entry doesn't exist... adding"

		# Upload file and obtain reval (Bisque URI)
		try:
			print "Uploading File", image_file
			#retval = uh.upload_image(image_file, metadata=metadata)
			#uri = retval[1];
		except:
			print ":: Could not upload... trying again..."

if __name__ == "__main__":
	requests.packages.urllib3.disable_warnings()
	UploadToBisque()