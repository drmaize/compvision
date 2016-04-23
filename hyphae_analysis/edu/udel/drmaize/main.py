import os
import re
import time

import scipy.spatial as spspat
import skimage.morphology as skmorph
from mpl_toolkits.mplot3d import Axes3D
from scipy.spatial.distance import cdist
import scipy.stats as spstat
import matplotlib.pyplot as plt
import joblib
import scipy.signal as spsig
import bioformats
import javabridge
import numpy as np
import scipy.ndimage as spim
import scipy.misc as spmisc

import skimage.filters as skfil

from edu.udel.drmaize import utils
from joblib import Parallel
from overtime.sharedmemory import ndshm, shared_arrays
import scipy.misc as spmisc
import csv
import sys

import mayavi.mlab as mlab
from collections import OrderedDict

# def _worker((func, args, kwargs)):
# try:
# return func(*args, **kwargs)
# except:
# traceback.print_exc()
# raise


def hyst(lo, hi, structure=None):
    labels = spim.label(lo, structure=structure)
    labs = np.unique(labels[0][hi])
    labs = labs[labs > 0]

    # msk = np.zeros(labels[0].shape, bool)
    # for l in labs:
    # msk[labels[0] == l] = True

    msk = ndshm.zeros(labels[0].shape, bool)
    labels = ndshm.fromndarray(labels[0])

    Parallel(n_jobs=1, max_nbytes=None)(joblib.delayed(utils.set_msk)(msk, labels, l) for l in labs)

    return np.copy(msk)

    # msk = arr2mmap(np.zeros(labels[0].shape, bool))
    # labels = arr2mmap(labels[0])
    #
    # pool = mp.Pool(initializer=mp_init, initargs=({'labels': labels, 'msk': msk},))
    # try:
    # pool.map(mp_unpack, ((mp_ident(set_msk), ((mp_glob('msk'), mp_glob('labels'), mp_ident(l))), {}) for l in labs))
    # pool.close()
    # except:
    # pool.terminate()
    # raise
    # finally:
    # pool.join()
    #
    # msk = shm2arr(msk)
    #
    # #     retval = arr2mmap(np.empty((len(d2dx2),) + im_pad.shape))
    # #     im_pad = arr2mmap(im_pad)
    # #     pool = mp.pool.Pool(initializer=mp_init, initargs=({'im_pad':im_pad, 'retval':retval},))
    # #     try:
    # #         pool.map(mp_unpack, ((mp_ret_wrap((mp_glob_slc(('retval', i)), mp_eval('spsig.fftconvolve'))), (mp_glob('im_pad'), mp_ident(k), mp_ident('same')), {}) for i, k in enumerate(d2dx2)))
    # #         pool.close()
    # #     except:
    # #         pool.terminate()
    # #         raise
    # #     finally:
    # #         pool.join()
    #
    # return msk


def hesseig(im, res, sz, nstds, orthstep, nrm=None):
    d2dx2 = get_hessian_kernels(res, sz, nstds, orthstep)
    if nrm is not None:
        d2dx2 = list(d2dx2[i] / np.abs(d2dx2[i]).sum() * nrm[i] for i in range(len(d2dx2)))

    pad = tuple((p, p) for p in np.divide(np.max(list(k.shape for k in d2dx2), 0), 2))
    im_pad = np.pad(im, pad, 'edge').astype(float)

    retval = ndshm.zeros((len(d2dx2),) + im_pad.shape)
    im_pad = ndshm.fromndarray(im_pad)

    Parallel(n_jobs=1, max_nbytes=None, verbose=0)(
        joblib.delayed(utils.add_out_arg(spsig.fftconvolve))(im_pad, k, 'same', out=retval[i])
        for i, k in enumerate(d2dx2))

    retval = np.copy(retval)
    im_pad = np.copy(im_pad)

    d2dx2 = np.empty((len(res),) * 2 + im.shape)
    for ind, (i, j) in enumerate(np.transpose(np.triu_indices(len(res)))):
        d2dx2[i, j] = d2dx2[j, i] = utils.unpad(retval[ind], pad)

    # eigen
    axes = tuple(range(len(res) + 2))
    d2dx2 = np.transpose(d2dx2, axes[2:] + axes[:2])

    retval = ndshm.zeros(d2dx2.shape[:-1])
    d2dx2 = ndshm.fromndarray(d2dx2)

    Parallel(n_jobs=1, max_nbytes=None, verbose=0)(
        joblib.delayed(utils.add_out_arg(np.linalg.eigvalsh))(d2dx2[i], out=retval[i])
        for i in range(len(d2dx2)))

    retval = np.copy(retval)
    d2dx2 = np.concatenate(list(a[None, ...] for a in retval))

    return d2dx2


def get_hessian_kernels(resolution, size, num_stds, ortho_step_size):
    assert np.all(np.asarray(size) > 1.)
    dd = []
    for dx in np.transpose(np.triu_indices(len(resolution))):
        order = [np.count_nonzero(dx == i) for i in xrange(len(resolution))]
        sigma = np.sum(
            (np.arange(len(resolution), dtype=np.float64) != i) * (ortho_step_size * o)
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
    scspace = (spstat.gmean(1 + scspace, 0) - 1) ** .5  # spstat.gmean(scspace, 0)

    lne, crn = scspace[..., 0], scspace[..., 1]
    
#     sz = 2 ** 8
#     mx = spim.uniform_filter(lne, 2 * sz + 1, mode='constant').argmax()
#     mx = np.unravel_index(mx, lne.shape)
#     slc = np.s_[mx[0] - sz:mx[0] + sz + 1, mx[1] - sz:mx[1] + sz + 1]
#     print slc
#     exit()
#     (slice(3, 516, None), slice(1026, 1539, None))

    slc = Ellipsis  # (slice(3, 516, None), slice(1026, 1539, None))

#     plt.figure('crn')
#     plt.imshow(crn[slc] ** .5, 'gray')
#     plt.figure('lne')
#     plt.imshow(lne[slc] ** .5, 'gray')

    data['crn'] = crn
    data['lne'] = lne
    
    if os.path.isfile(os.path.join(pth, 'results/segmentationfungus', npz_name)):
        npz_cache = utils.file_cache(os.path.join(pth, 'results/segmentationfungus', npz_name), '/tmp/drmaize/')
    else:
        npz_cache = os.path.join(pth, 'results/segmentationfungus', npz_name)
        np.savez_compressed(os.path.join(pth, 'results/segmentationfungus', npz_name), **data)
    with np.load(npz_cache, 'r') as old_data:
        old_data = dict(old_data)

    old_data.update(data)
    data = old_data
    np.savez_compressed(os.path.join(pth, 'results/segmentationfungus', npz_name), **data)

    print npz_name
    print npz_cache


def segment(pth, fname, npz_name, exp_re, immsk):
    print "segment"
    data = {}

    npz_cache = utils.file_cache(os.path.join(pth, 'results/segmentationfungus', npz_name), '/tmp/drmaize/')
    with np.load(npz_cache, 'r') as old_data:
        crn = old_data['crn']
        lne = old_data['lne']

#     plt.figure('dist')
#     plt.subplot(121), plt.hist(np.log(lne[lne > 1e-6]).flat, bins=255)
#     plt.subplot(122), plt.hist(np.log(crn[crn > 1e-6]).flat, bins=255)

    for d in (lne, crn):
        print np.log(d[d > 1e-6]).mean() + np.arange(5) * np.log(d[d > 1e-6]).std()

    m = re.match(exp_re, fname)
    print m.group(3)
#     if m.group(3) == '01':
#         # 12 HPI
#         cmsk = 2.25, 7.5
#         lmsk = 3.75
#     elif m.group(3) == '02':
#         # 24 HPI
#         cmsk = 2., 5.25
#         lmsk = 2.75
#     elif m.group(3) == '03':
#         # 48 HPI
#         cmsk = 1.5, 5.
#         lmsk = 2.25
#     else:
#         raise Exception

    cmsk = np.log(crn[crn > 1e-6]).mean() + 4.0 * np.log(crn[crn > 1e-6]).std(),  # 1.5, 4.5
    lmsk = np.log(lne[lne > 1e-6]).mean() + 3.5 * np.log(lne[lne > 1e-6]).std()  # 2.25

    crn = (crn > cmsk[0])  # | (lne > cmsk[1])
    lne = (lne > lmsk)
    seg = hyst(lne, crn, np.ones((3, 3), bool))
    seg[~immsk] = 0

    slc = Ellipsis  # (slice(3, 516, None), slice(1026, 1539, None))

#     plt.figure('cmsk')
#     plt.imshow(crn[slc], 'gray', interpolation='nearest')
#     plt.figure('lmsk')
#     plt.imshow(lne[slc], 'gray', interpolation='nearest')
 
#     plt.figure('seg')
#     plt.imshow(seg[slc], 'gray', interpolation='nearest')

    data['seg'] = seg
    
    npz_cache = utils.file_cache(os.path.join(pth, 'results/segmentationfungus', npz_name), '/tmp/drmaize/')
    with np.load(npz_cache, 'r') as old_data:
        old_data = dict(old_data)
        old_data.update(data)
        data = old_data
        np.savez_compressed(os.path.join(pth, 'results/segmentationfungus', npz_name), **data)

    print npz_name
    print npz_cache    


def skeleton(pth, npz_name, immsk):
    print 'skeleton'
    data = {}

    npz_cache = utils.file_cache(os.path.join(pth, 'results/segmentationfungus', npz_name), '/tmp/drmaize/')
    with np.load(npz_cache, 'r') as old_data:
        seg = old_data['seg']

    skel, dist = skmorph.medial_axis(seg, return_distance=True)
    node, edge, leaf = (spim.label(g, np.ones((3, 3), bool))[0] for g in utils.skel2graph(skel))

    trim_edge = (edge != 0) & ~(skmorph.binary_dilation(node != 0, np.ones((3, 3), bool)) != 0)
    trim_edge = spim.label(trim_edge, np.ones((3, 3), bool))[0]

    leaf_edge_vals = skmorph.binary_dilation(leaf != 0, np.ones((3, 3), bool)) != 0
    leaf_edge_vals = np.unique(trim_edge[leaf_edge_vals])
    leaf_edge_vals = leaf_edge_vals[leaf_edge_vals > 0]
    leaf_edge = leaf != 0

    # for v in leaf_edge_vals:
    # leaf_edge[trim_edge == v] = True

    # trim_edge = arr2mmap(trim_edge)
    # leaf_edge = arr2mmap(leaf_edge)
    # pool = mp.Pool(initializer=mp_init, initargs=({'leaf_edge': leaf_edge, 'trim_edge': trim_edge},))
    # try:
    # pool.map(mp_unpack,
    # ((mp_ident(set_msk), ((mp_glob('leaf_edge'), mp_glob('trim_edge'), mp_ident(l))), {}) for l
    # in
    # leaf_edge_vals))
    # pool.close()
    # except:
    # pool.terminate()
    # raise
    # finally:
    # pool.join()
    trim_edge = ndshm.fromndarray(trim_edge)
    leaf_edge = ndshm.fromndarray(leaf_edge)
    Parallel(n_jobs=1, max_nbytes=None)(
        joblib.delayed(utils.set_msk)(leaf_edge, trim_edge, l) for l in leaf_edge_vals)
    trim_edge = np.copy(trim_edge)
    leaf_edge = np.copy(leaf_edge)

    leaf_edge[(skmorph.binary_dilation(leaf_edge, np.ones((3, 3), bool)) != 0) & (edge != 0)] = True
    leaf_edge = spim.label(leaf_edge, np.ones((3, 3), bool))[0]

    leaf_edge_node = skmorph.binary_dilation(leaf_edge != 0, np.ones((3, 3), bool)) != 0
    leaf_edge_node = ((node != 0) & leaf_edge_node) | leaf_edge
    leaf_edge_node = spim.label(leaf_edge_node, np.ones((3, 3), bool))[0]

    cand_node = leaf_edge_node * (node != 0)
    cand_node = cand_node.nonzero()
    cand_node = np.transpose((leaf_edge_node[cand_node],) + cand_node + (2 * dist[cand_node],))

    cand_leaf = leaf_edge_node * (leaf != 0)
    cand_leaf = cand_leaf.nonzero()
    cand_leaf = np.transpose((leaf_edge_node[cand_leaf],) + cand_leaf)

    if len(cand_node) > 0 and len(cand_leaf) > 0:
        # pruned = []
        # for v in np.unique(cand_node[:, 0]):
        # p = prune_leaves(cand_leaf, cand_node, v)
        # pruned.append(p)

        # cand_leaf = arr2mmap(cand_leaf)
        # cand_node = arr2mmap(cand_node)
        # pool = mp.Pool(initializer=mp_init, initargs=({'cand_leaf': cand_leaf, 'cand_node': cand_node},))
        # try:
        # pruned = pool.map(mp_unpack, (
        # (mp_ident(prune_leaves), ((mp_glob('cand_leaf'), mp_glob('cand_node'), mp_ident(j))), {}) for j
        # in
        # np.unique(cand_node[:, 0])))
        # pool.close()
        # except:
        # pool.terminate()
        # raise
        # finally:
        # pool.join()

        cand_leaf = ndshm.fromndarray(cand_leaf)
        cand_node = ndshm.fromndarray(cand_node)
        pruned = Parallel(n_jobs=1, max_nbytes=None)(
            joblib.delayed(prune_leaves)(cand_leaf, cand_node, j) for j in np.unique(cand_node[:, 0]))
        cand_leaf = np.copy(cand_leaf)
        cand_node = np.copy(cand_node)

        pruned_ind = []
        for p in pruned:
            pruned_ind.extend(p)
        pruned_ind = tuple(np.transpose(pruned_ind))

        pruned = ~skel

        # for v in leaf_edge[pruned_ind]:
        # pruned[leaf_edge == v] = True

        # pruned = arr2mmap(pruned)
        # leaf_edge = arr2mmap(leaf_edge)
        # pool = mp.Pool(initializer=mp_init, initargs=({'leaf_edge': leaf_edge, 'pruned': pruned},))
        # try:
        # pool.map(mp_unpack,
        # ((mp_ident(set_msk), ((mp_glob('pruned'), mp_glob('leaf_edge'), mp_ident(l))), {}) for l in
        # np.unique(leaf_edge[pruned_ind])))
        # pool.close()
        # except:
        # pool.terminate()
        # raise
        # finally:
        # pool.join()

        pruned = ndshm.fromndarray(pruned)
        leaf_edge = ndshm.fromndarray(leaf_edge)
        Parallel(n_jobs=1, max_nbytes=None)(
            joblib.delayed(utils.set_msk)(pruned, leaf_edge, l) for l in np.unique(leaf_edge[pruned_ind]))
        pruned = np.copy(pruned)
        leaf_edge = np.copy(leaf_edge)

        pruned = ~pruned
        pruned[~immsk] = False
    else:
        pruned = np.zeros_like(skel)

    slc = np.s_[:seg.shape[0] / 4, :seg.shape[1] / 4]

#     plt.figure('skel')
#     plt.imshow(pruned[slc], 'gray')
#     plt.figure('pruned')
#     plt.imshow((skel & ~pruned)[slc], 'gray')

    data['pruned'] = skel & ~pruned
    data['skel'] = pruned

    npz_cache = utils.file_cache(os.path.join(pth, 'results/segmentationfungus', npz_name), '/tmp/drmaize/')
    with np.load(npz_cache, 'r') as old_data:
        old_data = dict(old_data)
        old_data.update(data)
        data = old_data
        np.savez_compressed(os.path.join(pth, 'results/segmentationfungus', npz_name), **data)

    print npz_name
    print npz_cache


def pipeline():
    # TODO extract function for selecting filenames
    
    '/home/rhein/mnt/drmaize/image_data/e013SLB/microimages/reconstructed/HS'
    'e013SLBp01wA1x20_1506111930rc001.ome.tif'
    
    exp_re = 'e(\d{3})(SLB|NLB)p(\d{2})w([A-D])([1-6])x20_(\d*)rf001\.ome\.tif'
    data_dir = '/home/rhein/mnt/drmaize/image_data'
    sub_dir = 'microimages/reconstructed/HS'
    
    
    exp = 'e022NLB'
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
            
#             if int(m.group(3)) == 1:
#                 if 1 <= int(m.group(5)) <= 3:
#                     if m.group(6) == '1506111930':
#                         fnames.append(os.path.join(data_dir, exp, sub_dir, f))
#                         print f
#                 if 4 <= int(m.group(5)) <= 6:
#                     if m.group(6) == '1506121515':
#                         fnames.append(os.path.join(data_dir, exp, sub_dir, f))
#                         print f
#             elif int(m.group(3)) == 2:
#                 if 1 <= int(m.group(5)) <= 3:
#                     if m.group(6) == '1506121700':
#                         fnames.append(os.path.join(data_dir, exp, sub_dir, f))
#                         print f
#                 if 4 <= int(m.group(5)) <= 6:
#                     if m.group(6) == '1506221400':
#                         fnames.append(os.path.join(data_dir, exp, sub_dir, f))
#                         print f
#             elif int(m.group(3)) == 3:
#                 if 1 <= int(m.group(5)) <= 3:
#                     if m.group(6) == '1505041720':
#                         fnames.append(os.path.join(data_dir, exp, sub_dir, f))
#                         print f
#                 if 4 <= int(m.group(5)) <= 6:
#                     if m.group(6) == '1508062130':
#                         fnames.append(os.path.join(data_dir, exp, sub_dir, f))
#                         print f
#         if False:
#             pass
#         elif m and m.group(6) in ['1501221600', '1501241213']:
#             fnames.append(os.path.join(data_dir, exp, sub_dir, f))
#             print f
#         elif m and m.group(3) == '02' and m.group(6) == '':
#             fnames.append(os.path.join(data_dir, exp, sub_dir, f))
#             print f
#         elif m and m.group(3) == '03' and m.group(6) == '':
#             fnames.append(os.path.join(data_dir, exp, sub_dir, f))
#             print f
#         if f == 'exp013SLBp03wC31505041720rf001.ome.tif':
#             fnames.append(os.path.join(data_dir, exp, sub_dir, f))
    
    seed = time.time()
    print 'seed', seed
    
    metrics = []

    for fname in sorted(fnames)[::-1]:
#         fname = '/home/rhein/mnt/drmaize/image_data/013SLB/microimages/reconstructed/exp013SLBp02wB31506121700rf002.ome.tif'

#         fname = '/home/rhein/mnt/drmaize/image_data/013SLB/microimages/reconstructed/exp013SLBp03wB11505041720rf002.ome.tif'
        print 'filename', fname
        
#         head, tail = os.path.split(fname)
#         tail = tail.replace('rf002.ome.tif', '_topsurface.txt')
#         surf = os.path.join(head, 'LeafSurfaceImage', tail)
#         surf = np.loadtxt(surf, np.float32, delimiter=',')
#          
#         plt.figure('surf')
#         plt.hist(surf.flat, bins=100)
# #         plt.imshow(surf, 'gray', interpolation='nearest')
#          

#         cache_fname = utils.file_cache(fname, '/tmp/drmaize')
#         fung = utils.get_tif(cache_fname)
#         print 'fung', cache_fname
#         
#         cache_fname = utils.file_cache(fname.replace('rf', 'rl'), '/tmp/drmaize')
#         host = utils.get_tif(cache_fname)
#         print 'host', cache_fname
#         
#         plt.figure()
#         plt.imshow(host.max(1), 'gray', interpolation='nearest')
# 
#         plt.figure()
#         plt.imshow(fung.max(1), 'gray', interpolation='nearest')
#         
#         head, tail = os.path.split(fname)
#         tail = tail.replace('rf002.ome.tif', '_topsurface.txt')
#         surf = os.path.join(head, 'LeafSurfaceImage', tail)
#         surf = np.loadtxt(surf, np.float32, delimiter=',')
# 
#         ys, xs = np.indices(surf.shape)
#         zs = surf
#         
#         zs, ys, xs = (spim.zoom(v, 2. ** -5, order=1) for v in (zs, ys, xs))
#         
#         plt.figure()
#         ax = plt.subplot(111, projection='3d')
#         ax.scatter(xs * 2.6240291219148313, ys * 2.6240291219148313, zs * 1.2)
        
#         def randrange(n, vmin, vmax):
#             return (vmax - vmin) * np.random.rand(n) + vmin
#         
#         fig = plt.figure()
#         ax = fig.add_subplot(111, projection='3d')
#         n = 100
#         for c, m, zl, zh in [('r', 'o', -50, -25), ('b', '^', -30, -5)]:
#             xs = randrange(n, 23, 32)
#             ys = randrange(n, 0, 100)
#             zs = randrange(n, zl, zh)
#             ax.scatter(xs, ys, zs, c=c, marker=m)
#         
#         ax.set_xlabel('X Label')
#         ax.set_ylabel('Y Label')
#         ax.set_zlabel('Z Label')
                          
#          
#         plt.figure('fung')
#         plt.hist(fung.flat, bins=100)
# #         plt.imshow(fung, 'gray', interpolation='nearest')
#  
    
        pth, fname = os.path.split(fname)
        if os.path.isfile(os.path.join(pth, 'MIP', fname)):
            cache_fname = utils.file_cache(os.path.join(pth, 'MIP', fname), '/tmp/drmaize')
            im = spim.imread(cache_fname)
        else:
            cache_fname = utils.file_cache(os.path.join(pth, fname), '/tmp/drmaize')
            im = utils.get_tif(cache_fname)
            im = np.max(im, 0)
            spmisc.imsave(os.path.join(pth, 'MIP', fname), im)
        print 'cache filename', cache_fname        

        im = im.astype(float)
#         im = utils.imscale(im, (.5,) * 2)

        cache_fname = utils.file_cache(os.path.join(pth, fname), '/tmp/drmaize/')
        res = utils.get_tif_res(cache_fname)
        print 'physical resolution', res
        res = res[1:]
        res = res / np.min(res)

        npz_name = '{}.npz'.format(os.path.splitext(os.path.splitext(fname)[0])[0])

        # mask generation
        # TODO insert mask into cache file
        immsk = im > 4
#         immsk = im > skfil.threshold_otsu(im[im > 1e-6])
        r = 2 ** 5
#         selem = np.indices((2 * r + 1,) * 2, float)
#         selem -= r
#         selem **= 2
#         selem = selem.sum(0)
#         np.sqrt(selem, selem)
#         selem = selem <= r
#         immsk = utils.fft_binary_closing(immsk, selem)
#         r = np.max(im.shape) / 40
        selem = np.indices((2 * r + 1,) * 2, float)
        selem -= r
        selem **= 2
        selem = selem.sum(0)
        np.sqrt(selem, selem)
        selem = selem <= r
        immsk = utils.fft_binary_erosion(immsk, selem)
        immsk[:r, :] = immsk[:, :r] = immsk[-r:, :] = immsk[:, -r:] = 0
                
        slc = np.s_[:im.shape[0] / 16, :im.shape[1] / 16]
        
#         plt.figure('im')
#         plt.imshow(im[slc] ** .5, 'gray')
#         plt.figure('immsk')
#         plt.imshow(immsk[slc], 'gray')

#         scanal(pth, npz_name, im, immsk, sizes, nstds, orthstep, res)
#         segment(pth, fname, npz_name, exp_re, immsk)
#         skeleton(pth, npz_name, immsk)
#         continue
        
        npz_cache = utils.file_cache(os.path.join(pth, 'results/segmentationfungus', npz_name), '/tmp/drmaize/')
        with np.load(npz_cache, 'r') as data:
            data = dict(data)
                        
#         for k, v in data.items():
#             plt.figure(k)
#             plt.imshow(v[slc], 'gray')
            
        seg = data['seg']
        skel, dist = skmorph.medial_axis(seg, return_distance=True)
        node, edge, leaf = (spim.label(g, np.ones((3, 3), bool))[0] for g in utils.skel2graph(skel))

        dist = dist * 2.6240291219148313
#         plt.figure('dist')
#         plt.imshow(dist[slc], 'gray', interpolation='nearest')
#         
#         plt.figure('node')
#         plt.imshow(node[slc], 'gray', interpolation='nearest')
#         plt.figure('edge')
#         plt.imshow(edge[slc], 'gray', interpolation='nearest')
#         plt.figure('leaf')
#         plt.imshow(leaf[slc], 'gray', interpolation='nearest')
#                
#         plt.show()
        
#         exp_re = 'exp(\d{3})(SLB|NLB)p(\d{2})w([A-D])([1-6])(\d*)rf002\.ome\.tif'
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
        met_row['width_skewness'] = spstat.skew(dist[seg > 0].flat)
        met_row['width_kurtosis'] = spstat.kurtosis(dist[seg > 0].flat)
        
        met_row['leaf'] = np.count_nonzero(leaf)
        met_row['edge'] = np.count_nonzero(edge)
        met_row['node'] = np.count_nonzero(node)
    
            
#         fname = os.path.join(pth, fname)
#         head, tail = os.path.split(fname)
#         tail = tail.replace('rf001.ome.tif', '_topsurface_optimized1.txt')
#         surf = os.path.join(head, 'surfacemap', tail)
#         cache_fname = utils.file_cache(surf, '/tmp/drmaize')
#         surf = np.loadtxt(cache_fname, np.float32, delimiter=',')
# 
#         fname = os.path.join(pth, fname)
#         tif = fname.replace('rf', 'rl')
#         cache_fname = utils.file_cache(tif, '/tmp/drmaize')
#         host = utils.get_tif(cache_fname)        
# #         surf = np.argmax(host, 0).astype(np.float32)
#         host = host.argmax(0)      
# # #         
# # #         mn, mx = 0.0, 149.0  # surf.min(), surf.max()
# # #         print mn, mx
# # # 
# # #         surf[0, 0] = mn
# # #         surf[-1, -1] = mx
# # #                 
# # #         plt.close('all')
# # # 
# # #         plt.figure()
# # #         plt.imshow(surf, 'gray', interpolation='nearest')
# # #         
# #         surf = spim.gaussian_filter(surf, 5, mode='nearest') 
# #         
# #         surf[0, 0] = mn
# #         surf[-1, -1] = mx
# #                 
# #         plt.figure()
# #         plt.imshow(surf, 'gray', interpolation='nearest')
# #         
# #         return plt.show()
#         
#         cache_fname = utils.file_cache(fname, '/tmp/drmaize')
#         fung = utils.get_tif(cache_fname)
#         fung = np.argmax(fung, 0)
#         
#         tail1 = tail.replace('_topsurface_optimized1.txt', '_hyphsurface_skel.txt')
#         np.savetxt(os.path.join(head, 'surfacemap', tail1), fung * (skel > 0), delimiter=',')
#         print os.path.join(head, 'surfacemap', tail1)
#         
#         tail2 = tail.replace('_topsurface_optimized1.txt', '_hyphsurface_seg.txt')
#         np.savetxt(os.path.join(head, 'surfacemap', tail2), fung * (seg > 0), delimiter=',')
#         print os.path.join(head, 'surfacemap', tail2)
#         
#         fung = fung.astype(np.float32)
#         dpth = (fung - surf)
#         dpth *= 1.2
#         
#         met_row['depth_mean'] = np.mean(dpth[skel > 0].flat)
#         met_row['depth_median'] = np.median(dpth[skel > 0].flat)
#         met_row['depth_variance'] = np.var(dpth[skel > 0].flat)
#         met_row['depth_skewness'] = spstat.skew(dpth[skel > 0].flat)
#         met_row['depth_kurtosis'] = spstat.kurtosis(dpth[skel > 0].flat)
#         
#         for k in (met_row):
#             print k, met_row[k]
        metrics.append(met_row)
                
#         skel = seg
#          
#         sz = 2 ** 6
#         ctr = (fung - surf) * (skel > 0)
#             
# #         ctr = -ctr
#         ctr = spim.uniform_filter(ctr, 2 * sz + 1, mode='constant', cval=ctr.max())
#     
#         ctr = ctr.argmin()
#         ctr = np.unravel_index(ctr, surf.shape)
#         slc = np.s_[ctr[0] - sz:ctr[0] + sz + 1, ctr[1] - sz: ctr[1] + sz + 1]
# 
# #         slc = (slice(899, 1028, None), slice(1439, 1568, None))
# #         slc = np.s_[...]
# 
#         print slc
#         
#         plt.close('all')
#          
#         plt.figure()
#         plt.imshow(host[slc], 'gray', interpolation='nearest')
#    
#         plt.figure()
#         plt.imshow(fung[slc], 'gray', interpolation='nearest')
#    
#         plt.figure()
#         plt.imshow(surf[slc], 'gray', interpolation='nearest')
#    
#         plt.figure()
#         plt.imshow(skel[slc], 'gray', interpolation='nearest')
#   
# #         plt.figure()
# #         plt.imshow(((fung - surf) * (skel > 0))[slc], 'gray', interpolation='nearest')
#           
#         plt.figure()
#         plt.hist((fung - surf)[slc][skel[slc] > 0], bins=100)
#           
#         plt.figure()
#         plt.imshow((surf * (skel == 0) + fung * (skel > 0))[slc], 'gray', interpolation='nearest')
#          
#         plt.figure()
#         ax = plt.subplot(111, projection='3d')
#  
#         ys, xs = np.indices(skel.shape)
#         zs = fung         
#         zs, ys, xs = (v[slc][skel[slc] > 0] for v in (zs, ys, xs))
#         ax.scatter((xs * 2.6240291219148313).astype(np.float32),
#                    (ys * 2.6240291219148313).astype(np.float32),
#                    (zs * -1.2).astype(np.float32), c='m',)  # marker='.')
#              
#         ys, xs = np.indices(surf.shape)
#         zs = surf         
#         zs, ys, xs = (v[slc][skel[slc] == 0] for v in (zs, ys, xs))
#         ax.scatter((xs * 2.6240291219148313).astype(np.float32),
#                    (ys * 2.6240291219148313).astype(np.float32),
#                    (zs * -1.2).astype(np.float32), c='g',)  # marker='.')
#          
#         plt.show()
#         continue
    
    print (metrics)
    with open('metrics.csv', 'w') as csvfile:
        fieldnames = ['experiment', 'disease', 'plate', 'well_row', 'well_col', 'timestamp', \
                      'host', 'segmentation', \
                      'width_mean', 'width_median', 'width_variance', 'width_skewness', 'width_kurtosis', \
#                       'depth_mean', 'depth_median', 'depth_variance', 'depth_skewness', 'depth_kurtosis', \
                      'leaf', 'edge', 'node']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(metrics)
            
# #         _, dist = skmorph.medial_axis(data['seg'], return_distance=True)
# #         dist *= data['skel'] != 0
# #         dist *= 2 * 2.6240291219148313
# #           
# #         plt.figure()
# #         plt.hist(dist[dist > 0], normed=True)
# #         plt.xlabel('micrometer width of hyphae')
# #         plt.ylabel('proportion of hyphae')
# #         
# #         dist = spim.grey_dilation(dist, 2 ** 1 + 1, mode='constant')
# #           
# #         plt.figure()
# #         plt.imshow(dist)
# #         plt.colorbar()
# #         plt.title('Micrometer Width of Hyphae')
#           
# #         jet = (dist.astype(float) - dist.min()) / dist.ptp()
# #         jet = spim.grey_dilation(jet, 2 ** 3 + 1, mode='constant')
# #         cmap = plt.get_cmap('gray')
# #         jet = cmap(jet)
# #         spmisc.imsave('width_heat.png', jet)
#           
#           
# #         return plt.show()
#              
#         cache_fname = utils.file_cache(os.path.join(pth, fname), '/tmp/drmaize')
#         im = utils.get_tif(cache_fname)        
#         skel_depth = im.argmax(0)
#         
# #         
#         cache_fname = utils.file_cache(os.path.join(pth, fname[:-12] + 'l001.ome.tif'), '/tmp/drmaize')
#         im = utils.get_tif(cache_fname)
# # #          
# #         sz = max(np.divide(im.shape, 10.))
# #         sz = np.arange(0, np.ceil(np.log2(sz)) + 1)
# #         fil = np.empty((len(sz),) + im.shape[1:])
# #            
# #         with shared_arrays(im, fil) as shm:
# #             Parallel()(joblib.delayed(surf_map)(shm.im, shm.fil[i - sz[0]], 2 * 2 ** i + 1) for i in sz)
# #           
# #         w = 2. ** np.array(sz)
# #         w /= w.sum()
# #         surf_depth = (fil * w[..., None, None]).sum(0)
# 
# #         surf = '/home/rhein/mnt/drmaize/image_data/013SLB/microimages/reconstructed/LeafSurfaceImage/exp013SLBp03wC31505041720_surfloc.txt'
# #         surf_depth = np.loadtxt(surf, float, delimiter=",")
#         
#         surf_depth = im.argmax(0)
#         
#         depth = (skel_depth - surf_depth)
#         
#         plt.figure()
#         plt.hist((1.2 * depth[data['skel'] != 0]).flat, bins=100, normed=True)
#         plt.xlabel('micrometer depth below leaf surface')
#         plt.ylabel('proportion of hyphae')
#         
#         depth = depth * (data['skel'] != 0)
#         depth = spim.grey_dilation(depth, 2 ** 1 + 1, mode='constant')
#         
#         plt.figure()
#         plt.imshow(1.2 * depth * (depth > 0))
#         plt.colorbar()
#         plt.title('Micrometer Depth of Hyphae')
# 
#                 
# #         plt.figure()
# #         plt.subplot(131), plt.imshow(skel_depth, 'gray')
# #         plt.subplot(132), plt.imshow(surf_depth, 'gray')
# #         plt.subplot(133), plt.imshow(depth, 'gray')
# #         
# #         plt.figure()
# #         plt.subplot(131), plt.imshow(((1 + skel_depth) * (data['skel'] != 0))[slc])  # , 'gray')
# #         plt.subplot(132), plt.imshow(((1 + surf_depth) * (data['skel'] != 0))[slc])  # , 'gray')
# #         plt.subplot(133), plt.imshow(((1 + depth) * (depth > 0) * (data['skel'] != 0))[slc])  # , 'gray')
# 
# #         jet = (1 + depth) * (depth > 0) * (data['skel'] != 0)
# #         jet = spim.grey_dilation(jet, 2 ** 3 + 1, mode='constant')
# #         jet = (jet.astype(float) - jet.min()) / jet.ptp()
# #         cmap = plt.get_cmap('jet')
# #         jet = cmap(jet)
# #         spmisc.imsave('depth_heat.png', jet)
#         
#         return plt.show()
    
    
def surf_map(input, output, size):
    v = spim.uniform_filter(input, (1,) + (size,) * 2, mode='constant')
    output[...] = v.argmax(0)


def prune_leaves(cand_leaf, cand_node, v):
    l = cand_leaf[:, 0] == v
    l = cand_leaf[l, 1:3]
    n = cand_node[:, 0] == v
    n, s = cand_node[n, 1:3], cand_node[n, 3]
    d = spspat.distance.cdist(l, n)
    d = d.min(1)
    s = s.max()
    return l[d < s]


def artificial3d():
    fname = '/home/rhein/mnt/drmaize/image_data/013SLB/microimages/reconstructed/SEG/exp013SLBp03wD3rf001.ome.tif.npz'

    with np.load(fname) as data:
        data = dict(data)
        skel = data['skel']

    imz = utils.get_tif('/home/rhein/PycharmProjects/drmaize/exp013SLBp03wD3rf001.ome.tif')
    imz = utils.imscale(imz, (1,) + (.5,) * 2)
    data['im'] = imz.max(0)

    wnd = 2 ** 6
    mx = spim.uniform_filter(skel.astype(float), 2 * wnd + 1, mode='constant')
    mx = mx.argmax()
    mx = np.unravel_index(mx, skel.shape)

    slc = np.s_[mx[0] - wnd:mx[0] + wnd + 1, mx[1] - wnd:mx[1] + wnd + 1]

    for k in data:
        plt.figure(k)
        plt.imshow(data[k][slc], 'gray')

    skel = skel[slc]

    # fig = plt.figure()
    # ax = fig.add_subplot(111, projection='3d')
    # ys, xs = skel.nonzero()
    # zs = imz.argmax(0)[skel != 0]
    # ax.scatter(xs, ys, zs)

    plt.figure()
    plt.subplot(131), plt.hist((imz.argmax(0))[slc].flat, bins=22, range=(-.5, 21.5))
    plt.subplot(132), plt.hist((imz.argmax(0) * data['seg'])[slc].flat, bins=22, range=(-.5, 21.5))
    plt.subplot(133), plt.hist((imz.argmax(0) * data['skel'])[slc].flat, bins=22, range=(-.5, 21.5))

    return plt.show()

    depths = np.zeros_like(skel, float)

    labels, num_labels = spim.label(skel, np.ones((3, 3), bool))
    slcs = spim.find_objects(labels)

    for slc in slcs:
        obj = skel[slc]
        obj_ind = np.transpose(obj.nonzero())
        seed = spim.center_of_mass(obj)
        seed = cdist((seed,), obj_ind)[0].argmin()
        seed = tuple(obj_ind[seed])

        obj_dpth = depths[slc]
        obj_dpth[seed] = 1

        fringe = spim.binary_dilation(obj_dpth != 0, np.ones((3, 3), bool))
        fringe ^= obj_dpth != 0
        fringe &= obj != 0

        while fringe.any():
            obj_dpth[fringe] = obj_dpth.max() + 1
            fringe = spim.binary_dilation(obj_dpth != 0, np.ones((3, 3), bool))
            fringe ^= obj_dpth != 0
            fringe &= obj != 0

            # while fringe.any():
            # pass

    # Y, X = skel.nonzero()
    #
    # Z = np.zeros_like(Y)
    # for i in range(wnd):
    # Z[np.random.random(Z.shape) < .1] += 1

    # fig = plt.figure()
    # Axes3D
    # ax = fig.add_subplot(111, projection='3d')
    # ax.scatter(X, Y, Z, c='r', marker='.')  # , c=c, marker=m)
    #
    # ax.set_xlabel('X Label')
    # ax.set_ylabel('Y Label')
    # ax.set_zlabel('Z Label')

    depths /= depths.ptp()
    depths *= wnd + 1
    depths = depths.astype(int)

    plt.figure()
    plt.imshow(depths, 'gray')

    # fig = plt.figure()
    # ims = []
    # frame = np.zeros_like(depths)
    # for i in range(wnd):
    # frame[depths == i + 1] = 1
    # im = plt.imshow(frame.copy(), 'gray')
    # ims.append([im])
    # ani = animation.ArtistAnimation(fig, ims, interval=100, blit=True, repeat_delay=100)
    # ani.save('dynamic_images.mp4')

    return plt.show()


def mlab_test():
    """Test surf on regularly spaced co-ordinates like MayaVi."""
    def f(x, y):
        sin, cos = np.sin, np.cos
        return sin(x + y) + sin(2 * x - y) + cos(3 * x + 4 * y)

    x, y = np.mgrid[-7.:7.05:0.1, -5.:5.05:0.05]
    s = mlab.surf(x, y, f)
    # cs = contour_surf(x, y, f, contour_z=0)
    
    mlab.show()
    
    return s
    


def main():
    pipeline()


if __name__ == '__main__':
    os.system("taskset -p 0xFFFFFFFF %d" % os.getpid())
    Axes3D

    for f in os.listdir('/dev/shm'):
        if 'shmmap' in f:
            os.remove('/dev/shm/' + f)

    statvfs = os.statvfs('/dev/shm')
    if (statvfs.f_frsize * statvfs.f_bavail / 1024. ** 3) < 44:
        raise Exception(
            'Shared memory is running low.  try: sudo mount -o remount,size=100% /run/shm/')

    javabridge.start_vm(args=[], class_path=bioformats.JARS)
    try:
        main()
    finally:
        javabridge.kill_vm()
