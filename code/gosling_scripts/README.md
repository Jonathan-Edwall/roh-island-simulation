# Gosling.js plots of empirical ROH-hotspots
To display Gosling.js plots of the empirical ROH-hotspots, store the .html and .js files in the Gosling_plots folder inside your Results directory. For example, with the Labrador Retriever dataset used in the development of this pipeline, the path from the root directory would be:
`~/results/ROH-Hotspots/empirical/labrador_retriever/Gosling_plots`

The **.html** file contains the main script, specifying which plots to be display (which **.js**-files to be used). The **.js** files handles the plot configurations for each plotted chromosome. In this example, only chromosomes containing a ROH hotspot are plotted.

Currently, you will need to manually specify the **.js** files in the .html script and each .js file must be manually configured to refer to and use the correct data files for the plot.


# Guide to Display the Gosling.js Plots

To display the plots, you will need to run a local server in the background.

As an example, you can use the Visual Studio Code (VS Code) extension called <b>'Live Server'</b>, available from this [link](https://marketplace.visualstudio.com/items?itemName=ritwickdey.LiveServer).

**Steps to set up the local server with 'Live Server':**
- **1: Download and install the 'Live Server' extension** in VS Code.  

- **2: Launch the plot** by right-clicking the .html file (e.g., **Empirical ROH Hotspots - gosling.html**) in VS Code and then select the **"Open with Live Server"** option.  
    This will open the plot in a web browser and display the ROH hotspot plots!
