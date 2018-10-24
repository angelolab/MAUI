# MIBI_GUI

## Overview
* Introduction
* Background removal
* Denoising
* Aggregate removal

## Introduction
MIBI_GUI is a set of three graphical user interfaces (GUIs) for low-level analysis of MIBI data. The three steps of low-level analysis (after you've extracted your data) are background removal, denoising, and aggregate removal. Once you've downloaded or cloned this repository, all you need to do to use the GUI is to add the MIBI_GUI directory and all subdirectories to your MATLAB path. When doing low-level analysis of your MIBI data, you don't need to add your data to the MATLAB path, that's done inside of the GUI. If you clone this repository, you can get updates simply by navigating to the MIBI_GUI directory in terminal and typing 'git pull'.

The MIBI_GUI expects that your data will be structured in a certain way. You should have a directory structure that looks like this

    your_data
        panel
        extracted
            Point1
            Point2
            Point3
            ...
        no_background
        no_noise
        no_aggregates

Your Points can be either folders or they can be multilayer tiffs, MIBI_GUI doesn't care. For best results, it's recommended that you include a folder called "panel" on the same level as your extracted (and other) folders. Inside of this panel folder, you should put your panel.csv file (you don't have to rename the file, it just has to be a csv). This way, MIBI_GUI can keep track of the mass-order of your labels, making the results of your analysis compatible with other scripts that expect mass-ordered labels. If you fail to include this csv file, or put it in the wrong place, MIBI_GUI will still load your data, but it will sort the channels alphabetically, possibly making the results of your analysis incompatible with other scripts that expect mass-sorted channels.

If your Points are folders, then MIBI_GUI expects that somewhere inside of this folder there are individual TIF files for each channel. You have to tell MIBI_GUI the internal structure of your Points so it knows how to find them. For instance, if your Point folders are organized like this...

    Point#
        TIFs
            Au.tif
            dsDNA.tif
            CD45.tif
            ...

Then you should write just "TIFs" in pathext.txt (don't include the quotation marks). If your Point folders are organized like this...

    Point#
        extra_directory
            TIFs
                Au.tif
                dsDNA.tif
                CD45.tif
                ...

Then you should write "extra_directory/TIFs" in pathext.txt.

At each stage of low-level analysis, MIBI_GUI will write the results to an appropriate directory. So if you have your raw extracted data inside of "my_data/extracted/", then MIBI_GUI will write the background-removed data to "my_data/no_background/", the denoised data to "my_data/no_noise", and the aggregate-removed data to "my_data/no_aggregates". At each stage a log file will be saved inside of the respective folder to help you keep track of your work.


## Background removal GUI

First, run background_removal_gui.m, this opens the background removal GUI.
Now we have to add points we want to remove background from. Do this by clicking the “Add Point(s)” button in the “Manage Points and Select Background Channel” section, which opens a file navigator. Navigate to the folder that has your data, and select the points you want to remove the background from. Note that this can be either Point folders (as described above) or multilayer TIFFs.
Once we’ve added the points, we need to select a channel to use for selecting background removal parameters. To do this, select from the dropdown menu the channel you want to use. This channel be treated as the "background" channel, and the selected point/channel pair will be automatically displayed. Note that MIBI_GUI by default plots over the current figure, if you want new figures to be generated each time you select a channel (or point), deselect the "Reuse figure" button.

Now we can select background parameters in the “Background Removal Parameters” section. There are three parameters for generating a mask, the Gaussian radius of the blur, the Threshold we cutoff at, and the Background Cap. Enter the parameters you want to test on the currently selected point and channel combination, and press the “Test” button (if you want you select other point-channel pairs, press “Load”, and test the same parameters, or other parameters). The GUI will save a little history of what parameters you’ve loaded, which you can manage using the “Delete” and “Reload” buttons, which remove a selected set of parameters or loads the selected set of parameters for easy re-testing, respectively. When you press the “Test” button, an image of the generated mask and a histogram will be displayed. If you want a new figure to be generated each time you test, deselect the "Reuse figure" button in this section.

If we want we can evaluate our choice of background removal parameters on other point-channel combinations. To do so, look in the “Evaluation Parameters” section, and select the desired point from the “Point” dropdown menu, as well as the desired channel from the “Channel” dropdown menu. We can choose the value to be removed from the channel as well as the evaluation cap in the “Remove value” and “Evaluation Cap” boxes, respectively. When you’ve picked the parameters you want to evaluate, either click the “Evaluate Point” button to evaluate the desired parameters on the selected channel and point, displaying the before and after images for that channel and point, OR click the “Evaluate All Points” button to evaluate the desired parameters on the selected channel across ALL points, displaying the before and after for each point on the selected channel. As before, the GUI saves a history of your evaluation parameters, which can be managed with the “Delete” and “Reload” buttons.

Once you’re comfortable with the selected background removal parameters, you can look under the “Background Removal” section and click the “Remove Background” button. This opens up a file navigator window, which you can use to select which folder the log file your your background removal session can be saved. Once you select the folder you want the log file saved, the background parameters will be applied to all the channels in all the points you added in the first step, and will be saved into a new folder called “no_background” parallel to the folder your points were originally in, and the log file recording the parameters you used will be saved into the folder you selected. If you were feeling very confident in the previous steps and didn’t actually test the background parameters or evaluate the removal parameters but simply entered the parameters you wanted to use, click the “Load Params” button before you click the “Remove Background” button.


## Denoising GUI

First, run denoising_gui.m, this opens the denoising GUI.
Now we have to add points we want to denoise. Do this by clicking the “Add Point(s)” button in the “Manage Points” section, which opens a file navigator. Navigate to the folder that has your data, and select the points you want to denoise from. Note: these should be either Point folders or multi-layered TIFFs.

Once the Points have been loaded you will notice the large white box inside of the “Denoising Parameters” section populates with channel names and various numbers. This display indicates the currently chosen values for each channel (at the moment channels have the same values across all points). The slider marked “Threshold” can be used to change the nearest neighbor threshold for the selected channel, the threshold value can also be edited in the text box right next to the slider. You can change the range of values taken by the slider by clicking the “Threshold” button and modifying the minimum and maximum values. If you want to use a different k-val for the the nearest neighbor calculation, enter a different value in the “K-val” text box. You can easily switch between different channels by simply clicking on them, and if you want to look at channels on a different point, simply select the point under the “Manage Points” section.

To actually view the results of denoising, we need to do a k-nearest neighbors calculation on each image. Select the Points and Channels (either by double-clicking or highlighting and pressing the "Enter" key on your keyboard) that you want to do the calculation for, then press the "Run KNN" button. Depending on how many points and which channels you picked, this could take a while. Once the calculation is done, you can navigate around the point-channel combinations you ran the calculation for and adjust the Threshold (using the sliding bar or the textbox right next to it) and the display cap (this is just for viewing purposes and does not effect denoising in any way). If you the boundaries of the sliding bars are not to your liking, just click the buttons right next to them with the name of the parameter they control and change the minimum and maximum values of the sliding bar.

Whatever combination of point/channel is highlighted will be displayed on the screen. If you want to use a different k-val for the KNN calculation, simply select the channel you want to change the value for and enter the new value in the textbox labeled "K-val". When you click "Run KNN" again, the calculation will be updated to use this value.

If you decide you want to continue working later on denoising, you can click the “Save Run” button at the bottom of the GUI, which will prompt you to pick a folder location and file name to save your work. This will save the relevant information into a .mat file, which you can later open by clicking the “Load Run” button. Once you are satisfied with the denoising parameters you have selected, click the “Denoise” button. This will open a file navigator window which allows you to select the folder in which the log for this session will be saved. The log files contains information about the parameters you used for denoising. The denoising parameters will be applied to the points you loaded, and the results will be saved into a folder called “no_noise”, parallel to the folder you’re points are in.


## Aggregate removal GUI

First, run aggregate_removal_gui.m, this opens the aggregate removal GUI.
First we have to add points we want to remove aggregates from. Do this by clicking the “Add Point(s)” button in the “Manage Points” section, which opens a file navigator. Navigate to the folder that has your data, and select the points you want to remove the background from. Note: these should be either folders of TIFFs or multi-layered TIFFs.
Once we’ve added the points, we need to select a point to use for selecting aggregate removal parameters. To do this, click on the point you want to use and click the “Select” button. This will select the desired point and plot it for your viewing convenience, applying some default aggregate removal parameters.

As with the denoising GUI, you will notice a large white box populate with channel names and numbers after you have selected a point. These indicate the aggregate removal parameters for each channel. These parameters (“Threshold”, “Radius”, and “Cap”) can be modified with their respective sliders or text boxes. You can change the ranges of each of these sliders by clicking on the buttons near the sliders and entering new values for the minimum and maximum values. Changes to the values will be more or less instantaneously. As with the denoising GUI, you can save and reload your work mid-run using the “Save Run” and “Load Run” buttons. You can double click on a channel to mark (or unmark) it, as a visual aid for you when going through many channels, in case you find it hard to remember what channels you have already worked on. Once you are satisfied with the aggregate removal parameters you have selected, click the “Remove Aggregates” button, which will open a file navigator window, allowing you to select which folder the log file for this run will be save in. Once you have selected this location, the aggregate removal parameters will be applied and the results saved inside of a folder called “no_aggregates”, parallel to the folder in which your original points were stored.
