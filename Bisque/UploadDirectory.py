import sys
from Upload.UploadHandler import UploadHandler

def main():
	
	if len(sys.argv) != 2:
		print "Usage: python UploadDirectory.py <dataset_name> <path_to_directory>"
	else:
		dataset_name = sys.argv[1] 
		path = sys.argv[2]
		files = (file for file in os.listdir(path) 
			 if os.path.isfile(os.path.join(path, file)))

		image_data = []
		for file in files:
			# lookup file metadata
			metadata = None
			image_data.append( (os.path.join(path, file), metadata) )
			
		uh = UploadHandler()
		uh.upload_dataset(dataset_name, image_data)
		
if __name__ == "__main__":
	main()
	

