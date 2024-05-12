# Third Wave Librarian
The 3rd Wave synthesizer can store 500 patches in 5 banks of 100 each. This tool can load all of them at once and allows them to be re-organised. Additionally, any bank can be loaded into any of the 5 lanes of the tool, enabling five-way operations between arbitrary banks. A new bank can also be built from existing ones.

The librarian works with files, not with MIDI. You can mount the synthesizer as a drive over USB and copy the banks to your disk. After organising them with this tool, you can copy them back the same way.

There might be bugs. Please back up your patch files before using this tool on them. The tool can edit the patch names (inside the files), can rename the files and both copy and move them on disk. Note that copying a patch also creates a new copy of the patch file.

The tool expects a flat list of patch files within one directory per bank. The file names are expected to end with NNN.PRO, where NNN is a 3 digit, zero-padded number like 001. The sequence is expected to go from 001 upwards, with each file name incrementing the number by 1. Any part of the file name before NNN.PRO will be stripped away upon save to ensure internal tool consistency.

The tool does not currently verify that the patch name is valid when a patch is renamed.

![Screenshot](https://github.com/kimsand/ThirdWaveLibrarian/blob/4ec31972c4de5bd46d8416eadc4ad05abf123af7/images/ThirdWaveLibrarian.png)

Features:
* Load all 5 banks at once from their root folder on disk.
* Load a bank individually into any of the 5 lanes.
* Reorder patches within a lane by drag-and-drop.
* Move patches between banks, or within a bank, by cut-and-paste.
* Copy patches between banks, or within a bank, by copy-and-paste.
* Rename patches by clicking on the name to enable edit (or pressing enter).
* Create a new bank by pasting patches into an empty bank.
* Save the reorganised and/or created banks back to disk.

Wish list:
* Move patches between banks by drag-and-drop.
* Wavetable dependency list, showing which patches use each wavetable.
* Repository with all patches.
* Duplicate handling.
* Patch diffing.
