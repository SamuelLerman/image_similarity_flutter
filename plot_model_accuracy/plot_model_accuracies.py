import csv
import numpy as np 
import matplotlib as mpl
import matplotlib.pyplot as plt
import matplotlib.font_manager as font_manager
import tqdm

mpl.rcParams['font.family']='serif'
cmfont = font_manager.FontProperties(fname=mpl.get_data_path() + '/fonts/ttf/cmr10.ttf')
mpl.rcParams['font.serif']=cmfont.get_name()
mpl.rcParams['mathtext.fontset']='cm'
mpl.rcParams['axes.unicode_minus']=False

SMALL_SIZE = 14
MEDIUM_SIZE = 18
BIGGER_SIZE = 22

plt.rc('font', size=SMALL_SIZE)          # controls default text sizes
plt.rc('axes', titlesize=BIGGER_SIZE, titleweight='bold')     # fontsize of the axes title
plt.rc('axes', labelsize=MEDIUM_SIZE)    # fontsize of the x and y labels
plt.rc('xtick', labelsize=MEDIUM_SIZE)    # fontsize of the tick labels
plt.rc('ytick', labelsize=MEDIUM_SIZE)    # fontsize of the tick labels
plt.rc('legend', fontsize=MEDIUM_SIZE)    # legend fontsize
plt.rc('figure', titlesize=BIGGER_SIZE) 

def mean(l):
    n = len(l)
    S = 0
    for el in l:
        S += el
    return S/n

def get_mean_accuracies(list_of_accuracies):
    """
    list_of_accuracies : List<List<float>>
    all of its elements must have same length
    """
    n = len(list_of_accuracies[0])
    res = [0]*n
    for i in range(n):
      mean_accuracy_i = mean([accuracy[i] for accuracy in list_of_accuracies])
      res[i] = mean_accuracy_i
    return res
  
def plot_accuracies(thresholds, performances_pos, performances_neg, ref_images_folder_name):
    fig, ax = plt.subplots()
    ax.set_xlabel("Thresholds of detection")
    ax.set_ylabel("Accuracy (in %)")
    ax.set_yticks(list(range(0,100,6)))
    plt.title("Accuracy as a function of the threshold of detection \n for the {} dataset".format(ref_images_folder_name))

    ax.plot(thresholds, np.array(performances_pos)*100, color='red', zorder=2, label='positive images')
    ax.scatter(thresholds, np.array(performances_pos)*100, color='red', zorder=3)

    ax.plot(thresholds, np.array(performances_neg)*100, color='blue', zorder=2, label='negative images')
    ax.scatter(thresholds, np.array(performances_neg)*100, color='blue', zorder=3)

    fig.set_facecolor('white')

    plt.grid(True, lw=0.5, zorder = 0)
    plt.legend()
    plt.show()

    
### If you want to load the model, import the deepranking_model.py in python_backend dir or create another file ###  
    
def generate_accuracies(positive_images_dir_path, negative_images_dir_path, ref_images_dir_path, threshold, model):
  """
  Computes the accuracy of the model over positive images and negative images
  You must pass:
  - the reference images directory path of the class you want to test
  - a dataset of positive images
  - a dataset of negative images
  - a threshold value 
  - the tensorflow model
  """
  images_pos = os.listdir(positive_images_dir_path)
  images_neg = os.listdir(negative_images_dir_path)
  images_ref = os.listdir(ref_images_dir_path)
  S_pos = 0
  for pos in tqdm(images_pos, position=0):
    for ref in images_ref:
      x = compare_images(os.path.join(ref_images_dir_path, ref), os.path.join(positive_images_dir_path, pos))
      if x < threshold:
        S_pos += 1
        break
  S_neg = 0
  for neg in tqdm(images_neg, position=0):
    for ref in images_ref:
      k = 1
      x = compare_images(os.path.join(ref_images_dir_path, ref), os.path.join(negative_images_dir_path, neg))
      if x < threshold:
        k = 0
        break
    S_neg += k
  perf_pos = S_pos/len(images_pos)
  perf_neg = S_neg/len(images_neg)
  return perf_pos, perf_neg
 
 

  
  
