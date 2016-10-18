from Resources.ResourceManager import ResourceManager
import xml.etree.ElementTree as ET

marker_types = {
	'1' : ['Epidermal-Epidermal', '#006600'],
	'2' : ['Epidermal-stomata', '#0033ff'],
	'3' : ['Through stomata', '#330066'],
	'4' : ['Intracellular', '#330000'],
	'5' : ['Failed', '#cc0000'],
	'6' : ['No germination', '#cc6600'],
	'7' : ['Single germination', '#9900cc'],
	'8' : ['Dual germination', '#9966ff'],
	'9' : ['Unclear','#663300'],
	'10' : ['Vasculature','#99cc00'],
	'11' : ['No attempt', '#ffcc00'],
	'12' : ['Bottom spore', '#996666']
}

def UploadCellCounterData(filename):
	
	tree = ET.parse(filename)
	root = tree.getroot()

	linewidth = 3
	image_properties = root[0] # Unused
	marker_data = root[1][1:] # Skip first line "Current Marker"

	# Setup Resource Manager handler
	RM = ResourceManager(config_file=".ConfigOptions", debug=True)
	
	# point_map: {name : [x,y,z,color,linewidth]}
	point_map = {}
	
	# Obtain URI from filename
	uri = "http://bisque.iplantcollaborative.org/data_service/00-H3FW4LyS3p8QhENV6LMs2X"
	
	# Iterate through markers
	for marker_type in marker_data:
		current_type = marker_types[marker_type[0].text]
		name = current_type[0]
		color = current_type[1]
		
		print '>>>', name, '| Color:', color
		point_map[name] = []
		markers = marker_type[1:]
		for ind, marker in enumerate(markers):
			x = marker[0].text
			y = marker[1].text
			z = marker[2].text
			print "x:", x,
			print "y:", y,
			print "z:", z
			point_map[name].append([x,y,z,color,linewidth])
	
	RM.add_points(uri, point_map)
	
			
if __name__ == "__main__":
	filename = 'CellCounter_e013SLBp03wB2x20_1505041720rc001.xml'
	UploadCellCounterData(filename)
