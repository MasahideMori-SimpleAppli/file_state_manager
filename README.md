# file_state_manager

(en)Japanese ver is [here](https://github.com/MasahideMori-SimpleAppli/file_state_manager/blob/main/README_JA.md).  
(ja)この解説の日本語版は[ここ](https://github.com/MasahideMori-SimpleAppli/file_state_manager/blob/main/README_JA.md)にあります。

## Overview
This package allows you to easily undo and redo saved data in your application.
This package is not intended for tracking detailed change history.
Built for applications that are complex and potentially subject to high volumes of data changes.

## Usage
Please check out the Examples tab.

## Support
Basically no support.  
Please file an issue if you have any problems.  
This package is low priority, but may be fixed.

## About version control
The C part will be changed at the time of version upgrade.  
However, versions less than 1.0.0 may change the file structure regardless of the following rules.  
- Changes such as adding variables, structure change that cause problems when reading previous files.
    - C.X.X
- Adding methods, etc.
    - X.C.X
- Minor changes and bug fixes.
    - X.X.C

## License
This software is released under the MIT License, see LICENSE file.

## Copyright notice
The “Dart” name and “Flutter” name are trademarks of Google LLC.  
*The developer of this package is not Google LLC.