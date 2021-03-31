import sys, os
from Util.TwitterClient import TwitterClient

if len(sys.argv) < 2:
	print "Usage: python TweetUpdate.py <message>"
else:
	message = " ".join(sys.argv[1:])
	message += " #DrMaize"
	script_path = os.path.dirname(os.path.realpath(__file__))
	config_path = os.path.join(script_path, ".ConfigOptions")
	tclient = TwitterClient(config_file=config_path)
	tclient.tweet(message)