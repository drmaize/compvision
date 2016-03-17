import sys,os,requests
from Upload.UploadHandler import UploadHandler

def main():
	
	if len(sys.argv) != 3:
		print "Usage: python UploadDirectory.py <dataset_name> <path_to_directory>"
	else:
		dataset_name = sys.argv[1] 
		path = sys.argv[2]
		files = [f for f in os.listdir(path) 
			 if os.path.isfile(os.path.join(path, f))]
		
		uri_list = []

		uh = UploadHandler(config_file=".ConfigOptions", debug=True)
		for index, f in enumerate(files):
			print "Uploading file: " + str(f) + " (" + str(index+1) + " of " + str(len(files)) + ")"
			retval = uh.upload_image(str(os.path.join(path, f)), metadata={'experimentID':str(dataset_name)})
			uri_list.append(retval)

		print uri_list
if __name__ == "__main__":
	requests.packages.urllib3.disable_warnings()
	main()
	

