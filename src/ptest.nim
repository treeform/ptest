## print-tester for nim

import os, strformat, strutils

var pwd = getCurrentDir()
var fail = false

for file in walkDirRec("."):
  if not file.endsWith("test.nim"): continue
  let
    tmp = file[0..^5] & ".test.tmp"
    text = file[0..^5] & ".test.txt"
  if not existsFile(text): continue
  echo " * ", file
  let err = execShellCmd(&"nim c -r --verbosity:0 {pwd}/{file} > {pwd}/{tmp}")
  if err != 0:
    echo "Failed to compile!"
    fail = true
  when defined(windows):
    discard execShellCmd(&"dos2unix {pwd}/{tmp}")
  let
    tmpData = readFile(tmp)
    textData = readFile(text)

  if tmpData != textData:
    echo "There is a difference"
    discard execShellCmd(&"git diff --no-index {pwd}/{text} {pwd}/{tmp}")
    fail = true

  removeFile(text)
  moveFile(tmp, text)

if fail:
  quit(0)
