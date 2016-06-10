# "/mnt/data27/wisser/drmaize/image_data/e013SLB/microimages/reconstructed/HS/e013SLBp01wA1x20_1506111930rc001.ome.tif"

import sys, os
from DBHandler import DBHandler
from xlrd import open_workbook

db_name = "test_drmaizeIDB"
dbh = DBHandler(database=db_name)

path = "/mnt/data27/wisser/drmaize/image_data/e013SLB/microimages/reconstructed/HS/"
xls_file_path = "/mnt/data27/wisser/drmaize/Bioimage_Metadata.xlsm"
book = open_workbook(xls_file_path)

files = [file for file in os.listdir(path) 
         if os.path.isfile(os.path.join(path, file)) and not f.startswith('.')]


table = 'inventory'
sheet = book.sheet_by_index(0)
for row_index in xrange(1, sheet.nrows):
	row_list = []
	# If sampleID isn't exp 13
	sampleID = str(sheet.cell(row_index, 1).value).encode('ascii')
	if sampleID[:6] == '013SLB':
		for col_index in xrange(1, sheet.ncols-1):
			row_list.append(str(sheet.cell(row_index, col_index).value).encode('ascii'))
		dbh.insert_into(table,row_list)


# Failed: INSERT into microImage VALUES 
# ('013SLBp01wA1','e013SLBp01s1_1412161734_R1_GR1_B1_L201.lsm','e013SLBp01s1_1412161734_R1_GR1_B1_L300.lsm',
# '','','x10y10z22','btlr:c','10X','','NULL');
'''
  microImage_id
	sample
	microImageStart
	microImageStop
	microImage
	microMIP
	imagingDimensions
	imagingDirection
	magnification
	microImage_comments
	tilingStatus
	reconstructedImage
'''

table = 'microImage'
sheet = book.sheet_by_index(2)
for row_index in xrange(1, sheet.nrows):
	row_list = ['NULL']
	# If sampleID isn't exp 13
	sampleID = str(sheet.cell(row_index, 1).value).encode('ascii')
	if sampleID[:6] == '013SLB':
		for col_index in xrange(1, sheet.ncols):
			row_list.append(str(sheet.cell(row_index, col_index).value).encode('ascii'))
		
		
		micro_id = int(float(str(sheet.cell(row_index, 0).value).encode('ascii')))
		
		if  micro_id < 2146 and micro_id > 2073:
			for file in files:
				fn = os.path.basename(file)
				if fn[1:13] == sampleID:
					row_list.append(fn[:27])
					break
		else:
			row_list.append('NULL')
		#print row_list
		dbh.insert_into(table,row_list)

	
	
table = 'microImageSets'

for file in files:

	row_list = ['NULL']	
	fn = os.path.basename(file)
	row_list.append(fn[:27])
	row_list.append(fn[27:32])
	row_list.append('NULL')
	row_list.append('NULL')
	row_list.append('NULL')
	#print row_list
	dbh.insert_into(table,row_list)
