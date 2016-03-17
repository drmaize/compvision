##############
# Bisque API #
##############
from bqapi.comm import *
from bqapi import BQSession, BQDataset, BQImage, BQFactory
from bqapi.bqfeature import *
from bqapi.util import *

#########################
# Url and XML utilities #
#########################
import urlparse
import xml.etree.ElementTree as ElementTree

cf = "../.ConfigOptions"

class ResourceManager(object):

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