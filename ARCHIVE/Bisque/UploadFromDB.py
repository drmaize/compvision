import sys,os,requests,re, time
from Upload.UploadHandler import UploadHandler
from DB.DBHandler import DBHandler


def main():

	if len(sys.argv) != 3:
		print "Usage: python UploadFromDB.py <dataset_name> <path_to_directory>"
	else:
		dataset_name = sys.argv[1]
		path = sys.argv[2]
		files = [f for f in os.listdir(path)
			if os.path.isfile(os.path.join(path, f)) 
			and not f.startswith('.') 
			and not f.startswith('exp')]
			
		if os.path.isfile("retry_files"):
			print "Files that were not uploaded exist... uploading now"
			with open("retry_files.txt", "r+") as fp:
				files = [line.strip() for line in fp]

		uh = UploadHandler(config_file=".ConfigOptions", debug=True)
		dbh = DBHandler(config_file=".ConfigOptions", debug=True)
		
		# Set the MicroImageSet DB info
		microImageSet_table = 'microImageSets'
		microImageSet_key_1 = 'reconstructedImage'
		microImageSet_key_2 = 'imageChannel'
		microImageSet_headers = dbh.get_columns(microImageSet_table)
		reg = re.compile('(e.*?)(.....)\.')
		
		# Set the MicroImage DB info
		microImage_table = 'microImage'
		microImage_key = 'reconstructedImage'
		microImage_headers = dbh.get_columns(microImage_table)
		
		# Set the Inventory DB info
		inventory_table = 'inventory'
		inventory_key = 'sample'
		inventory_headers = dbh.get_columns(inventory_table)
		
		# If the first file doesn't upload correctly, this will control (stop) the flow
		inp = 'n'
		
		for index, f in enumerate(files):
			for retries in range(2):
				try:
					print "Uploading file: " + str(f) + " (" + str(index+1) + " of " + str(len(files)) + ")"
					
					# Search for entry in microImageSet table (unique)
					matches = reg.match(f)
					reconstructedImage = matches.group(1)
					imageChannel = matches.group(2)
					search_dict = {microImageSet_key_1 : reconstructedImage, microImageSet_key_2 : imageChannel}
					row = dbh.search_col(microImageSet_table, search_dict)[0]
					
					# Setup metadata dictionary
					metadata = {}
					metadata['dataset'] = dataset_name
					
					# Insert ONLY image channel and microimagesets_id info from microimagesets table 
					metadata['imageChannel'] = str(row[0])
					metadata['microImageSet_id'] = str(row[2])

					# Search for information in microImage table
					search_dict = {microImage_key : reconstructedImage}
					row = dbh.search_col(microImage_table, search_dict)[0]
					sample = row[1] # Get sample from microImage table
					for i in range(len(microImage_headers)): 
						metadata[microImage_headers[i]] = str(row[i])
					
					# Finally, search for info in inventory table
					search_dict = {inventory_key : sample}
					row = dbh.search_col(inventory_table, search_dict)[0]
					for i in range(len(inventory_headers)): 
						metadata[inventory_headers[i]] = str(row[i])
					
					# Upload file and obtain reval (Bisque URI)
					try:
						retval = uh.upload_image(str(os.path.join(path, f)), metadata=metadata)
						uri = retval[1];
					except:
						print "Error Uploading... trying again in 2 minutes"
						time.sleep(120)
						retval = uh.upload_image(str(os.path.join(path, f)), metadata=metadata)
						uri = retval[1];
					
					print "Bisque URI:", uri
					set_dict = {"bisqueURI":uri}
					where_dict = {microImage_key : reconstructedImage, microImageSet_key_2 : imageChannel}
					dbh.update_entry(microImageSet_table, set_dict, where_dict)
					row = dbh.search_col(microImageSet_table, where_dict)[0]
					print "New entry:", row
					
					print "Update Process Complete!"
					print "========================================"
					print ""
					
				except Exception,e:
					if retries < 1:
						print "=========================="
						print "Error: ", str(e)
						print "Trying one more time..."
						print "=========================="
					else:
						print "=========================="
						print "Dumping remaining files to retry_files and errors to error_dump"
						with open("retry_files","w+") as fp:
							for elem in files[index:]:
								fp.write(elem + "\n")
						with open("error_dump", "w+") as fp:
							fp.write(str(e))
						return

if __name__ == "__main__":
	requests.packages.urllib3.disable_warnings()
	main()
	
	