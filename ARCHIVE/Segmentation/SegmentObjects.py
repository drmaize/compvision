# keras 2.0.8 and tensorflow 1.5 cuDNN 11 and
# numpy 1.19.5 and tifffile 2020.9.3 and scikit_image 0.17.2


import os
import argparse
import numpy as np
from skimage import io
from keras.models import model_from_json
from keras import backend as K
import tifffile as tf

K.set_image_dim_ordering('th')
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'

#Loads Keras model .json architecture and .h5 weights
def load_model_and_weights(architecture_path, weights_path):
    with open(architecture_path) as architecture_data:
        loaded_model = model_from_json(architecture_data.read())
        loaded_model.load_weights(weights_path)
    return loaded_model

#Given an image, model, and normalization params, normalizes the image and then sends it through the model
def processImage(image_to_process, model_to_use, normalize_factor_in, clip_factor):
    if normalize_factor_in < 0:
        image_to_process = image_to_process / np.mean(image_to_process)
        image_to_process = np.clip(image_to_process, 0, clip_factor)
    else:
        image_to_process = image_to_process / normalize_factor_in
        image_to_process = np.clip(image_to_process, 0, clip_factor)
    output = model_to_use.predict(image_to_process)

    try:
        im = output.reshape(image_to_process.shape[2], image_to_process.shape[3])
    except:
        im = output[:, :, 0].reshape(image_to_process.shape[2], image_to_process.shape[3])
    im = 255 * ((im - np.min(im)) / (np.max(im) - np.min(im)))

    processed_image = im.astype(np.uint8)
    return processed_image


def save_image_file(path, image_to_save):
    io.imsave(path, image_to_save)



if __name__ == "__main__":
    # Here are some example arguments to pass. Requires input/output image paths (stacks or single image) and path to model architecture and weights
    # -i D:\drmaize\FullSegmentation\test_images\e013SLBp03wA1x20_1505041720rf001.ome.tif -o D:\drmaize\FullSegmentation\fun_e013SLBp03wA1x20_1505041720rf001.ome.tif  -a D:\drmaize\FullSegmentation\fungal_architecture.json -w D:\drmaize\FullSegmentation\fungal_weights.h5 -n 1 -nc 255
    # -i D:\drmaize\FullSegmentation\test_images\e025SLBp01wA5x20_1610041600rl001_surface.png -o D:\drmaize\FullSegmentation\e025SLBp01wA5x20_1610041600rl001_surface.png -a D:\drmaize\FullSegmentation\cell_architecture.json -w D:\drmaize\FullSegmentation\cell_weights.h5
    parser = argparse.ArgumentParser()
    parser.add_argument("--input_path", "-i", type=str, default="", required=True,
                        help='Path to image to process')
    parser.add_argument("--output_path", "-o", type=str, default="", required=True,
                        help='Path to output to')
    parser.add_argument("--arch", "-a", type=str, default="", required=True,
                        help='Path to architecture of network in .json format, from Keras')
    parser.add_argument("--weights", "-w", type=str, default="", required=True,
                        help='Path to weights of network in .h5 format, from Keras')
    parser.add_argument("--normalize_factor", "-n", type=float, default=-1,
                        help='Value to normalize input image by. We used 120 as that was the mean of the dataset. If left blank, defaults to image mean')
    parser.add_argument("--normalize_clip", "-nc", type=float, default=1,
                        help='Is network trained on 0-1 or 0-255? For our trained detectors, fungus is 255, while cells and stomata are 1')

    args = parser.parse_args()
    input_path = args.input_path
    output_path = args.output_path
    arch = args.arch
    weights = args.weights
    normalize_factor = args.normalize_factor
    normalize_clip = args.normalize_clip

    print("Loading model: " + arch + ",  with weights: " + weights)
    model = load_model_and_weights(arch, weights)
    layers = model.layers
    input_shape = list(layers[0].batch_input_shape)
    input_shape[0] = 1  # batch size of 1
    input_shape = tuple(input_shape)
    imgx = input_shape[2]
    imgy = input_shape[3]

    stack_ii = 1
    if input_path.lower().endswith('.tif') or input_path.lower().endswith('.tiff'):
        with tf.TiffFile(input_path) as tif:
            for page in tif.pages:
                image = page.asarray()
                print("Processing image " + str(stack_ii) + "/" + str(len(tif.pages)) + " in tiff stack")
                image = image.astype('float32')[:imgx, :imgy].reshape(input_shape)
                out_im = processImage(image, model, normalize_factor, normalize_clip)
                print("Writing image output " + str(stack_ii) + "/" + str(len(tif.pages)) + " to: " + output_path)
                tf.imwrite(output_path, out_im, append=True)
                stack_ii = stack_ii + 1
    else:
        print("Processing image")
        image = io.imread(input_path).astype('float32')[:imgx, :imgy].reshape(input_shape)
        out_im = processImage(image, model, normalize_factor, normalize_clip)
        print("Writing output to: " + output_path)
        save_image_file(output_path, out_im)
