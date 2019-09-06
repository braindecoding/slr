<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        Brain Decoder Toolbox  ver. 1.2

                                           updated on 2010/10/01

_______________________________________________________________________________
Introduction
~~~~~~~~~~~~
The Brain Decoder Toolbox (BDTB) is a suite of MATLAB functions to 'decode'
brain activity. BDTB learns the difference of brain activity patterns, and
classifies brain activity by the result of learning.


_______________________________________________________________________________
Directory structure
~~~~~~~~~~~~~~~~~~~
When you unzip the file, you'll get following directories and files.

BDTB-1.2/
  |- decoder/
  |    |- fmri/     : functions specialized for fMRI data
  |    |- general/  : functions specialized for BDTB
  |    |- utility/  : practical functions
  |
  |- addpath_bdtb.m : function to add path of above directories
  |- readme.txt     : this file
  |
  (full ver. only)
  |- open/
       |- liblinear-1.7
       |- libsvm-mat-3.0-1
       |- osu_svm3.00
       |- spm5

Some of functions in 'fmri' directory require 'SPM5'.
Now, BDTB can use 'LIBLINEAR', 'LIBSVM', 'OSU-SVM' and 'SLR' to decode brain
information.

  LIBLINEAR : http://www.csie.ntu.edu.tw/~cjlin/liblinear/
  LIBSVM    : http://www.csie.ntu.edu.tw/~cjlin/libsvm
  OSU-SVM   : http://svm.sourceforge.net/download.shtml
  SPM5      : http://www.fil.ion.ucl.ac.uk/spm/software/spm5/
  SLR       : http://www.cns.atr.jp/~oyamashi/SLR_WEB.html


_______________________________________________________________________________
Installation
~~~~~~~~~~~~
To get installed BDTB, you just unzip the downloaded file wherever you like.

You may also download 'sample.zip' file, including sample programs and sample
fMRI data. Please start from the sample to learn how to use BDTB.


_______________________________________________________________________________
Reference
~~~~~~~~~
Kamitani, Y., and Tong, F. (2005).
 Decoding the visual and subjective contents of the human brain.
 Nat Neurosci 8, 679-685.


_______________________________________________________________________________
Copyright
~~~~~~~~~
BDTB is free but copyright software, distributed under the terms of the GNU
General Public Licence as published by the Free Software Foundation.
Further details on "copyleft" can be found at http://www.gnu.org/copyleft/.
No formal support or maintenance is provided or implied.


_______________________________________________________________________________
Feedback
~~~~~~~~
Any feedback is welcome. Please contact us at the address below.

Satoshi MURATA
Research Engineer in ATR Intl. Computational Neuroscience Labs
satoshi-m@atr.jp


_______________________________________________________________________________
History
~~~~~~~
2010/10/01
  BDTB ver 1.2
2010/08/10
  BDTB ver 1.1

2010/05/11
  BDTB ver 1.0
