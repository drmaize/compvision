##################
# System Imports #
##################
import ConfigParser, sys, os

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

colors = {"red" : "#FF0000", 
	"green" : "#00FF00", 
	"blue" : "#0000FF",
	"pink" : "#FF00FF",
	"yellow" : "#FFFF00",
	"white" : "#FFFFFF",
	"black" : "#000000"}

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

	
	def _debug_print(self, s, log="info"):
		if self.debug:
			print s
		if log=="info":
			self.logger.info(s)
		elif log=="error":
			self.logger.error(s)
					
					
	def _postxml(self, uri, xmlstr):
		local_session = self._authenticate()
		if local_session is None:
			self._debug_print('Unable to authenticate session.')
			return None
		else:
			try:
				return local_session.postxml(uri, xmlstr)
			except:
				self._debug_print('Resource URI not found.')
				return None

	def add_tag(self, uri, name, value):
		'''
		Adds a text annotation to a resource
		'''
		xmlstr = '<tag name=\"' + name + '\" value=\"' + str(value) + '\"/>'
		return self._postxml(uri,xmlstr)
				
	def _gob_xml(self, type, vertex_list, color, name, width):
		'''
		Constructs a template gobject xml string
		'''
		xmlstr = '<gobject type=\"' + type + '\" '
		if name:
			xmlstr += 'name=\"' + name + '\" '
		xmlstr += '>\n'
		if color in colors:
			xmlstr += '<tag value=\"' + colors[color] + '\" name=\"color\" />\n'
		elif color[0] == '#':
			xmlstr += '\t<tag value=\"' + color.lower() + '\" name=\"color\" />\n'
		for vertex in vertex_list:
			x = vertex[0]
			y = vertex[1]
			xmlstr += '<vertex x=\"' + str(x) + '\" y=\"' + str(y) + '\" ' 
			if len(vertex) > 2:
				z = vertex[2]
				xmlstr += 'z=\"' + str(z) + '\" ' 
			xmlstr += '/>\n'
		if width:
			xmlstr += "<tag value=\"" + str(width) + "\" name=\"line_width\" />\n"
		xmlstr += "</gobject>"
		return xmlstr
		
	def add_point(self, uri, coords, color="red", name=None, width=None):
		'''
		Adds a point annotation to a resource
		'''
		xmlpoint = self._gob_xml('point', [coords], color, name, width)
		return self._postxml(uri,xmlpoint) 
	
	def add_points(self, uri, point_map):
		'''
		@point_map: {name : [x,y,z,color,linewidth]}
		'''
		print "Uploading all points..."
		for name, data_lines in point_map.iteritems():
			for data in data_lines:
				self.add_point(uri, data[0:3], data[3], name, data[4])

		print "Points Uploaded!"
		
	def add_circle(self, uri, center, radius, color="red", name=None, width=None):
		'''
		Adds a circle annotation to a resource
		'''
		coord_2 = [center[0], center[1]+radius] + center[2:]
		xmlpoint = self._gob_xml('circle', [coords, coord_2], color, name, width)
		return self._postxml(uri,xmlpoint) 
	
	def add_points(self, uri, point_map):
		'''
		@point_map: {name : [x,y,z,color,linewidth]}
		'''
		print "Uploading all circles..."
		for name, data_lines in point_map.iteritems():
			for data in data_lines:
				self.add_point(uri, data[0:3], data[3], name, data[4])
				#xmlstr += self._gob_xml('point', [data[0:3]], data[3], name, data[4])
				#xmlstr += '\n'
		print "Circles Uploaded!"
		
		
	def delete_resource(self, uri):
		local_session = self._authenticate()
		return local_session.deletexml(uri)

if __name__ == "__main__":

	rm = ResourceManager(debug=True)
	uri='http://bisque.iplantcollaborative.org/data_service/00-QH3s9p6QdP3kixQzsAHToZ'

