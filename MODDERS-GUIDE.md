## This is not a tutorial on how to create a custom character pre-workshop, but a guide on how to make them more distributable.

# How it works
The script uses the scripts that are in UMT and reads them IF they are .gml files (because reasons). So, this guide will help to port your mods so that they can be distirbuted easily.

## 1. Converting the scripts
First off, the first thing to note when dealing with ANY GML file or JSON file that you make for this loader is that you CANNOT use sprite NUMBERS. 

All you need to do to convert the numbers to names is to simply middle click the sprite number, then click the name in the dropdown that pops up.

<img width="646" height="221" alt="image" src="https://github.com/user-attachments/assets/cae46938-82c2-484b-96c0-be35ba21726e" />

Next, you want to copy the name that is at the top of the window of the script you wont to be a .GML file.

<img width="603" height="274" alt="image" src="https://github.com/user-attachments/assets/4562281e-1c5b-448f-b045-9e1d58a2f891" />

Finally, you want to create a new file, that is the EXACT NAME (aka the name you just copied) of the script you are converting then add ".GML" at the end.

<img width="233" height="32" alt="image" src="https://github.com/user-attachments/assets/e67fb5b5-73a2-4066-a095-541eb1a24851" />

For exmple, for the 'bair_stick' script this is what the file name  would be.

Then, you want to cocpy and paste the whole script, with no sprite numbers, into the file you just created. Then rinse, and repeat for all the scripts associated with your character.

## 2. Adding Sprites
This tool uses the 'ImportGraphicsAdvanced.csx' Script for importing sprites to the game. 

So, all you need to do is have the sprites be GIFs with names that are the same as the sprite you want them to be named, (ex. spr_bair_stick.gif) or have the sprites have their own folder with each of the frames being PNGs with "_frame" the frame number being frame as the name ("spr_bair_stick_0", "spr_bair_stick_1" etc.) . After you have all the sprites in GIF format or folder format (or PNG if the sprite doesn't have any frames) you can add them into their own folder labeled "My CC Animations" or whatever you want, or you can have them be in the same folder as the GML files.

<img width="606" height="484" alt="image" src="https://github.com/user-attachments/assets/a68c5713-16a1-4ae4-a9a5-62bc2b61f7c0" />

## 3. Making the Character Appear on the Select Screen
In order to have the Character appear on the select screen you need 2  JSON files, 

1. A file named "myCCName_data.json" which has the string for the character that is located in the "character_data" script

<img width="1117" height="37" alt="image" src="https://github.com/user-attachments/assets/025f8927-f9f3-4b82-857d-498dd59edc8f" />

It should only have the highlighted information in the file, nothing more nothing less. 2 things to note for this file is that **IT MUST END IN _DATA OR ELSE IT WILL NOT BE ADDED TO THE "CHARACTER_DATA" SCRIPT.** And, remember that all files in this loader **MUST** have sprite names instead of sprite numbers.

2. A file named "myCCName_portrait.json" which **ONLY CONTAINS THE NAME OF THE CHARACTER AS IT APPEARS IN THE "CHARACTER_DATA" SCRIPT WITH QUOTATION MARKS**

<img width="244" height="68" alt="image" src="https://github.com/user-attachments/assets/f46e49ce-86d1-48a3-89e3-2082cf1dcad2" />

Again, if the file does not end in _portrait **IT WILL NOT SHOW UP ON THE CHARACTER SELECT SCREEN** and it must have quotation marks around it as shown.

So after following this tutorial, your directory should look *similar* (not identical) to the following screenshot,

<img width="257" height="552" alt="image" src="https://github.com/user-attachments/assets/a0833c68-c690-4b64-9b74-5c1f6713876b" />

Make sure all the information is stored as you want it, but do note that if the GML files arent in the "Character Assets" folder while the script to import them into the game is running, then the script **WILL NOT BE IMPORTED.**
