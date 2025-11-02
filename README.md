# Simplified Robocopy with GUI

A PowerShell script with a graphical user interface that activates **Robocopy** and allows the use of various command-line switches.

---

## Background

I often work with different computers that contain an enormous number of files and very deep folder paths, which Windows normally can’t handle.  
I was often in doubt and could hardly remember the different command-line switches — and which ones should be used by default when copying files normally.  

To make this easier, I created a PowerShell script that provides a graphical overlay for Robocopy and includes the most commonly used switches.

---

## Features

- Graphical user interface for Robocopy  
- Easy access to common command-line switches  
- Simplifies copying large file structures and long paths  
- Reduces the need to remember complex command syntax  

---

## Example

Here’s what the simplified Robocopy interface looks like:

![Simplified Robocopy GUI](Simplified%20Robocopy.png)

---

## Requirements

- Windows PowerShell  
- Administrator **privileges**

---

## Usage
- Run the .exe file (automatically elevates as admin)
- Run the PowerShell script as **Administrator** to ensure Robocopy can access all files and folders properly.

```powershell
# Example
Start-Process powershell -Verb RunAs -ArgumentList '.\Robocopy-GUI.ps1'
