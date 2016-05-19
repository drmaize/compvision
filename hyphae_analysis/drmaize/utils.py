import hashlib
import heapq
import os
import pickle
import random
import shutil
import itertools
import mmap

from PIL import Image
import numpy as np
import scipy.ndimage as spim
import bioformats
import scipy.signal as spsig
import scipy.misc as spmisc
import scipy.stats as spstats
from lxml import etree
import time

__author__ = 'rhein'


def skel2graph(skel):
    leaves = [ \
        [[0, 0, 0],
         [0, 1, 1],
         [0, 0, 0]],
        [[0, 0, 0],
         [0, 1, 0],
         [0, 0, 1]],
        [[0, 0, 0],
         [0, 1, 1],
         [0, 0, 1]],
        [[0, 0, 0],
         [0, 1, 1],
         [0, 1, 1]]]
    edges = [ \
        [[1, 0, 1],
         [0, 1, 0],
         [0, 0, 0]],
        [[1, 0, 1],
         [0, 1, 1],
         [0, 0, 0]],
        [[1, 0, 1],
         [1, 1, 1],
         [0, 0, 0]],
        [[0, 1, 0],
         [0, 1, 1],
         [0, 0, 0]],
        [[0, 1, 0],
         [0, 1, 1],
         [0, 0, 1]],
        [[1, 1, 0],
         [0, 1, 1],
         [0, 0, 1]],
        [[0, 1, 0],
         [0, 1, 0],
         [0, 0, 1]],
        [[0, 1, 0],
         [0, 1, 0],
         [0, 1, 0]],
        [[0, 1, 0],
         [0, 1, 0],
         [0, 1, 1]],
        [[1, 1, 0],
         [0, 1, 0],
         [0, 1, 1]],
        [[1, 0, 0],
         [0, 1, 0],
         [0, 0, 1]],
        [[1, 0, 0],
         [0, 1, 1],
         [0, 0, 1]],
        [[1, 0, 0],
         [1, 1, 1],
         [0, 0, 1]]]

    def perm2d(k):
        ret = []
        k = np.asarray(k)
        for transp in (k.transpose(0, 1), k.transpose(1, 0)):
            for flip in (transp, transp[:, ::-1], transp[::-1, :], transp[::-1, ::-1]):
                ret.append(flip)
        return ret

    k = 2 ** np.arange(9).reshape((3, 3))
    skel_unq = spim.correlate((skel != 0).astype(int), k.astype(int), mode='constant')

    leaf = np.zeros_like(skel, bool)
    leaf_val = {(l1 * k).sum() for l0 in leaves for l1 in perm2d(l0)}
    for v in leaf_val:
        leaf |= skel_unq == v

    edge = np.zeros_like(skel, bool)
    edge_val = {(e1 * k).sum() for e0 in edges for e1 in perm2d(e0)}
    for v in edge_val:
        edge |= skel_unq == v

    node = (skel != 0) ^ leaf ^ edge

    return node, edge, leaf


def set_msk(msk, labels, l):
    msk[labels == l] = True


def unpad(array, pad_width):
    slc = tuple(slice(start, -stop) for (start, stop) in pad_width)
    return array[slc]


class add_out_arg(object):
    def __init__(self, function):
        self._function = function

    def __call__(self, *args, **kwargs):
        out = kwargs.pop('out')
        out[...] = self._function(*args, **kwargs)


def arr2mmap(a):
    sa = np.frombuffer(mmap.mmap(-1, a.nbytes), a.dtype)
    sa.shape = a.shape
    sa[...] = a
    return sa


def shm2arr(sa):
    return sa.copy()


def differentiation_kernel(order):
    return (-1) ** np.arange(order + 1) * spmisc.comb(order, np.arange(order + 1))


def gaussian_kernel(sigma, num_stds):
    k = np.ones((1,) * len(sigma), float)
    for i, s in enumerate(sigma):
        x = np.ceil(num_stds * s).astype(int)
        x = np.arange(-x, x + 1)
        px = spstats.norm.pdf(x, scale=s)
        px /= px.sum()
        shp = [1] * len(sigma)
        shp[i] = len(px)
        px.shape = tuple(shp)
        k = spsig.convolve(px, k)
    return k


def gaussian_differentiation_kernel(sigma, num_stds, order, delta, scale):
    """
    http://en.wikipedia.org/wiki/Scale_space#Gaussian_derivatives
    :param sigma:
    :param num_stds:
    :param order:
    :param delta:
    :param scale:
    :return:
    """
    delta = list(delta)
    g = gaussian_kernel(sigma, num_stds)
    d = np.ones((1,) * len(order))
    for i in range(len(order)):
        _d = differentiation_kernel(order[i]).astype(float)
        if len(_d) % 2 != 1:
            _d = (np.pad(_d, ((0, 1),), 'constant') + np.pad(_d, ((1, 0),), 'constant')) / 2.
            delta[i] *= 2
        _d /= delta[i] ** order[i]
        _d *= np.sqrt(scale[i]) ** order[i]
        shp = np.ones(len(order), int)
        shp[i] = _d.shape[0]
        _d.shape = shp
        d = spsig.convolve(d, _d)
    d = spsig.convolve(g, d)
    return d


def fft_binary_closing(image, selem):
    dilated = fft_binary_dilation(image, selem)
    out = fft_binary_erosion(dilated, selem)
    return out


def fft_binary_dilation(image, selem):
    selem = (selem != 0)
    binary = (image > 0)
    conv = spsig.fftconvolve(binary, selem, 'same')
    return conv > np.finfo(np.float32).eps


def fft_binary_erosion(image, selem):
    selem = (selem != 0)
    selem_sum = np.sum(selem)
    binary = (image > 0)
    pad_width = tuple((s / 2,) * 2 for s in selem.shape)
    binary = np.pad(binary, pad_width, 'constant', constant_values=True)
    conv = spsig.fftconvolve(binary, selem, 'valid')
    return conv >= (selem_sum - np.finfo(np.float32).eps)


def get_tif_res(tif_file):
    root = bioformats.get_omexml_metadata(tif_file)
    root = str(root)
    root = etree.fromstring(root)
    ns = root.nsmap[None]
    root = root.find('{{{ns}}}Image/{{{ns}}}Description'.format(ns=ns))
    root = root.text
    root = etree.fromstring(root)
    ns = root.nsmap[None]
    return tuple(
        float(root.find('{{{ns}}}Image/{{{ns}}}Pixels'.format(ns=ns)).get('PhysicalSize{}'.format(dim)))
        for dim in ('Z', 'Y', 'X'))


def imscale(im, scales, mode='nearest', cval=0.0):
    assert np.ndim(im) == len(scales)
    for i, scale in enumerate(scales):
        ind = np.linspace(0, im.shape[i], round(scale * im.shape[i]), False)
        ind += (im.shape[i] - ind[-1]) / 2.
        ind = ind.astype(int)
        if scale > 1:
            im = im.take(ind, i)
            sigma = np.sqrt((scale / 2.) ** 2 - .5 ** 2)
            im = spim.gaussian_filter1d(im, sigma, axis=i, mode=mode, cval=cval)
        elif scale == 1:
            im = im.take(ind, i)
        elif scale > 0:
            scale **= -1
            sigma = np.sqrt((scale / 2.) ** 2 - .5 ** 2)
            im = spim.gaussian_filter1d(im, sigma, axis=i, mode=mode, cval=cval)
            im = im.take(ind, i)
        else:
            raise ValueError
    return im


def get_tif(seq_fname):
    pim = Image.open(seq_fname)
    pages = itertools.count()
    tif = []
    for p in pages:
        try:
            pim.seek(p)
            page = np.copy(pim)
            tif.append(page)
        except EOFError:
            if len(tif) == 0:
                raise EOFError
            else:
                break

    ret = np.empty((p,) + page.shape, page.dtype)
    for i in range(p):
        ret[i] = tif[i]
    return ret


def file_cache(fname, cache_pth, max_size=None, refresh=False):
    if not os.path.isdir(cache_pth):
        os.makedirs(cache_pth)

    fname = os.path.realpath(fname)
    st1 = os.stat(fname)
    cache_id = (st1.st_size, st1.st_mtime, st1.st_ctime, fname)
    cache_id = hashlib.md5(pickle.dumps(cache_id)).hexdigest()
    ext = os.path.splitext(fname)[1]
    cache_fname = os.path.join(cache_pth, '{}{}'.format(cache_id, ext))
    
    if not refresh and os.path.exists(cache_fname):
        st2 = os.stat(cache_fname)
        if st1.st_size == st2.st_size and st1.st_mtime == st2.st_mtime:
            return cache_fname

    cache_sz = sum(os.path.getsize(os.path.join(cache_pth, f))
                   for f in os.listdir(cache_pth)
                   if os.path.isfile(os.path.join(cache_pth, f)))
    file_sz = os.path.getsize(fname)

    if max_size is not None:
        if file_sz > max_size:
            return fname

        h = [(os.path.getatime(os.path.join(cache_pth, f)), f)
             for f in os.listdir(cache_pth)
             if os.path.isfile(os.path.join(cache_pth, f))]
        heapq.heapify(h)

        while cache_sz + file_sz > max_size:
            rfname = heapq.heappop(h)[1]
            os.remove(os.path.join(cache_pth, rfname))
            # cache_sz = sum(os.path.getsize(os.path.join(cache_pth, f)) for f in os.listdir(cache_pth) if
            # os.path.isfile(os.path.join(cache_pth, f)))
            cache_sz -= os.path.getsize(os.path.join(cache_pth, rfname))

    shutil.copy2(fname, cache_fname)
    return cache_fname


def shuffle(seq, seed=None):
    if seed is None:
        seed = time.time()
    random.seed(seed)
    seq = [v for v in seq]
    random.shuffle(seq)
    return seq
