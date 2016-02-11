from tifffile import TiffFile
import UserDict

class Metadict(UserDict.UserDict):
	
	def __init__(self, filename):
		UserDict.UserDict.__init__(self)
		metadict = {}
		with TiffFile(filename) as tiff:
			for page in tiff:
				for tag in page.tags.values():
					metadict[tag.name] = tag.value
		self.update(metadict)

if __name__ == "__main__":

	md = Metadict("../test/test2.ome.tif")
	print md.keys()



