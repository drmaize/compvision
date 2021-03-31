##################
# System imports #
##################
import os, sys, logging, ConfigParser

###################
# Package imports #
###################
sys.path.insert(0, '../')
sys.path.insert(0, '../Includes')

##################
# Twitter import #
##################
from twitter import *

#######################
# Path to config file #
#######################
cf = "../.ConfigOptions"

class TwitterClient(object):

	def __init__(self, config_file=cf, debug=False):
		config = ConfigParser.ConfigParser()
		config.read(config_file)
		
		# Setup logging and debugging for this module
		self.logger = logging.getLogger(__name__)
		self.debug = debug
		
		# Credentials and session info
		self.username = config.get('twitter', 'username').encode("utf8")
		self.access_token = config.get('twitter', 'access_token').encode("utf8")
		self.access_token_secret = config.get('twitter', 'access_token_secret').encode("utf8")
		self.api_key = config.get('twitter', 'api_key').encode("utf8")
		self.api_secret = config.get('twitter', 'api_secret').encode("utf8")


	def tweet(self, message):
		t = Twitter(auth=OAuth(self.access_token, self.access_token_secret, self.api_key, self.api_secret))
		t.statuses.update(status=message)

if __name__ == "__main__":
	
	tclient = TwitterClient()
	tclient.tweet("Testing the TwitterClient for DrMaize! #DrMaize")
	


