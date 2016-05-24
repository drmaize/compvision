import sys,os,requests,re
from Upload.UploadHandler import UploadHandler
from DB.DBHandler import DBHandler

def main():

        if len(sys.argv) != 3:
                print "Usage: python UploadFromDB.py <experiment> <path_to_directory>"
        else:
                dataset_name = sys.argv[1]
                path = sys.argv[2]
                files = [f for f in os.listdir(path)
                         if os.path.isfile(os.path.join(path, f)) and not f.startswith('.')]

		uh = UploadHandler(config_file=".ConfigOptions", debug=True)
		dbh = DBHandler(config_file=".ConfigOptions", debug=True)
		
		table = 'microImage'
		p_key = 'sample'
		col_headers = dbh.get_columns(table)

		reg = re.compile('e(.*?)x.._')
		uri_list = []
		for index, f in enumerate(files):
			print "Uploading file: " + str(f) + " (" + str(index+1) + " of " + str(len(files)) + ")"
			matches = reg.match(f)
			col = dbh.search_col(table, p_key, matches.group(1))
			
			print "\n\n========================"
			print path, f
			print len(col), col
			ri = raw_input()

			col = col[0]

			metadata = {}
			for i in range(len(col_headers)): 
				metadata[col_headers[i]] = str(col[i])
			metadata['experiment'] = dataset_name

			#retval = uh.upload_image(str(os.path.join(path, f)), metadata=metadata)
			#uri_list.append((f,retval))
			print ">>>"
			print metadata

			ri = raw_input()

		print uri_list
		with open(dataset_name + "_uris.txt", "w+") as fp:
			for (f,uri) in uri_list:
				print f, uri
				fp.write(f + "\t" + uri + "\n")


        
		
if __name__ == "__main__":
        requests.packages.urllib3.disable_warnings()
        main()

