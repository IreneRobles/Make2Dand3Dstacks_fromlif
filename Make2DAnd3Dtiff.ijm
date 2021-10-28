macro "Make2D_and_3D"{

var collectGarbageInterval = 1; // the garbage is collected after n Images
var collectGarbageCurrentIndex = 1; // increment variable for garbage collection
var collectGarbageWaitingTime = 100; // waiting time in milliseconds before garbage is collected
var collectGarbageRepetitionAttempts = 10; // repeats the garbage collection n times
var collectGarbageShowLogMessage = true; // defines whether or not a log entry will be made

//Select the directory where the lif files are
dir = getDirectory("Choose a directory");


//Get the parent directory and make there a forder to store images
parent_dir = dir + "/..";
tiff2D_dir = parent_dir + "/tiff2D/";
tiff3D_dir = parent_dir + "/tiff3D/";
File.makeDirectory(tiff2D_dir);
File.makeDirectory(tiff3D_dir);

setBatchMode(true);
// Go to the directory and get the image files
list_images = getFileList(dir);

for (i=0; i<list_images.length; i++){
	
	image_title = list_images[i];
	image_address = dir+image_title;
	//If it is a lif file...
	if((endsWith(image_title, ".lif")) ){

		print(image_title);
		
		run("Bio-Formats Macro Extensions");
      	Ext.setId(image_address);
      	Ext.getSeriesCount(seriesCount);


      	for (j=0;j<seriesCount;j++){
      		//ImageNo=j+1;
	
	 		Ext.setSeries(j);
	        Ext.getSeriesName(seriesName);
			run("Bio-Formats Importer", "open=" + image_address +" stack_order=XYCZT series_"+toString(j+1));    //MAKE SURE THIS IS j+1 otherwise leads to duplicated image.  
			Stack.getDimensions(width, height, channels, slices, frames);
      		
      		if (slices>1){

      		path = image_title;
	
			name=getTitle;

			///////Get shortened path name without the .lif  
				path2= path;
				dotIndex = lastIndexOf(path2, ".");													////Needs to be the same path! i.e. keep path2
				if (dotIndex!=-1)
				path2 = substring(path2, 0, dotIndex); 
				seriesName2= replace(seriesName, "/", "_");
				print(seriesName2);

				
				if((channels>1)){
				run("Split Channels");
				
				image_address3D = tiff3D_dir+path2;
				image_address2D = tiff2D_dir+path2;

				for(p=1; p<=channels ; p++){
								selectWindow("C"+p+"-"+name);
								saveAs("TIF", ""+image_address3D+"_"+seriesName2+"_C"+p);
								run("Z Project...", "projection=[Max Intensity]");
								saveAs("TIF", ""+image_address2D+"_"+seriesName2+"_C"+p+"_MAX");
								rename("C"+p);
							
							}
				}
				
				run("Reset...", "reset=[Undo Buffer]"); 
    			run("Reset...", "reset=[Locked Image]"); 


				while (nImages>0) {
          			close();
				};

				
	 			collectGarbageIfNecessary();

      		};


      	};
		
	};
};
setBatchMode(false);
showMessage("BatchProcessFinished");



	
};


function collectGarbageIfNecessary(){
if(collectGarbageCurrentIndex == collectGarbageInterval){
wait(collectGarbageWaitingTime);
for(i=0; i<collectGarbageRepetitionAttempts; i++){
wait(100);
run("Collect Garbage");
call("java.lang.System.gc");
}
if(collectGarbageShowLogMessage) print("...Collecting Garbage...");
print(collectGarbageCurrentIndex);
collectGarbageCurrentIndex = 1;
}else collectGarbageCurrentIndex++;
}