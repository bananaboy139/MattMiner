#[
  DONE todo: import/export settings from json
  todo: specify .minecraft folder
  todo: specify new folder for mods
  DONE todo: move folders and create symlink
  todo: download changes to mod folder
]#
import os
import json

const
  mineCraftFolderJson = "Minecraft Folder"
  mattFolderJson = "Matt's Folder"

var 
  mineCraftFolder : string
  mattFolder : string


const settingsFile : string = "MattMiner.cfg"

#MineFolders are string array, first var for MinecraftFolder path, secound for MattFolder path
#this alows everything to be organised and easily readable.
type MineFolder = array[2, string]
var
  ModsFolder: MineFolder = [joinPath(mineCraftFolder, "Mods"), joinPath(mattFolder, "Mods")]
  ConfigFolder: MineFolder = [joinPath(mineCraftFolder, "Config"), joinPath(mattFolder, "Config")]
  ResourcePacksFolder: MineFolder = [joinPath(mineCraftFolder, "ResourcePacks"), joinPath(mattFolder, "ResourcePacks")]
  MineFolders: array[3, MineFolder] = [ModsFolder, ConfigFolder, ResourcePacksFolder]

proc SetFolders* (MinecraftFolder: string, MattFolder: string) {.cdecl, exportc, dynlib.} =
  mineCraftFolder = MinecraftFolder
  mattFolder = MattFolder

proc ExportSettings* () {.cdecl, exportc, dynlib.} =
  let jsonObject = %* {mineCraftFolderJson: mineCraftFolder, mattFolderJson: mattFolder}
  writeFile(settingsFile, $ jsonObject)

proc ImportSettings* () {.cdecl, exportc, dynlib.} =
  let parsedObject = parseFile(settingsFile)
  mineCraftFolder = parsedObject[mineCraftFolderJson].getStr
  mattFolder = parsedObject[mattFolderJson].getStr

proc SetupMattMiner* () {.cdecl, exportc, dynlib.} =
  #step 1, move all MineFolders to MattFolder location
  #step 2, create all symlinks
  for MFolder in MineFolders:
    moveDir(MFolder[1], MFolder[2])
    createSymlink(MFolder[2], MFolder[1])