import sublime
import sublime_plugin
import re

# Simple ERM toggle code comment plugin by Zur13
# Allows to comment and uncomment ERM commands !!, !#, !$, !? 
# Add this keybindings to use the command:
#  { "keys": ["ctrl+alt+c"], "command": "erm_toggle_code_comment", "args": {} }
#
class ErmToggleCodeCommentCommand(sublime_plugin.TextCommand):
  def run(self, edit):
      print(' ');
      print('<<<<<<<<< Simple Erm Toggle Code Comment Plugin by Zur13 >>>>>>>>>');
      invertReplacesList = []
      isCommentIn = -1
      # Walk through each region in the selection
      for region in self.view.sel():
          for linePartialMulti in self.view.lines(region):
              # Expand the region to the full line it resides on, excluding the newline
              line = self.view.line(linePartialMulti)

              # Extract the string for the line, and add a newline
              lineTxt = self.view.substr(line)
              print('  >> ')
              #print('  >> Toggle code comment: ' + lineTxt)
              # Measuring line finding comment position if any
              lineLen = len(lineTxt)
              if isCommentIn == -1:
                  if lineLen > 0:
                      if re.search('\![\!\?\$\#]', lineTxt):
                          isCommentIn = 0
                      elif re.search('\*[\!\?\$\#]', lineTxt):
                          isCommentIn = 1
              if lineLen > 0:
                  if isCommentIn == 0 and re.search('\![\!\?\$\#]', lineTxt):
                      print('  >> Comment code   : ' + lineTxt)
                      resLine = re.sub('\!\!', '*!', lineTxt)
                      resLine = re.sub('\!\?', '*?', resLine)
                      resLine = re.sub('\!\$', '*$', resLine)
                      resLine = re.sub('\!\#', '*#', resLine)

                      invertReplacesList = [(line, resLine)] + invertReplacesList
                  elif isCommentIn == 1 and re.search('\*[\!\?\$\#]', lineTxt):
                      print('  >> Uncomment code : ' + lineTxt)
                      resLine = re.sub('\*\!', '!!', lineTxt)
                      resLine = re.sub('\*\?', '!?', resLine)
                      resLine = re.sub('\*\$', '!$', resLine)
                      resLine = re.sub('\*\#', '!#', resLine)

                      invertReplacesList = [(line, resLine)] + invertReplacesList
                  else:
                      print('  >> Do nothing with: ' + lineTxt)
      # Apply line replacements
      for line, resLine in invertReplacesList:
          self.view.replace(edit, line, resLine)
