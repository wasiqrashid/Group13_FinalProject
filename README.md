# Group13_FinalProject
Brain Tumor Detection and  Sizing in MRI Scans

Brain tumors are a common global issue with the potential to cause problems such as headaches, seizures, and cancer.
MRI scans are the most common modality for diagnosis currently. However, they have some major limitations.
An automated system may be quicker and more accurate than a traditional MRI scan.
Our Program uses image processing techniques to determine the presence, location, and size of a tumor from a brain MRI scan.
This can aid in future development of categorizing tumors as benign or malignant.



Instructions:

- Extract the Group13_Data.zip file, revealing two folders (tumor_images and no_tumor_images)
- Take all .jpg files from those folders and place them in a separate folder
- Place bme3053c_final_project_code.m into the same folder as the .jpg files, and set this as the working folder in MATLAB
- Run bme3053c_final_project_code.m in MATLAB
- For every input, "x.jpg", there will be an output, "Result x.jpg", saved to the same folder
- The "Result x.jpg" file will provide image analysis results, as well as a final output with the brain tumor highlighted and classification/size listed



The image is classified by the following metric:

No tumor: 0-5% of brain area.

Small tumor: 5-10% of brain area.

Developing tumor: 10-20% of brain area.

Developed tumor: 20-30% of brain area.

Massive tumor: >30% of brain area.



Authors: Kendall Moran, Abigail Misiura, Wasiq Rashid
