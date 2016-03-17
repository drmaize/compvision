##################
# System imports #
##################
import os, logging, uuid, ConfigParser
import sys, StringIO, multiprocessing
from multiprocessing import Pool, cpu_count
from multiprocessing.pool import ApplyResult

##############
# Bisque API #
##############
from bqapi.comm import *
from bqapi import BQSession, BQDataset, BQImage, BQFactory
from bqapi.bqfeature import *
from bqapi.util import *

###################
# Package imports #
###################
sys.path.insert(0, '../')
sys.path.insert(0, '/home/wtreible/.local/lib/python2.7/site-packages/')
sys.path.insert(0, '/usr/lib64/python2.7/site-packages/Cython-0.20-py2.7-linux-x86_64.egg')
import Util.Pickle

#########################
# Url and XML utilities #
#########################
import urlparse
import xml.etree.ElementTree as ElementTree

#######################
# Path to config file #
#######################
cf = "../.ConfigOptions"

class UploadHandler(object):

	def __init__(self, config_file=cf, debug=False):
		config = ConfigParser.ConfigParser()
		config.read(config_file)
		
		# Setup logging and debugging for this module
		self.logger = logging.getLogger(__name__)
		self.debug = debug
		
		# Credentials and session info
		self.username = config.get('credentials', 'username')
		self.password = config.get('credentials', 'password')
		self.bisque_root = config.get('urls', 'bisque_root')

	def _authenticate(self, attempts=25):
		'''
		Attempts to authenticate N times
		
		@attempts(optional): number of attempts to authenticate
		'''
		for i in range(attempts):
			s = BQSession().init_cas(self.username, self.password, bisque_root=self.bisque_root)
			try:
				if s._check_session():
					self._debug_print('Authenticated successfully!')
					return s
			except:
				self._debug_print('Unable to authenticate... trying again')
				pass
			time.sleep(30)
			
		self._debug_print('Unable to authenticate.', 'error')
		return None

	def _xml_builder(resource_name, metadata, resource_type="image"):
		xmlstr = "<resource type=\"" + resource_type + "\">\n"
		for key, value in metadata.iteritems():
			xmlstr += "\t<tag name=\"" + key + "\" value=\"" + value + "\" />\n"
		return xmlstr + "</resource>"

	def _debug_print(self, s, log_type="info"):
		if self.debug:
			print s
		if log=="info":
			self.logger.info(s)
		elif log=="error":
			self.logger.error(s)

	def upload_image(self, filename, metadata=None):
		'''
		Posts image and returns the result

		@filename: path to image to be uploaded
		@metadata(optional): associated metadata dictionary (k,v pairs)
		'''
		local_session = self._authenticate()
		'''
		if local_session is None:
			time.sleep(600)
			local_session = self._authenticate()
		else:
			return None
		'''	
		try:
			if metadata:
				xmlstr = self._xml_builder(metadata)
				outxml = local_session.postblob(filename=filename, xml=xmlstr)
			else:
				outxml = local_session.postblob(filename=filename)	
		except AttributeError:
			self._debug_print('Failed to post file ' + filename, 'error')
			return None
			
		self._debug_print(filename + ' posted')	

		xmlet  = local_session.factory.string2etree (outxml)
		if xmlet.tag == 'resource' and xmlet.get ('type') == 'uploaded':
			self._debug_print('Successful upload of ' + filename)
			image = local_session.factory.from_etree(xmlet[0])
			return (image.name, image.uri)
		else:
			self._debug_print('Unsuccessful upload of ' + filename, log="error")
			return None		
			
	def _upload_image_helper(self, args):
		'''
		Wrapper for expanding arguments to allow async uploads 
		'''
		return self.upload_image(*args)
			
	def upload_dataset(self, dataset_name, image_data, num_threads=4):
		'''
		Uploads multiple images and groups them into a dataset via threading
		
		@dataset_name: name of the dataset
		@image_data: list of pairs of (filename, metadata) input
		'''

		pool = multiprocessing.Pool(num_threads)
		result = pool.map_async(self._upload_image_helper, [(image[0], image[1]) for image in image_data] )
		
		# OLD Method of async
		#async_results = [ pool.apply_async(self.upload_image, (idata[0],idata[1])) for idata in image_data ]
		#print async_results
		#map(ApplyResult.wait, async_results)
		#ds_list = [r.get() for r in async_results]
		
		while not result.ready():
			self._debug_print("Chunks Remaining: >={}".format(result._number_left))
			time.sleep(30)
		
		# Build dataset
		ds_list = result.get()
		pool.close()
		
		self._debug_print('Dataset ' + dataset_name + ' contans '+ str(len(ds_list)) + ' element(s)')
		dataset = BQDataset (name=dataset_name)
		dataset.value = [ (uri, 'object') for image_name, uri in ds_list ]
		
		# Refresh authentication in cases of long uploads
		local_session = self._authenticate()
		if local_session.save(dataset):
			self._debug_print('Dataset ' + dataset_name + ' uploaded successfully!')
		else:
			self._debug_print('Dataset ' + dataset_name + ' failed to upload', log="error")
			
		return ds_list
			
	def _depr_upload_dataset(self, dataset_name, image_data):
		'''
		DEPRECATED
		
		Uploads multiple images and groups them into a dataset

		@dataset_name: name of the dataset
		@image_data: list of pairs of (filename, metadata) input
		'''
		
		ds_list = []
		for filename, metadata in image_data:
			image = self.upload_image(filename=filename, metadata=metadata)
			if image is not None:
				ds_list.append((image.name, image.uri))
		self._debug_print('Dataset ' + dataset_name + ' contans '+ str(len(ds_list)) + ' element(s)')
		
		dataset = BQDataset (name=dataset_name)
		dataset.value = [ (uri, 'object') for image_name, uri in ds_list ]
		self.session = self._authenticate(self.bqs)
		if self.session.save(dataset):
			self.logger.info('Dataset ' + dataset_name + ' uploaded successfully!')
			self._debug_print('Dataset ' + dataset_name + ' uploaded successfully!')
		else:
			self.logger.error('Dataset ' + dataset_name + ' failed to upload')
			self._debug_print('Dataset ' + dataset_name + ' failed to upload')

if __name__ == "__main__":
	
	uh = UploadHandler(debug=True)
	'''
	dataset_name = "test"
	test_image = '../test/test.jpg'
	test_image2 = '../test/test2.ome.tif'
	metadata = {"item1" : "description1", "item2":"description2"}
	image_data = [ (test_image, metadata) , (test_image2, metadata) ]
	'''
	'''	
	dataset_name = "exp019SLB"
	path = "/mnt/data27/wisser/drmaize/image_data/e019SLB/microimages/reconstructed/HS/"
	files = (file for file in os.listdir(path) 
         if os.path.isfile(os.path.join(path, file)))
	
	image_data = []
	for file in files:
		image_data.append( (os.path.join(path, file), None) )

	
	
	print image_data
	
	# print "uh.upload(dataset_name, image_data)"
	# uh.upload_image(test_image, metadata)
	
	uh.upload_dataset(dataset_name, image_data)
	'''
	uh.upload_image("/home/wtreible/upload/e013SLBp01wA1x20_1506111930rc001.ome.tif", {"experimentID":"e013SLB"})


