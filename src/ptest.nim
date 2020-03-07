## print-tester for nim

import os, osproc, strformat, strutils, terminal

var pwd = getCurrentDir()
var
  fail = 0
  pass = 0
  skip = 0

for file in walkDirRec("."):
  if file.endsWith("ptest.nim"): continue
  if not file.endsWith("test.nim"): continue
  let
    tmp = pwd / file[0..^5] & ".test.tmp"
    text = pwd / file[0..^5] & ".test.txt"
    file = pwd / file
  let code = readFile(file)
  if "unittest" in code:
    let (output, err) = execCmdEx(&"nim c --verbosity:0 -r {file}")
    if err != 0:
      stdout.styledWrite(fgRed, "[fail] ")
      echo file
      inc fail
    else:
      stdout.styledWrite(fgGreen, "[pass] ")
      echo file
      inc pass
    continue

  if not existsFile(text):
    stdout.styledWrite(fgYellow, "[skip] ")
    echo file, " no corresponding ", text
    inc skip
    continue
  let homefolder = file.splitFile()[0]
  setCurrentDir(homefolder)
  let (output, err) = execCmdEx(&"nim c --verbosity:0 --hints:off -r {file}")
  writeFile(tmp, output)
  setCurrentDir(pwd)
  if err != 0:
    stdout.styledWrite(fgRed, "Failed to compile!\n")
    inc fail
    continue

  when defined(windows):
    discard execCmdEx(&"dos2unix {tmp}")

  let
    tmpData = readFile(tmp)
    textData = readFile(text)

  if tmpData != textData:
    stdout.styledWrite(fgRed, "[fail] ")
    echo file
    let (output, err) = execCmdEx(&"git diff --no-index {text} {tmp}")
    inc fail
  else:
    stdout.styledWrite(fgGreen, "[pass] ")
    echo file
    inc pass

  removeFile(text)
  moveFile(tmp, text)

echo &"passed {pass} failed {fail} skipped {skip}"

if fail > 0:
  stdout.styledWrite(fgRed, "*** failed ***")
  quit(0)
else:
  stdout.styledWrite(fgGreen, "*** passed ***")
