import sublime
import sublime_plugin
import re

# Simple ERM inline comment indention and format plugin by Zur13
# Allows to indent ERM comment lines which are located after ERM command !!, !#, !$, !? and terminated by the ";"
# Allows to change style of ERM comments between [] and //
# Allows to collect variables changed in ERM line into comment
# Allows to prepare comment according to preffered add settings (add [] or add //)
# Add this keybindings to use the command:
#  { "keys": ["alt+f"], "command": "erm_format_inline_comment", "args": {"targetIdent": 40, "removeDoubleSlashes":1, "surroundBySquareBrackets":1, "removeSquareBrackets":0, "addDoubleSlashes":0, "collectVars":0 , "prepareComment":0} },  
#  { "keys": ["alt+shift+f"], "command": "erm_format_inline_comment", "args": {"targetIdent": -1, "removeDoubleSlashes":1, "surroundBySquareBrackets":1, "removeSquareBrackets":0, "addDoubleSlashes":0, "collectVars":0, "prepareComment":0} },
#  { "keys": ["ctrl+alt+f"], "command": "erm_format_inline_comment", "args": {"targetIdent": -1, "removeDoubleSlashes":1, "surroundBySquareBrackets":1, "removeSquareBrackets":0, "addDoubleSlashes":0, "collectVars":1, "prepareComment":1} }
#

class ErmFormatInlineCommentCommand(sublime_plugin.TextCommand):
    def findCodeBodyEnd(self, lineTxt):
        ermCommandStart1, ermCommandStart2, ermCommandStart3, ermCommandStart4 = '!', '#', '$', '?'
        lineLen = len(lineTxt)
        # index of the last erm command start sequence !!, !#, !$ or !? in this line
        idxOfLastErmCommandStart = -1
        # index of the first semicolon after the last erm command start sequence 
        idxOfErmCodeEnd = -1
        textBlockOpened = 0
        if lineLen > 0:
            for idx in range(0 , lineLen):
                nextIdx = idx + 1
                if lineTxt[idx] == '^':
                    if textBlockOpened == 1:
                        textBlockOpened = 0
                    else:
                        textBlockOpened = 1
                if textBlockOpened == 0:
                    if lineTxt[idx] == ';' and idxOfErmCodeEnd == -1:
                        idxOfErmCodeEnd = idx
                    if nextIdx <= lineLen and lineTxt[idx] == '!':
                        if lineTxt[nextIdx] == ermCommandStart1 or lineTxt[nextIdx] == ermCommandStart2 or lineTxt[nextIdx] == ermCommandStart3 or lineTxt[nextIdx] == ermCommandStart4:
                            idxOfLastErmCommandStart = idx
                            idxOfErmCodeEnd = -1
        return idxOfLastErmCommandStart, idxOfErmCodeEnd

    def findCommentStart(self, lineTxt, idxOfErmCodeEnd):
        lineLen = len(lineTxt)
        # number of whitespaces between code end and comment start
        wspaceCnt = 0
        # index of the first comment symbol
        idxStartComment = -1
        # indexes of pre comment post code whitespace sequence 
        idxStartWspace = idxOfErmCodeEnd +1
        idxEndWspace = idxOfErmCodeEnd +1

        for idx in range(idxOfErmCodeEnd+1, lineLen):
            if lineTxt[idx] == ' ' or lineTxt[idx] == '\t':
                wspaceCnt = wspaceCnt + 1
                idxEndWspace = idx
            else:
                idxStartComment = idx
                if wspaceCnt < 1:
                    idxStartWspace = -1
                    idxEndWspace = -1
                break
        return wspaceCnt, idxStartComment, idxStartWspace, idxEndWspace

    def tryToRemoveExtraWspaces(self, lineTxt, idxOfErmCodeEnd, wspaceCnt, idxStartComment, idxStartWspace, idxEndWspace, targetCommentIndention, line, invertReplacesList):
        lineLen = len(lineTxt)
        wspacesRegex = re.compile(r'[ \t]+')

        deleteStartIdx = idxStartWspace
        deleteEndIdx = idxEndWspace + 1
        if deleteStartIdx < targetCommentIndention:
            deleteStartIdx = targetCommentIndention
        print('  >> deleteStartIdx=' + str(deleteStartIdx))
        print('  >> deleteEndIdx=' + str(deleteEndIdx))
        if deleteStartIdx < deleteEndIdx and wspacesRegex.match( lineTxt[deleteStartIdx:deleteEndIdx] ):
            resLine = lineTxt[0:deleteStartIdx] + lineTxt[deleteEndIdx:lineLen]
            resLineLen = len(resLine)
            if idxOfErmCodeEnd > targetCommentIndention and idxStartComment > targetCommentIndention and resLineLen > deleteStartIdx:
                #add 1 extra wspace if code block ends after target comment indention
                resLine = resLine[0:deleteStartIdx] + ' ' + resLine[deleteStartIdx:resLineLen]
            print('  >> Original line             : '+lineTxt)
            print('  >> Removed excess whitespaces: '+resLine)
            # Save line for later replacement
            return [(line, resLine)] + invertReplacesList
        return invertReplacesList

    def tryToAddExtraWspaces(self, lineTxt, idxOfErmCodeEnd, wspaceCnt, idxStartComment, idxStartWspace, idxEndWspace, targetCommentIndention, line, invertReplacesList):
        resLine = lineTxt
        additionalWhitespaces = targetCommentIndention - idxStartComment
        for idx in range(0, additionalWhitespaces):
            lineLenNew = len(resLine)  
            resLine = resLine[0:idxStartComment] + ' ' + resLine[idxStartComment:lineLenNew];
        print('  >> Original line             : '+lineTxt)
        print('  >> Added required whitespaces: '+resLine)
        # Save line for later replacement
        return [(line, resLine)] + invertReplacesList

    def tryToAddOneExtraWspace(self, lineTxt, idxOfErmCodeEnd, wspaceCnt, idxStartComment, idxStartWspace, idxEndWspace, targetCommentIndention, line, invertReplacesList):
        resLine = lineTxt
        lineLenNew = len(resLine)  
        resLine = resLine[0:idxStartComment] + ' ' + resLine[idxStartComment:lineLenNew];
        print('  >> Original line             : '+lineTxt)
        print('  >> Added 1 whitespace: '+resLine)
        # Save line for later replacement
        return [(line, resLine)] + invertReplacesList

    def fixMultilineIndention(self, edit, targetCommentIndention):
        invertReplacesList = []

        # Walk through each region in the selection
        for region in self.view.sel():
            for linePartialMulti in self.view.lines(region):
                # Expand the region to the full line it resides on, excluding the newline
                line = self.view.line(linePartialMulti)

                # Extract the string for the line, and add a newline
                lineTxt = self.view.substr(line)
                print('  >> ')
                print('  >> Check line comment indention: ' + lineTxt)
                # Measuring line finding comment position if any
                lineLen = len(lineTxt)

                if lineLen > 0 and not '\n' in lineTxt:
                    idxOfLastErmCommandStart, idxOfErmCodeEnd = self.findCodeBodyEnd(lineTxt)
                    print('  >> idxOfLastErmCommandStart=', idxOfLastErmCommandStart)
                    print('  >> idxOfErmCodeEnd=', idxOfErmCodeEnd)

                    if idxOfLastErmCommandStart >= 0 and idxOfErmCodeEnd > 0 and idxOfLastErmCommandStart < idxOfErmCodeEnd:
                        wspaceCnt, idxStartComment, idxStartWspace, idxEndWspace = self.findCommentStart(lineTxt, idxOfErmCodeEnd)
                        print('  >> idxStartComment=', idxStartComment)
                        print('  >> wspaceCnt=', wspaceCnt)
                        print('  >> idxStartWspace=', idxStartWspace)
                        print('  >> idxEndWspace=', idxEndWspace)
                        if idxStartComment >= 0 and idxOfErmCodeEnd < idxStartComment:                            
                            if idxStartComment > targetCommentIndention and wspaceCnt > 0 and idxStartWspace > 0 and idxStartWspace <= idxEndWspace:
                                invertReplacesList = self.tryToRemoveExtraWspaces(lineTxt, idxOfErmCodeEnd, wspaceCnt, idxStartComment, idxStartWspace, idxEndWspace, targetCommentIndention, line, invertReplacesList)
                            elif idxStartComment < targetCommentIndention:
                                invertReplacesList = self.tryToAddExtraWspaces(lineTxt, idxOfErmCodeEnd, wspaceCnt, idxStartComment, idxStartWspace, idxEndWspace, targetCommentIndention, line, invertReplacesList)
                            elif idxOfErmCodeEnd > targetCommentIndention and idxOfErmCodeEnd+1 == idxStartComment:
                                invertReplacesList = self.tryToAddOneExtraWspace(lineTxt, idxOfErmCodeEnd, wspaceCnt, idxStartComment, idxStartWspace, idxEndWspace, targetCommentIndention, line, invertReplacesList)
        # Apply line replacements
        for line, resLine in invertReplacesList:
            self.view.replace(edit, line, resLine)

    def findMaxLineIndention(self, lineTxt):
        maxLineIndention = -1
        lineLen = len(lineTxt)

        if lineLen > 0 and not '\n' in lineTxt:
            idxOfLastErmCommandStart, idxOfErmCodeEnd = self.findCodeBodyEnd(lineTxt)
            print('  >> idxOfLastErmCommandStart=', idxOfLastErmCommandStart)
            print('  >> idxOfErmCodeEnd=', idxOfErmCodeEnd)

            if idxOfLastErmCommandStart >= 0 and idxOfErmCodeEnd > 0 and idxOfLastErmCommandStart < idxOfErmCodeEnd:
                wspaceCnt, idxStartComment, idxStartWspace, idxEndWspace = self.findCommentStart(lineTxt, idxOfErmCodeEnd)
                print('  >> idxStartComment=', idxStartComment)
                if idxStartComment >= 0 and idxOfErmCodeEnd < idxStartComment and idxStartComment > maxLineIndention:
                    maxLineIndention = idxStartComment
                elif idxStartComment < 0 and idxOfErmCodeEnd+1 > maxLineIndention:
                    maxLineIndention = idxOfErmCodeEnd+1
        # return result
        return maxLineIndention

    def getPrevLineRegion(self, region):
        a = region.begin();
        b = a;
        firstLineOfRegion = self.view.full_line(sublime.Region(a, b))
        a = firstLineOfRegion.begin();
        b = a;
        if a > 0:
            a = a - 1;
            b = a;
            return self.view.line(sublime.Region(a, b))
        else:
            return firstLineOfRegion;

    def getNextLineRegion(self, region):
        b = region.end();
        a = b;
        lastLineOfRegion = self.view.full_line(sublime.Region(a, b))
        b = lastLineOfRegion.end() +1;
        a = b;
        return self.view.line(sublime.Region(a, b))

    def findMaxMultilineIndention(self, edit):
        maxMultilineIndention = 0
        selectedRegionsCnt = 0
        for region in self.view.sel():
            selectedRegionsCnt = selectedRegionsCnt + 1
        # Walk through each region in the selection
        for region in self.view.sel():
            if region.empty() and selectedRegionsCnt == 1:
                #extend region to next line and prev line
                lineMinus1 = self.getPrevLineRegion(region)
                lineMinus2 = self.getPrevLineRegion(lineMinus1)
                lineMinus3 = self.getPrevLineRegion(lineMinus2)
                linePlus1 = self.getNextLineRegion(region)
                linePlus2 = self.getNextLineRegion(linePlus1)
                linePlus3 = self.getNextLineRegion(linePlus2)
                a = lineMinus3.begin();
                b = linePlus3.end();

                newRegion = sublime.Region(a, b)
                for linePartialMulti in self.view.lines(newRegion):
                    # Expand the region to the full line it resides on, excluding the newline
                    line = self.view.line(linePartialMulti)

                    # Extract the string for the line, and add a newline
                    lineTxt = self.view.substr(line)
                    print('  >> ')
                    print('  >> Check line comment indention: ' + lineTxt)
                    # Measuring line finding comment position if any                
                    maxLineIndention = self.findMaxLineIndention(lineTxt)
                    if maxLineIndention > maxMultilineIndention:
                        maxMultilineIndention = maxLineIndention
            else:
                for linePartialMulti in self.view.lines(region):
                    # Expand the region to the full line it resides on, excluding the newline
                    line = self.view.line(linePartialMulti)

                    # Extract the string for the line, and add a newline
                    lineTxt = self.view.substr(line)
                    print('  >> ')
                    print('  >> Check line comment indention: ' + lineTxt)
                    # Measuring line finding comment position if any                
                    maxLineIndention = self.findMaxLineIndention(lineTxt)
                    if maxLineIndention > maxMultilineIndention:
                        maxMultilineIndention = maxLineIndention
        # return result
        return maxMultilineIndention

    def removeDoubleSlashComment(self, edit):
        invertReplacesList = []

        # Walk through each region in the selection
        for region in self.view.sel():
            for linePartialMulti in self.view.lines(region):
                # Expand the region to the full line it resides on, excluding the newline
                line = self.view.line(linePartialMulti)

                # Extract the string for the line, and add a newline
                lineTxt = self.view.substr(line)
                print('  >> ')
                print('  >> Check line comment for "//": ' + lineTxt)
                # Measuring line finding comment position if any
                lineLen = len(lineTxt)

                if lineLen > 0 and not '\n' in lineTxt:
                    idxOfLastErmCommandStart, idxOfErmCodeEnd = self.findCodeBodyEnd(lineTxt)
                    print('  >> idxOfLastErmCommandStart=', idxOfLastErmCommandStart)
                    print('  >> idxOfErmCodeEnd=', idxOfErmCodeEnd)

                    if idxOfLastErmCommandStart >= 0 and idxOfErmCodeEnd > 0 and idxOfLastErmCommandStart < idxOfErmCodeEnd:
                        wspaceCnt, idxStartComment, idxStartWspace, idxEndWspace = self.findCommentStart(lineTxt, idxOfErmCodeEnd)
                        print('  >> idxStartComment=', idxStartComment)

                        if idxStartComment >= 0 and idxOfErmCodeEnd < idxStartComment: 
                            part1 = lineTxt[0:idxOfErmCodeEnd+1]
                            part2 = lineTxt[idxOfErmCodeEnd+1:idxStartComment]
                            part3 = lineTxt[idxStartComment:lineLen]
                            part3Len = len(part3)
                            if part3Len >1 and part3[0] == '/'  and part3[1] == '/':
                                if part3Len > 2:
                                    part3 = part3[2:part3Len]
                                else:
                                    part3 = ''
                                resLine = part1 + part2 + part3
                                invertReplacesList = [(line, resLine)] + invertReplacesList

        # Apply line replacements
        for line, resLine in invertReplacesList:
            self.view.replace(edit, line, resLine)
        print('  >> ----------------- ')
        print('  >> ')

    def removeSquareBrackets(self, edit):
        invertReplacesList = []

        # Walk through each region in the selection
        for region in self.view.sel():
            for linePartialMulti in self.view.lines(region):
                # Expand the region to the full line it resides on, excluding the newline
                line = self.view.line(linePartialMulti)

                # Extract the string for the line, and add a newline
                lineTxt = self.view.substr(line)
                print('  >> ')
                print('  >> Remove [ ]": ' + lineTxt)
                # Measuring line finding comment position if any
                lineLen = len(lineTxt)

                if lineLen > 0 and not '\n' in lineTxt:
                    idxOfLastErmCommandStart, idxOfErmCodeEnd = self.findCodeBodyEnd(lineTxt)
                    print('  >> idxOfLastErmCommandStart=', idxOfLastErmCommandStart)
                    print('  >> idxOfErmCodeEnd=', idxOfErmCodeEnd)

                    if idxOfLastErmCommandStart >= 0 and idxOfErmCodeEnd > 0 and idxOfLastErmCommandStart < idxOfErmCodeEnd:
                        wspaceCnt, idxStartComment, idxStartWspace, idxEndWspace = self.findCommentStart(lineTxt, idxOfErmCodeEnd)
                        print('  >> idxStartComment=', idxStartComment)

                        if idxStartComment >= 0 and idxOfErmCodeEnd < idxStartComment: 
                            part1 = lineTxt[0:idxOfErmCodeEnd+1]
                            part2 = lineTxt[idxOfErmCodeEnd+1:idxStartComment]
                            part3 = lineTxt[idxStartComment:lineLen]
                            part3 = part3.rstrip()
                            part3Len = len(part3)
                            if part3Len >0 and part3[part3Len-1] == ']':
                                part3 = part3[0:part3Len-1]
                                part3Len = len(part3)
                            if part3Len >0 and part3[0] == '[':
                                part3 = part3[1:part3Len]
                                part3Len = len(part3)
                            resLine = part1 + part2 + part3
                            invertReplacesList = [(line, resLine)] + invertReplacesList

        # Apply line replacements
        for line, resLine in invertReplacesList:
            self.view.replace(edit, line, resLine)
        print('  >> ----------------- ')
        print('  >> ')

    def addSquareBrackets(self, edit):
        invertReplacesList = []

        # Walk through each region in the selection
        for region in self.view.sel():
            for linePartialMulti in self.view.lines(region):
                # Expand the region to the full line it resides on, excluding the newline
                line = self.view.line(linePartialMulti)

                # Extract the string for the line, and add a newline
                lineTxt = self.view.substr(line)
                print('  >> ')
                print('  >> Add [ ]": ' + lineTxt)
                # Measuring line finding comment position if any
                lineLen = len(lineTxt)

                if lineLen > 0 and not '\n' in lineTxt:
                    idxOfLastErmCommandStart, idxOfErmCodeEnd = self.findCodeBodyEnd(lineTxt)
                    print('  >> idxOfLastErmCommandStart=', idxOfLastErmCommandStart)
                    print('  >> idxOfErmCodeEnd=', idxOfErmCodeEnd)

                    if idxOfLastErmCommandStart >= 0 and idxOfErmCodeEnd > 0 and idxOfLastErmCommandStart < idxOfErmCodeEnd:
                        wspaceCnt, idxStartComment, idxStartWspace, idxEndWspace = self.findCommentStart(lineTxt, idxOfErmCodeEnd)
                        print('  >> idxStartComment=', idxStartComment)

                        if idxStartComment >= 0 and idxOfErmCodeEnd < idxStartComment: 
                            part1 = lineTxt[0:idxOfErmCodeEnd+1]
                            part2 = lineTxt[idxOfErmCodeEnd+1:idxStartComment]
                            part3 = lineTxt[idxStartComment:lineLen]
                            part3 = part3.rstrip()
                            part3Len = len(part3)
                            if part3Len >0 and part3[part3Len-1] != ']':
                                part3 = part3 + ']'
                                part3Len = len(part3)
                            if part3Len >0 and part3[0] != '[':
                                part3 = '[' + part3
                                part3Len = len(part3)
                            resLine = part1 + part2 + part3
                            invertReplacesList = [(line, resLine)] + invertReplacesList

        # Apply line replacements
        for line, resLine in invertReplacesList:
            self.view.replace(edit, line, resLine)
        print('  >> ----------------- ')
        print('  >> ')

    def addDoubleSlashes(self, edit):
        invertReplacesList = []

        # Walk through each region in the selection
        for region in self.view.sel():
            for linePartialMulti in self.view.lines(region):
                # Expand the region to the full line it resides on, excluding the newline
                line = self.view.line(linePartialMulti)

                # Extract the string for the line, and add a newline
                lineTxt = self.view.substr(line)
                print('  >> ')
                print('  >> Add "// ": ' + lineTxt)
                # Measuring line finding comment position if any
                lineLen = len(lineTxt)

                if lineLen > 0 and not '\n' in lineTxt:
                    idxOfLastErmCommandStart, idxOfErmCodeEnd = self.findCodeBodyEnd(lineTxt)
                    print('  >> idxOfLastErmCommandStart=', idxOfLastErmCommandStart)
                    print('  >> idxOfErmCodeEnd=', idxOfErmCodeEnd)

                    if idxOfLastErmCommandStart >= 0 and idxOfErmCodeEnd > 0 and idxOfLastErmCommandStart < idxOfErmCodeEnd:
                        wspaceCnt, idxStartComment, idxStartWspace, idxEndWspace = self.findCommentStart(lineTxt, idxOfErmCodeEnd)
                        print('  >> idxStartComment=', idxStartComment)

                        if idxStartComment >= 0 and idxOfErmCodeEnd < idxStartComment: 
                            part1 = lineTxt[0:idxOfErmCodeEnd+1]
                            part2 = lineTxt[idxOfErmCodeEnd+1:idxStartComment]
                            part3 = lineTxt[idxStartComment:lineLen]
                            part3 = part3.rstrip()
                            part3Len = len(part3)
                            if part3Len >1 and part3[0:2] != '//':
                                part3 = '// ' + part3
                                part3Len = len(part3)
                            resLine = part1 + part2 + part3
                            invertReplacesList = [(line, resLine)] + invertReplacesList

        # Apply line replacements
        for line, resLine in invertReplacesList:
            self.view.replace(edit, line, resLine)
        print('  >> ----------------- ')
        print('  >> ')

    def ensureWhitespaceAfterDoubleSlashes(self, edit):
        invertReplacesList = []

        # Walk through each region in the selection
        for region in self.view.sel():
            for linePartialMulti in self.view.lines(region):
                # Expand the region to the full line it resides on, excluding the newline
                line = self.view.line(linePartialMulti)

                # Extract the string for the line, and add a newline
                lineTxt = self.view.substr(line)
                print('  >> ')
                print('  >> Ensure whitespaces after "// ": ' + lineTxt)
                # Measuring line finding comment position if any
                lineLen = len(lineTxt)

                if lineLen > 0 and not '\n' in lineTxt:
                    idxOfLastErmCommandStart, idxOfErmCodeEnd = self.findCodeBodyEnd(lineTxt)
                    print('  >> idxOfLastErmCommandStart=', idxOfLastErmCommandStart)
                    print('  >> idxOfErmCodeEnd=', idxOfErmCodeEnd)

                    if idxOfLastErmCommandStart >= 0 and idxOfErmCodeEnd > 0 and idxOfLastErmCommandStart < idxOfErmCodeEnd:
                        wspaceCnt, idxStartComment, idxStartWspace, idxEndWspace = self.findCommentStart(lineTxt, idxOfErmCodeEnd)
                        print('  >> idxStartComment=', idxStartComment)

                        if idxStartComment >= 0 and idxOfErmCodeEnd < idxStartComment: 
                            part1 = lineTxt[0:idxOfErmCodeEnd+1]
                            part2 = lineTxt[idxOfErmCodeEnd+1:idxStartComment]
                            part3 = lineTxt[idxStartComment:lineLen]
                            part3 = part3.rstrip()
                            part3Len = len(part3)
                            if part3Len >2 and part3[0:2] == '//' and part3[2] != ' ':
                                part3 = part3[0:2] + ' ' + part3[2:part3Len]
                                part3Len = len(part3)
                            elif part3Len == 2 and part3[0:2] == '//':
                                part3 = part3 + ' '
                                part3Len = len(part3)
                            resLine = part1 + part2 + part3
                            invertReplacesList = [(line, resLine)] + invertReplacesList

        # Apply line replacements
        for line, resLine in invertReplacesList:
            self.view.replace(edit, line, resLine)
        print('  >> ----------------- ')
        print('  >> ')

    def addChangedVarToComment(self, commentText, varText):
        lenCText = len(commentText)
        if lenCText>0:
            if commentText[0] == '[':
                return '[' + varText + ", " + commentText[1:lenCText]
            elif commentText[0] == '/' and lenCText>2 and commentText[1] == '/' and commentText[2] == ' ':
                return '// ' + varText + ", " + commentText[3:lenCText]
            elif commentText[0] == '/' and lenCText>1 and commentText[1] == '/':
                return '// ' + varText + ", " + commentText[2:lenCText]
            else:
                return varText + ", " + commentText
        else:
            return commentText + varText

    def addChangedVars(self, edit):
        invertReplacesList = []

        # Walk through each region in the selection
        for region in self.view.sel():
            for linePartialMulti in self.view.lines(region):
                # Expand the region to the full line it resides on, excluding the newline
                line = self.view.line(linePartialMulti)

                # Extract the string for the line, and add a newline
                lineTxt = self.view.substr(line)
                print('  >> ')
                print('  >> Check ERM for vars "?": ' + lineTxt)
                # Measuring line finding comment position if any
                lineLen = len(lineTxt)

                if lineLen > 0 and not '\n' in lineTxt:
                    idxOfLastErmCommandStart, idxOfErmCodeEnd = self.findCodeBodyEnd(lineTxt)
                    print('  >> idxOfLastErmCommandStart=', idxOfLastErmCommandStart)
                    print('  >> idxOfErmCodeEnd=', idxOfErmCodeEnd)

                    if idxOfLastErmCommandStart >= 0 and idxOfErmCodeEnd > 0 and idxOfLastErmCommandStart < idxOfErmCodeEnd:
                        wspaceCnt, idxStartComment, idxStartWspace, idxEndWspace = self.findCommentStart(lineTxt, idxOfErmCodeEnd)
                        print('  >> idxStartComment=', idxStartComment)

                        if idxStartComment >= 0 and idxOfErmCodeEnd < idxStartComment: 
                            part1 = lineTxt[0:idxOfErmCodeEnd+1]
                            part2 = lineTxt[idxOfErmCodeEnd+1:idxStartComment]
                            part3 = lineTxt[idxStartComment:lineLen]

                            #Find ?<var>
                            changedVars = re.findall('\?[a-z]-?[0-9]*', part1)
                            changedVars.reverse()

                            for var in changedVars:
                                print('     >>>>> FOUND VAR: ' + var)
                                varLen = len(var)
                                var = var
                                if varLen > 1:
                                    var = var[1:varLen]
                                    varLen = len(var)
                                    if varLen > 1 and not re.search(var, part3):
                                        part3 = self.addChangedVarToComment(part3, var)
                                    elif varLen == 1 and not re.search(var+', ', part3):
                                        part3 = self.addChangedVarToComment(part3, var)
                            
                            #Find IF<var>
                            changedVars = re.findall('VR[a-z]-?[0-9]*', part1)
                            changedVars.reverse()

                            for var in changedVars:
                                print('     >>>>> FOUND VAR: ' + var)
                                varLen = len(var)
                                var = var
                                if varLen > 2:
                                    var = var[2:varLen]
                                    varLen = len(var)
                                    if varLen > 1 and not re.search(var, part3):
                                        part3 = self.addChangedVarToComment(part3, var)
                                    elif varLen == 1 and not re.search(var+', ', part3):
                                        part3 = self.addChangedVarToComment(part3, var)

                            #Find IF:V<flag>
                            changedVars = re.findall('IF[^;]*:[^;]*V[0-9]+', part1)
                            changedVars.reverse()

                            for var in changedVars:
                                print('     >>>>> FOUND VAR FLAG: ' + var)
                                varLen = len(var)
                                var = var
                                if varLen > 2:
                                    var = re.sub('IF[^;]*:[^;]*V', '', var)
                                    var = 'flg#'+var
                                    varLen = len(var)
                                    if varLen > 1 and not re.search(var, part3):
                                        part3 = self.addChangedVarToComment(part3, var)
                                    elif varLen == 1 and not re.search(var+', ', part3):
                                        part3 = self.addChangedVarToComment(part3, var)

                            part3Len = len(part3)
                            resLine = part1 + part2 + part3
                            invertReplacesList = [(line, resLine)] + invertReplacesList

        # Apply line replacements
        for line, resLine in invertReplacesList:
            self.view.replace(edit, line, resLine)
        print('  >> ----------------- ')
        print('  >> ')

    def prepareComment(self, edit, targetCommentIndention, cCommentStyle):
        invertReplacesList = []

        # Walk through each region in the selection
        for region in self.view.sel():
            for linePartialMulti in self.view.lines(region):
                # Expand the region to the full line it resides on, excluding the newline
                line = self.view.line(linePartialMulti)

                # Extract the string for the line, and add a newline
                lineTxt = self.view.substr(line)
                print('  >> ')
                print('  >> Check ERM for vars "?": ' + lineTxt)
                # Measuring line finding comment position if any
                lineLen = len(lineTxt)

                if lineLen > 0 and not '\n' in lineTxt:
                    idxOfLastErmCommandStart, idxOfErmCodeEnd = self.findCodeBodyEnd(lineTxt)
                    print('  >> idxOfLastErmCommandStart=', idxOfLastErmCommandStart)
                    print('  >> idxOfErmCodeEnd=', idxOfErmCodeEnd)

                    if idxOfLastErmCommandStart >= 0 and idxOfErmCodeEnd > 0 and idxOfLastErmCommandStart < idxOfErmCodeEnd:
                        wspaceCnt, idxStartComment, idxStartWspace, idxEndWspace = self.findCommentStart(lineTxt, idxOfErmCodeEnd)
                        if idxStartComment < 0: 
                            #if no comment on the line prepare new comment
                            part1 = lineTxt[0:idxOfErmCodeEnd+1]
                            part2 = lineTxt[idxOfErmCodeEnd+1:lineLen]
                            
                            if len(part2) == 0 or not re.search('[^ ]+', part2):
                                #if part2 is empty or contains only whitespaces
                                if len(part2) < targetCommentIndention:
                                    additionalWhitespaces = targetCommentIndention - len(part2)
                                    for idx in range(0, additionalWhitespaces):
                                        part2 = part2 + ' '
                            if cCommentStyle == 0:
                                part2 = part2 + '[]'
                            else:
                                part2 = part2 + '// '
                            resLine = part1 + part2
                            invertReplacesList = [(line, resLine)] + invertReplacesList
        # Apply line replacements
        for line, resLine in invertReplacesList:
            self.view.replace(edit, line, resLine)
        print('  >> ----------------- ')
        print('  >> ')

    def moveCursorInsideComment(self, edit, surroundBySquareBrackets):
        maxMultilineIndention = 0
        selectedRegionsCnt = 0
        for region in self.view.sel():
            selectedRegionsCnt = selectedRegionsCnt + 1
        if selectedRegionsCnt > 1:
            return
        # Walk through each region in the selection
        for region in self.view.sel():
            if region.empty():
                line = self.view.line(region)
                b = line.end();
                a = b;
                if surroundBySquareBrackets == 1:
                    b = line.end() -1;
                    a = b;
                newRegion = sublime.Region(a, b)
                
                # Extract the string for the line, and add a newline
                lineTxt = self.view.substr(line)
                #print('  >> ')
                #print('  >> Check ERM for vars "?": ' + lineTxt)
                # Measuring line finding comment position if any
                lineLen = len(lineTxt)

                if lineLen > 0:
                    idxOfLastErmCommandStart, idxOfErmCodeEnd = self.findCodeBodyEnd(lineTxt)
                    #print('  >> idxOfLastErmCommandStart=', idxOfLastErmCommandStart)
                    #print('  >> idxOfErmCodeEnd=', idxOfErmCodeEnd)

                    if idxOfLastErmCommandStart >= 0 and idxOfErmCodeEnd > 0 and idxOfLastErmCommandStart < idxOfErmCodeEnd:
                        wspaceCnt, idxStartComment, idxStartWspace, idxEndWspace = self.findCommentStart(lineTxt, idxOfErmCodeEnd)
                        if idxStartComment >= 0: 
                            print('  >> ----------------- ')
                            print('  >> Moving cursor inside comment block', idxOfErmCodeEnd)
                            print('  >> ')
                            self.view.sel().clear()
                            self.view.sel().add(newRegion)
                            self.view.show(newRegion)

    def run(self, edit, targetIdent, removeDoubleSlashes, surroundBySquareBrackets, removeSquareBrackets, addDoubleSlashes, collectVars, prepareComment):
        print(' ');
        print('<<<<<<<<< Simple Erm Inline Comment Plugin by Zur13 >>>>>>>>>');
        print('  >> Target idention is: ' + str(targetIdent));
        print('  >> removeDoubleSlashes = ' + str(removeDoubleSlashes));
        print('  >> surroundBySquareBrackets = ' + str(surroundBySquareBrackets));
        print('  >> removeSquareBrackets = ' + str(removeSquareBrackets));
        print('  >> addDoubleSlashes = ' + str(addDoubleSlashes));
        print('  >> collectVars = ' + str(collectVars));
        print('  >> prepareComment = ' + str(prepareComment));
        targetCommentIndention = targetIdent
        cCommentStyle = addDoubleSlashes
        origSelection = self.view.sel();
        if removeDoubleSlashes == 1:
            self.removeDoubleSlashComment(edit)
        if removeSquareBrackets == 1:
            self.removeSquareBrackets(edit)
        if surroundBySquareBrackets == 1:
            self.addSquareBrackets(edit)
        if addDoubleSlashes == 1:
            self.addDoubleSlashes(edit)
        if cCommentStyle == 1:
            self.ensureWhitespaceAfterDoubleSlashes(edit)
        if prepareComment == 1:
            self.prepareComment(edit, targetCommentIndention, cCommentStyle)
        if collectVars == 1:
            self.addChangedVars(edit)
        if targetCommentIndention > -1:
            self.fixMultilineIndention(edit, targetCommentIndention)
        else:
            targetCommentIndention = 0
            self.fixMultilineIndention(edit, targetCommentIndention)
            targetCommentIndention = self.findMaxMultilineIndention(edit)
            if targetCommentIndention > 150:
                targetCommentIndention = 150;
            self.fixMultilineIndention(edit, targetCommentIndention)
        if prepareComment == 1:
            self.moveCursorInsideComment(edit, surroundBySquareBrackets)
        print('  >> END <<')

                    
        
