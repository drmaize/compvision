
import sys
from DBHandler import DBHandler
from xlrd import open_workbook


if len(sys.argv) != 3:
	print "Usage: python XLStoSQL.py <xls_file_path> <db_name>"
else:
	xls_file_path = sys.argv[1]
	db_name = sys.argv[2]
	dbh = DBHandler(database=db_name)
	
	book = open_workbook(xls_file_path)
	
	'''
	Table inventory:
	    sample
        experiment
        plate
        well
        tissue
        receivedWhen
        receivedFrom
        disease
        pathogenStrain
        hostAccession
        hpi
        leafNumber
        replication
        treatment
        inventory_comments
	'''
	table = 'inventory'
	sheet = book.sheet_by_index(0)
	for row_index in xrange(1, sheet.nrows):
		row_list = []
		# If sampleID isn't empty
		if str(sheet.cell(row_index, 1).value).encode('ascii') != '':
			for col_index in xrange(1, sheet.ncols-1):
				row_list.append(str(sheet.cell(row_index, col_index).value).encode('ascii'))
			dbh.insert_into(table,row_list)
	
	
	'''
	Table macroImage:
        macroImage_id
        sample
        cameraImage
        macroImage
        macroImage_comments

	'''
	table = 'macroImage'
	sheet = book.sheet_by_index(1)
	for row_index in xrange(1, sheet.nrows):
		row_list = []
		# If sampleID isn't empty
		if str(sheet.cell(row_index, 0).value).encode('ascii') != '':
			for col_index in xrange(0, sheet.ncols-1):
				row_list.append(str(sheet.cell(row_index, col_index).value).encode('ascii'))
			row_list.append('')
			dbh.insert_into(table,row_list)
		
	'''
	Table microImage:
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
	'''
	table = 'microImage'
	sheet = book.sheet_by_index(2)
	for row_index in xrange(1, sheet.nrows):
		row_list = []
		# If sampleID isn't empty
		if str(sheet.cell(row_index, 0).value).encode('ascii') != '':
			for col_index in xrange(0, sheet.ncols):
				row_list.append(str(sheet.cell(row_index, col_index).value).encode('ascii'))
			dbh.insert_into(table,row_list)
	'''
	Table microImageSets:
		reconstructedImage
		imageChannel
		bisqueURI
	'''
	table = 'microImageSets'
	sheet = book.sheet_by_index(3)
	for row_index in xrange(1, sheet.nrows):
		row_list = []
		# If reconstructedImage isn't empty
		if str(sheet.cell(row_index, 0).value).encode('ascii') != '':
			for col_index in xrange(0, sheet.ncols):
				row_list.append(str(sheet.cell(row_index, col_index).value).encode('ascii'))
			dbh.insert_into(table,row_list)
	