## How to map F1 Key in SublimeText to open AutoIt documentation for the word under the keyboard cusor.


### 1. Install goto-documentation plugin

[Download ZIP from the goto-documentation github page](https://github.com/kemayo/sublime-text-2-goto-documentation) and unzip files to directory: `Sublime_Data_Dir\Packages\goto-documentation`.

* Note: although not specified, goto-documentation plugin works fine with both ST2 and ST3.
* If you need help finding your Sublime_Data_Dir, see [here](http://docs.sublimetext.info/en/latest/basic_concepts.html#the-data-directory).

### 2. Set key binding for F1
To the file  `Sublime_Data_Dir\Packages\User\Default (Windows).sublime-keymap`, add:

<pre>{ "keys": ["f1"], "command": "goto_documentation" },</pre>

### 3. Set goto-documentation command for autoit scope
To the file `Sublime_Data_Dir\Packages\goto-documentation\gotodocumentation.py`, add the following indented under "class GotoDocumentationCommand" (make sure it is correctly indented under the class since python is indent-sensitive).

* To have it open in the online documentation

<pre>	def autoit_doc(self, keyword, scope):
		open_url("http://www.autoitscript.com/autoit3/docs/functions/%s.htm" % keyword)</pre>

* To have it open in the help file documentation

<pre>	def autoit_doc(self, keyword, scope):
		cmd = ["hh.exe", r"mk:@MSITStore:C:\Program Files\AutoIt3\AutoIt3.chm::/html/functions/%s.htm" % keyword]
		subprocess.Popen(cmd)</pre>
