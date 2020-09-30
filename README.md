# 2pToolbox by Leonardo Lupori

This collection of code is a toolbox that I wrote and adapted for 2P physiology experiments in mice in vivo.

# File Overview

The toolbox contains a collection of tools for data acquisition, preprocessing and analysis of all sorts of data present in a recording, and some code and infos on the software and hardware setup of the experimental setup. In particular:

### Subfolder Pupil
This subfolder contains the code used to detect, track and analyze the pupil size during the recording

### Subfolder Rotary encoder
This subfolder contains 3D printable projects to print a monodimensional 
treadmill for mice. The setup is thought to integrate with a standard thorlabs 
rigid stand (available [here](https://www.thorlabs.com/thorproduct.cfm?partnumber=MP150-MLSH)) 
that can be easily mounted on an optical table and allows flexibility being 
at the same time standardized lab equipment. The rotational motion is picked 
up by a rotary encoder that can be attached to the side of the 3Dprinted parts. 
The folder also contains Arduino code that allows to correctly read the rotary 
encoder and to output an analog value representing the angular position of 
the wheel. This code requires a microcontroller capable of true 
digital-to-analog (DAC) conversion. it has being tested and used successfully 
on an arduino Zero, but should work also on others boards (e.g., Teensy3.5)

### Subfolder Utilities
This subfolder contains functions of general utility that I used thoughout the rest of the toolbox

### OLD
Deprecated pieces of code

### GUIs
No functioning GUIs are used in the toolbox at the moment. This folder contains GUIs that are either in development, deprecated or not useful anymore
