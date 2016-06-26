import os
import re
import time
import collections

import numpy as np
import scipy as sp
from scipy import ndimage, signal, stats, spatial
import matplotlib.pyplot as plt
import joblib
import scipy
import scipy.stats
from skimage import morphology
import javabridge
import bioformats
import scipy.misc
import tempfile
import contextlib
import sys
import warnings
import utils
from collections import OrderedDict
import csv

#############
# # Globals ##
#############

# results_path = 'results/segmentationfungus'
results_path = 'wtreible_results/segmentationfungus'

###########
# # Begin ##
###########

@contextlib.contextmanager
def empty(shape, dtype):
	filename = os.tempnam('/dev/shm')
	a = np.memmap(filename, mode='w+', shape=shape, dtype=dtype)
	try:
		yield a
		a.flush()
		if sys.getrefcount(a) > 2:
			warnings.warn('{} references to memory mapped file still exist'.format(sys.getrefcount(a) - 2))
	finally:
		del a
		os.remove(filename)		
		
@contextlib.contextmanager
def full(shape, fill_value, dtype):
	with empty(shape, dtype) as a:
		try:
			a[...] = fill_value
			yield a
		finally:
			del a
			
def zeros(shape, dtype):
	return full(shape, 0, dtype)

def ones(shape, dtype):
	return full(shape, 1, dtype)

def fromarray(a):
	return full(a.shape, a, a.dtype)




def hyst(lo, hi, structure=None):
	labels = ndimage.label(lo, structure=structure)
	labs = np.unique(labels[0][hi])
	labs = labs[labs > 0]
	
# 	 msk = np.zeros(labels[0].shape, bool)	
	labels = np.array(labels[0])		
	with zeros(labels.shape, bool) as msk:	
		joblib.Parallel(n_jobs=-1,)(joblib.delayed(utils.set_msk)(msk, labels, l) for l in labs)		
		msk = np.copy(msk)
	
	return msk


def hesseig(im, res, sz, nstds, orthstep, nrm=None):
	d2dx2 = get_hessian_kernels(res, sz, nstds, orthstep)
	if nrm is not None:
		d2dx2 = list(d2dx2[i] / np.abs(d2dx2[i]).sum() * nrm[i] for i in range(len(d2dx2)))

	pad = tuple((p, p) for p in np.max(list(k.shape for k in d2dx2), 0) / 2)
	im_pad = np.pad(im, pad, 'edge').astype(float)

# 	 retval = np.zeros((len(d2dx2),) + im_pad.shape)
	im_pad = np.array(im_pad)
	
	with empty((len(d2dx2),) + im_pad.shape, float) as retval:
		joblib.Parallel(n_jobs=-1,)(
			joblib.delayed(utils.add_out_arg(signal.fftconvolve))(im_pad, k, 'same', out=retval[i])
			for i, k in enumerate(d2dx2))
		retval = np.copy(retval)
	
	d2dx2 = np.empty((len(res),) * 2 + im.shape)
	for ind, (i, j) in enumerate(np.transpose(np.triu_indices(len(res)))):
		d2dx2[i, j] = d2dx2[j, i] = utils.unpad(retval[ind], pad)

	# eigen
	axes = range(len(res) + 2)
	d2dx2 = np.transpose(d2dx2, axes[2:] + axes[:2])

# 	 retval = np.zeros(d2dx2.shape[:-1])
	with empty(d2dx2.shape[:-1], float) as retval:
		joblib.Parallel(n_jobs=-1,)(
			joblib.delayed(utils.add_out_arg(np.linalg.eigvalsh))(d2dx2[i], out=retval[i])
			for i in range(len(d2dx2)))	
		retval = np.concatenate(list(a[None, ...] for a in retval))

	return retval


def get_hessian_kernels(resolution, size, num_stds, ortho_step_size):
	assert np.all(np.asarray(size) > 1.)
	dd = []
	for dx in np.transpose(np.triu_indices(len(resolution))):
		order = [np.count_nonzero(dx == i) for i in range(len(resolution))]
		sigma = np.sum(
			(np.arange(len(resolution), dtype=float) != i) * (ortho_step_size * o)
			for i, o in enumerate(order))
		sigma += (size / 2.) ** 2 - .5 ** 2
		sigma *= (np.min(resolution) / resolution) ** 2
		sigma = np.sqrt(sigma)
		scale = (size / 2.) ** 2 - .5 ** 2
		scale *= (np.min(resolution) / resolution) ** 2
		k = utils.gaussian_differentiation_kernel(sigma, num_stds, order, resolution, scale)
		dd.append(k)
	return dd


def scanal(pth, npz_name, im, immsk, sizes, nstds, orthstep, res):
	print 'scanal'
	data = {}

	nrm = list(np.abs(n).sum() for n in get_hessian_kernels(res, 50., nstds, orthstep))
	scspace = []
	for sz in sizes:
		print sz
		d2dx2 = hesseig(im, res, sz, nstds, orthstep, nrm)
		d2dx2.sort(d2dx2.ndim - 1)
		scspace.append(d2dx2.astype(np.float32))
	scspace = np.concatenate([sc[None, ...] for sc in scspace], 0)
	scspace *= -1
	scspace[scspace < 1e-6] = 0
	scspace[..., ~immsk, :] = 0
	scspace = (scipy.stats.gmean(1 + scspace, 0) - 1) ** .5

	lne, crn = scspace[..., 0], scspace[..., 1]
	
	data['crn'] = crn
	data['lne'] = lne
	
	if os.path.isfile(os.path.join(pth, results_path, npz_name)):
		npz_cache = utils.file_cache(os.path.join(pth, results_path, npz_name), '/tmp/drmaize/')
	else:
		npz_cache = os.path.join(pth, results_path, npz_name)
		np.savez_compressed(os.path.join(pth, results_path, npz_name), **data)
	with np.load(npz_cache, 'r') as old_data:
		old_data = dict(old_data)

	old_data.update(data)
	data = old_data
	np.savez_compressed(os.path.join(pth, results_path, npz_name), **data)

	print npz_name
	print npz_cache


def segment(pth, fname, npz_name, exp_re, immsk):
	print "segment"
	data = {}

	npz_cache = utils.file_cache(os.path.join(pth, results_path, npz_name), '/tmp/drmaize/')
	with np.load(npz_cache, 'r') as old_data:
		crn = old_data['crn']
		lne = old_data['lne']

	m = re.match(exp_re, fname)
	print m.group(3)
# 	 if m.group(3) == '01':
# 		 # 12 HPI
# 		 cmsk = 2.25, 7.5
# 		 lmsk = 3.75
# 	 elif m.group(3) == '02':
# 		 # 24 HPI
# 		 cmsk = 2., 5.25
# 		 lmsk = 2.75
# 	 elif m.group(3) == '03':
# 		 # 48 HPI
# 		 cmsk = 1.5, 5.
# 		 lmsk = 2.25
# 	 else:
# 		 raise Exception

	# TODO these thresholds don't work for all images
	cmsk = np.log(crn[crn > 1e-6]).mean() + 4.0 * np.log(crn[crn > 1e-6]).std(),  # 1.5, 4.5
	lmsk = np.log(lne[lne > 1e-6]).mean() + 3.5 * np.log(lne[lne > 1e-6]).std()  # 2.25

	crn = (crn > cmsk[0])  # | (lne > cmsk[1])
	lne = (lne > lmsk)
	seg = hyst(lne, crn, np.ones((3, 3), bool))
	seg[~immsk] = 0
	
	data['seg'] = seg
	
	npz_cache = utils.file_cache(os.path.join(pth, results_path, npz_name), '/tmp/drmaize/')
	with np.load(npz_cache, 'r') as old_data:
		old_data = dict(old_data)
		old_data.update(data)
		data = old_data
		np.savez_compressed(os.path.join(pth, results_path, npz_name), **data)

	print npz_name
	print npz_cache	


def skeleton(pth, npz_name, immsk):
	print 'skeleton'
	data = {}

	npz_cache = utils.file_cache(os.path.join(pth, results_path, npz_name), '/tmp/drmaize/')
	with np.load(npz_cache, 'r') as old_data:
		seg = old_data['seg']

	skel, dist = morphology.medial_axis(seg, return_distance=True)
	node, edge, leaf = (ndimage.label(g, np.ones((3, 3), bool))[0] for g in utils.skel2graph(skel))

	trim_edge = (edge != 0) & ~(morphology.binary_dilation(node != 0, np.ones((3, 3), bool)) != 0)
	trim_edge = ndimage.label(trim_edge, np.ones((3, 3), bool))[0]

	leaf_edge_vals = morphology.binary_dilation(leaf != 0, np.ones((3, 3), bool)) != 0
	leaf_edge_vals = np.unique(trim_edge[leaf_edge_vals])
	leaf_edge_vals = leaf_edge_vals[leaf_edge_vals > 0]
	leaf_edge = leaf != 0

	trim_edge = np.array(trim_edge)
	with fromarray(leaf_edge) as leaf_edge:
		joblib.Parallel(n_jobs=-1)(
			joblib.delayed(utils.set_msk)(leaf_edge, trim_edge, l) for l in leaf_edge_vals)
		leaf_edge = np.copy(leaf_edge)
		
	leaf_edge[(morphology.binary_dilation(leaf_edge, np.ones((3, 3), bool)) != 0) & (edge != 0)] = True
	leaf_edge = ndimage.label(leaf_edge, np.ones((3, 3), bool))[0]

	leaf_edge_node = morphology.binary_dilation(leaf_edge != 0, np.ones((3, 3), bool)) != 0
	leaf_edge_node = ((node != 0) & leaf_edge_node) | leaf_edge
	leaf_edge_node = ndimage.label(leaf_edge_node, np.ones((3, 3), bool))[0]

	cand_node = leaf_edge_node * (node != 0)
	cand_node = cand_node.nonzero()
	cand_node = np.transpose((leaf_edge_node[cand_node],) + cand_node + (2 * dist[cand_node],))

	cand_leaf = leaf_edge_node * (leaf != 0)
	cand_leaf = cand_leaf.nonzero()
	cand_leaf = np.transpose((leaf_edge_node[cand_leaf],) + cand_leaf)

	if len(cand_node) > 0 and len(cand_leaf) > 0:
		cand_leaf = np.array(cand_leaf)
		cand_node = np.array(cand_node)
		pruned = joblib.Parallel(n_jobs=-1)(
			joblib.delayed(prune_leaves)(cand_leaf, cand_node, j) for j in np.unique(cand_node[:, 0]))

		pruned_ind = []
		for p in pruned:
			pruned_ind.extend(p)
		pruned_ind = tuple(np.transpose(pruned_ind))

		pruned = ~skel

		pruned = np.array(pruned)
		leaf_edge = np.array(leaf_edge)
		joblib.Parallel(n_jobs=1, max_nbytes=None)(
			joblib.delayed(utils.set_msk)(pruned, leaf_edge, l) for l in np.unique(leaf_edge[pruned_ind]))

		pruned = ~pruned
		pruned[~immsk] = False
	else:
		pruned = np.zeros_like(skel)

	data['pruned'] = skel & ~pruned
	data['skel'] = pruned

	npz_cache = utils.file_cache(os.path.join(pth, results_path, npz_name), '/tmp/drmaize/')
	with np.load(npz_cache, 'r') as old_data:
		old_data = dict(old_data)
		old_data.update(data)
		data = old_data
		np.savez_compressed(os.path.join(pth, results_path, npz_name), **data)

	print npz_name
	print npz_cache


def pipeline(experiment):
	# TODO extract function for selecting filenames
	
	'/home/rhein/mnt/drmaize/image_data/e013SLB/microimages/reconstructed/HS'
	'e013SLBp01wA1x20_1506111930rc001.ome.tif'
	'/mnt/data27/wisser/drmaize/image_data/'
 
	exp_re = 'e(\d{3})(SLB|NLB)p(\d{2})w([A-D])([1-6])x20_(\d*)rf001\.ome\.tif'
	# data_dir = '/home/rhein/mnt/drmaize/image_data/'  
    data_dir = '/mnt/data27/wisser/drmaize/image_data'
	sub_dir = 'microimages/reconstructed/HS'
	
	
	exp = experiment
	if not os.path.isdir(os.path.join(data_dir, exp, sub_dir)):
		print "Experiment doesn't exist; exiting..."
		return
		
	sizes = .5 + 2 ** np.arange(4)
	nstds = 4.
	orthstep = 0.5

	fnames = []
	for f in sorted(os.listdir(os.path.join(data_dir, exp, sub_dir))):
		m = re.match(exp_re, f)
		if m:
			print m.group(6)
			fnames.append(os.path.join(data_dir, exp, sub_dir, f))
			print f
			
# 			 if int(m.group(3)) == 1:
# 				 if 1 <= int(m.group(5)) <= 3:
# 					 if m.group(6) == '1506111930':
# 						 fnames.append(os.path.join(data_dir, exp, sub_dir, f))
# 						 print f
# 				 if 4 <= int(m.group(5)) <= 6:
# 					 if m.group(6) == '1506121515':
# 						 fnames.append(os.path.join(data_dir, exp, sub_dir, f))
# 						 print f
# 			 elif int(m.group(3)) == 2:
# 				 if 1 <= int(m.group(5)) <= 3:
# 					 if m.group(6) == '1506121700':
# 						 fnames.append(os.path.join(data_dir, exp, sub_dir, f))
# 						 print f
# 				 if 4 <= int(m.group(5)) <= 6:
# 					 if m.group(6) == '1506221400':
# 						 fnames.append(os.path.join(data_dir, exp, sub_dir, f))
# 						 print f
# 			 elif int(m.group(3)) == 3:
# 				 if 1 <= int(m.group(5)) <= 3:
# 					 if m.group(6) == '1505041720':
# 						 fnames.append(os.path.join(data_dir, exp, sub_dir, f))
# 						 print f
# 				 if 4 <= int(m.group(5)) <= 6:
# 					 if m.group(6) == '1508062130':
# 						 fnames.append(os.path.join(data_dir, exp, sub_dir, f))
# 						 print f
	
	seed = time.time()
	print 'seed', seed
	
	metrics = []

	for fname in utils.shuffle(fnames, 0xDeadBeef):
		print 'filename', fname		
	
		pth, fname = os.path.split(fname)
		if os.path.isfile(os.path.join(pth, 'MIP', fname)):
			cache_fname = utils.file_cache(os.path.join(pth, 'MIP', fname), '/tmp/drmaize')
			im = ndimage.imread(cache_fname)
		else:
			cache_fname = utils.file_cache(os.path.join(pth, fname), '/tmp/drmaize')
			im = utils.get_tif(cache_fname)
			im = np.max(im, 0)
			scipy.misc.imsave(os.path.join(pth, 'MIP', fname), im)
		print 'cache filename', cache_fname		

# 		 cache_fname = drmaize.utils.file_cache(os.path.join(pth, fname), '/tmp/drmaize/')
# 		 res = utils.get_tif_res(cache_fname)
		res = np.array((1.,) * 3)
		print 'physical resolution', res
		res = res[1:]
		res = res / np.min(res)

		npz_name = '{}.npz'.format(os.path.splitext(os.path.splitext(fname)[0])[0])
		print npz_name

		im = im.astype(float)

		# mask generation
		# TODO insert mask into cache file
		immsk = im > 4

		scanal(pth, npz_name, im, immsk, sizes, nstds, orthstep, res)
		segment(pth, fname, npz_name, exp_re, immsk)
		skeleton(pth, npz_name, immsk)
		
		npz_cache = utils.file_cache(os.path.join(pth, results_path, npz_name), '/tmp/drmaize/')
		with np.load(npz_cache, 'r') as data:
			data = dict(data)
						
		seg = data['seg']
		skel, dist = morphology.medial_axis(seg, return_distance=True)
		node, edge, leaf = (ndimage.label(g, np.ones((3, 3), bool))[0] for g in utils.skel2graph(skel))

		dist = dist * 2.6240291219148313
		
# 		 exp_re = 'exp(\d{3})(SLB|NLB)p(\d{2})w([A-D])([1-6])(\d*)rf002\.ome\.tif'
		m = re.match(exp_re, fname)
		met_row = OrderedDict()
		met_row['experiment'] = m.group(1)
		met_row['disease'] = m.group(2)
		met_row['plate'] = m.group(3)
		met_row['well_row'] = m.group(4)
		met_row['well_col'] = m.group(5)
		met_row['timestamp'] = m.group(6)
		
		met_row['host'] = np.count_nonzero(immsk)
		met_row['segmentation'] = np.count_nonzero(seg)
		
		met_row['width_mean'] = np.mean(dist[seg > 0].flat)
		met_row['width_median'] = np.median(dist[seg > 0].flat)
		met_row['width_variance'] = np.var(dist[seg > 0].flat)
		met_row['width_skewness'] = stats.skew(dist[seg > 0].flat)
		met_row['width_kurtosis'] = stats.kurtosis(dist[seg > 0].flat)
		
		met_row['leaf'] = np.count_nonzero(leaf)
		met_row['edge'] = np.count_nonzero(edge)
		met_row['node'] = np.count_nonzero(node)
	
			
# 		 fname = os.path.join(pth, fname)
# 		 head, tail = os.path.split(fname)
# 		 tail = tail.replace('rf001.ome.tif', '_topsurface_optimized1.txt')
# 		 surf = os.path.join(head, 'surfacemap', tail)
# 		 cache_fname = utils.file_cache(surf, '/tmp/drmaize')
# 		 surf = np.loadtxt(cache_fname, np.float32, delimiter=',')
# 
# 		 fname = os.path.join(pth, fname)
# 		 tif = fname.replace('rf', 'rl')
# 		 cache_fname = utils.file_cache(tif, '/tmp/drmaize')
# 		 host = utils.get_tif(cache_fname)		
# #		 surf = np.argmax(host, 0).astype(np.float32)
# 		 host = host.argmax(0)	  
# # #		 
# # #		 mn, mx = 0.0, 149.0  # surf.min(), surf.max()
# # #		 print mn, mx
# # # 
# # #		 surf[0, 0] = mn
# # #		 surf[-1, -1] = mx
# # #				 
# # #		 plt.close('all')
# # # 
# # #		 plt.figure()
# # #		 plt.imshow(surf, 'gray', interpolation='nearest')
# # #		 
# #		 surf = ndimage.gaussian_filter(surf, 5, mode='nearest') 
# #		 
# #		 surf[0, 0] = mn
# #		 surf[-1, -1] = mx
# #				 
# #		 plt.figure()
# #		 plt.imshow(surf, 'gray', interpolation='nearest')
# #		 
# #		 return plt.show()
# 		 
# 		 cache_fname = utils.file_cache(fname, '/tmp/drmaize')
# 		 fung = utils.get_tif(cache_fname)
# 		 fung = np.argmax(fung, 0)
# 		 
# 		 tail1 = tail.replace('_topsurface_optimized1.txt', '_hyphsurface_skel.txt')
# 		 np.savetxt(os.path.join(head, 'surfacemap', tail1), fung * (skel > 0), delimiter=',')
# 		 print os.path.join(head, 'surfacemap', tail1)
# 		 
# 		 tail2 = tail.replace('_topsurface_optimized1.txt', '_hyphsurface_seg.txt')
# 		 np.savetxt(os.path.join(head, 'surfacemap', tail2), fung * (seg > 0), delimiter=',')
# 		 print os.path.join(head, 'surfacemap', tail2)
# 		 
# 		 fung = fung.astype(np.float32)
# 		 dpth = (fung - surf)
# 		 dpth *= 1.2
# 		 
# 		 met_row['depth_mean'] = np.mean(dpth[skel > 0].flat)
# 		 met_row['depth_median'] = np.median(dpth[skel > 0].flat)
# 		 met_row['depth_variance'] = np.var(dpth[skel > 0].flat)
# 		 met_row['depth_skewness'] = spstat.skew(dpth[skel > 0].flat)
# 		 met_row['depth_kurtosis'] = spstat.kurtosis(dpth[skel > 0].flat)
# 		 
# 		 for k in (met_row):
# 			 print k, met_row[k]
		metrics.append(met_row)
				
# 		 skel = seg
# 		  
# 		 sz = 2 ** 6
# 		 ctr = (fung - surf) * (skel > 0)
# 			 
# #		 ctr = -ctr
# 		 ctr = ndimage.uniform_filter(ctr, 2 * sz + 1, mode='constant', cval=ctr.max())
# 	 
# 		 ctr = ctr.argmin()
# 		 ctr = np.unravel_index(ctr, surf.shape)
# 		 slc = np.s_[ctr[0] - sz:ctr[0] + sz + 1, ctr[1] - sz: ctr[1] + sz + 1]
# 
# #		 slc = (slice(899, 1028, None), slice(1439, 1568, None))
# #		 slc = np.s_[...]
# 
# 		 print slc
# 		 
# 		 plt.close('all')
# 		  
# 		 plt.figure()
# 		 plt.imshow(host[slc], 'gray', interpolation='nearest')
# 	
# 		 plt.figure()
# 		 plt.imshow(fung[slc], 'gray', interpolation='nearest')
# 	
# 		 plt.figure()
# 		 plt.imshow(surf[slc], 'gray', interpolation='nearest')
# 	
# 		 plt.figure()
# 		 plt.imshow(skel[slc], 'gray', interpolation='nearest')
#   
# #		 plt.figure()
# #		 plt.imshow(((fung - surf) * (skel > 0))[slc], 'gray', interpolation='nearest')
# 		   
# 		 plt.figure()
# 		 plt.hist((fung - surf)[slc][skel[slc] > 0], bins=100)
# 		   
# 		 plt.figure()
# 		 plt.imshow((surf * (skel == 0) + fung * (skel > 0))[slc], 'gray', interpolation='nearest')
# 		  
# 		 plt.figure()
# 		 ax = plt.subplot(111, projection='3d')
#  
# 		 ys, xs = np.indices(skel.shape)
# 		 zs = fung		 
# 		 zs, ys, xs = (v[slc][skel[slc] > 0] for v in (zs, ys, xs))
# 		 ax.scatter((xs * 2.6240291219148313).astype(np.float32),
# 					(ys * 2.6240291219148313).astype(np.float32),
# 					(zs * -1.2).astype(np.float32), c='m',)  # marker='.')
# 			  
# 		 ys, xs = np.indices(surf.shape)
# 		 zs = surf		 
# 		 zs, ys, xs = (v[slc][skel[slc] == 0] for v in (zs, ys, xs))
# 		 ax.scatter((xs * 2.6240291219148313).astype(np.float32),
# 					(ys * 2.6240291219148313).astype(np.float32),
# 					(zs * -1.2).astype(np.float32), c='g',)  # marker='.')
# 		  
# 		 plt.show()
# 		 continue
	
	print (metrics)
	with open('metrics.csv', 'w') as csvfile:
		fieldnames = ['experiment', 'disease', 'plate', 'well_row', 'well_col', 'timestamp', \
					  'host', 'segmentation', \
					  'width_mean', 'width_median', 'width_variance', 'width_skewness', 'width_kurtosis', \
# 					   'depth_mean', 'depth_median', 'depth_variance', 'depth_skewness', 'depth_kurtosis', \
					  'leaf', 'edge', 'node']
		writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
		writer.writeheader()
		writer.writerows(metrics)
			
# #		 _, dist = skmorph.medial_axis(data['seg'], return_distance=True)
# #		 dist *= data['skel'] != 0
# #		 dist *= 2 * 2.6240291219148313
# #		   
# #		 plt.figure()
# #		 plt.hist(dist[dist > 0], normed=True)
# #		 plt.xlabel('micrometer width of hyphae')
# #		 plt.ylabel('proportion of hyphae')
# #		 
# #		 dist = ndimage.grey_dilation(dist, 2 ** 1 + 1, mode='constant')
# #		   
# #		 plt.figure()
# #		 plt.imshow(dist)
# #		 plt.colorbar()
# #		 plt.title('Micrometer Width of Hyphae')
# 		   
# #		 jet = (dist.astype(float) - dist.min()) / dist.ptp()
# #		 jet = ndimage.grey_dilation(jet, 2 ** 3 + 1, mode='constant')
# #		 cmap = plt.get_cmap('gray')
# #		 jet = cmap(jet)
# #		 spmisc.imsave('width_heat.png', jet)
# 		   
# 		   
# #		 return plt.show()
# 			  
# 		 cache_fname = utils.file_cache(os.path.join(pth, fname), '/tmp/drmaize')
# 		 im = utils.get_tif(cache_fname)		
# 		 skel_depth = im.argmax(0)
# 		 
# #		 
# 		 cache_fname = utils.file_cache(os.path.join(pth, fname[:-12] + 'l001.ome.tif'), '/tmp/drmaize')
# 		 im = utils.get_tif(cache_fname)
# # #		  
# #		 sz = max(np.divide(im.shape, 10.))
# #		 sz = np.arange(0, np.ceil(np.log2(sz)) + 1)
# #		 fil = np.empty((len(sz),) + im.shape[1:])
# #			
# #		 with shared_arrays(im, fil) as shm:
# #			 Parallel()(joblib.delayed(surf_map)(shm.im, shm.fil[i - sz[0]], 2 * 2 ** i + 1) for i in sz)
# #		   
# #		 w = 2. ** np.array(sz)
# #		 w /= w.sum()
# #		 surf_depth = (fil * w[..., None, None]).sum(0)
# 
# #		 surf = '/home/rhein/mnt/drmaize/image_data/013SLB/microimages/reconstructed/LeafSurfaceImage/exp013SLBp03wC31505041720_surfloc.txt'
# #		 surf_depth = np.loadtxt(surf, float, delimiter=",")
# 		 
# 		 surf_depth = im.argmax(0)
# 		 
# 		 depth = (skel_depth - surf_depth)
# 		 
# 		 plt.figure()
# 		 plt.hist((1.2 * depth[data['skel'] != 0]).flat, bins=100, normed=True)
# 		 plt.xlabel('micrometer depth below leaf surface')
# 		 plt.ylabel('proportion of hyphae')
# 		 
# 		 depth = depth * (data['skel'] != 0)
# 		 depth = ndimage.grey_dilation(depth, 2 ** 1 + 1, mode='constant')
# 		 
# 		 plt.figure()
# 		 plt.imshow(1.2 * depth * (depth > 0))
# 		 plt.colorbar()
# 		 plt.title('Micrometer Depth of Hyphae')
# 
# 				 
# #		 plt.figure()
# #		 plt.subplot(131), plt.imshow(skel_depth, 'gray')
# #		 plt.subplot(132), plt.imshow(surf_depth, 'gray')
# #		 plt.subplot(133), plt.imshow(depth, 'gray')
# #		 
# #		 plt.figure()
# #		 plt.subplot(131), plt.imshow(((1 + skel_depth) * (data['skel'] != 0))[slc])  # , 'gray')
# #		 plt.subplot(132), plt.imshow(((1 + surf_depth) * (data['skel'] != 0))[slc])  # , 'gray')
# #		 plt.subplot(133), plt.imshow(((1 + depth) * (depth > 0) * (data['skel'] != 0))[slc])  # , 'gray')
# 
# #		 jet = (1 + depth) * (depth > 0) * (data['skel'] != 0)
# #		 jet = ndimage.grey_dilation(jet, 2 ** 3 + 1, mode='constant')
# #		 jet = (jet.astype(float) - jet.min()) / jet.ptp()
# #		 cmap = plt.get_cmap('jet')
# #		 jet = cmap(jet)
# #		 spmisc.imsave('depth_heat.png', jet)
# 		 
# 		 return plt.show()
	
	
def surf_map(input, output, size):
	v = ndimage.uniform_filter(input, (1,) + (size,) * 2, mode='constant')
	output[...] = v.argmax(0)


def prune_leaves(cand_leaf, cand_node, v):
	l = cand_leaf[:, 0] == v
	l = cand_leaf[l, 1:3]
	n = cand_node[:, 0] == v
	n, s = cand_node[n, 1:3], cand_node[n, 3]
	d = spatial.distance.cdist(l, n)
	d = d.min(1)
	s = s.max()
	return l[d < s]


def main(experiment):
	pipeline(experiment)

if __name__ == '__main__':
	if len(sys.argv) < 2:
		print "Usage: python SegmentHyphae.py <experiment>"
	else:
		arg_names = ['script_name', 'experiment']
		args = dict(zip(arg_names, sys.argv))
		Arg_list = collections.namedtuple('Arg_list', arg_names)
		args = Arg_list(*(args.get(arg, None) for arg in arg_names))
		experiment = args[1]
		print "Experiment:", experiment
		
		os.system("taskset -p 0xFFFFFFFF %d" % os.getpid())

		for f in os.listdir('/dev/shm'):
			if 'shmmap' in f:
				os.remove('/dev/shm/' + f)

		statvfs = os.statvfs('/dev/shm')
		if (statvfs.f_frsize * statvfs.f_bavail / 1024. ** 3) < 44:
			raise Exception('Shared memory is running low.  try: sudo mount -o remount,size=100% /run/shm/')

		javabridge.start_vm(args=[], class_path=bioformats.JARS)
		try:
			bioformats.init_logger()	
			main(experiment)
		finally:
			javabridge.kill_vm()
