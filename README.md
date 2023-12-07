# Third Wave Librarian
The 3rd Wave synthesizer can store 500 patches in 5 banks of 100 each. This tool can load all the banks, display them side-by-side, reorder patches and move them between banks.

The librarian works with files, not with MIDI. You can mount the synthesizer as a drive over USB and copy the banks to your disk. After organising them with this tool, you can copy them back the same way.

There might be bugs. Please back up your patch files before using this tool on them. The tool does not edit the files (yet), but it does rename them and move them on disk.

The tool naively expects a flat list of patch files per folder. The expected file naming is NNN.PRO, where NNN is a 3 digit, zero-padded number like 001.

![Screenshot](https://raw.githubusercontent.com/kimsand/ThirdWaveLibrarian/master/images/ThirdWaveLibrarian.png)

Features:
* Load all 5 banks at once from their root folder on disk.
* Load a bank individually into any of the 5 lanes.
* Reorder patches within a lane by drag-and-drop or cut-and-paste.
* Move patches between banks by cut-and-paste.
* Save the reorganised banks back to disk.

Wish list:
* Error messages and robustness.
* Rename patches.
* Add patches to a bank.
* Move patches between banks by drag-and-drop.
* Wavetable dependency list, showing which patches use each wavetable.
* Repository with all patches.
* Duplicate handling.
* Patch diffing.
