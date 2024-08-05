function Assert (Cond)
{
	if (!Cond)
	{
		var Error = ASSERT_VIOLATION;
	}
} // .function Assert

function ord (c)
{
	var	result	=	String(c).charCodeAt(0);
	Assert(!isNaN(result));
	return result;
} // .function ord

function set ()
{
	var
		Args		=	arguments,
		Arg			=	null,
		NumArgs	=	arguments.length,
		MinInd	=	0,
		MaxInd	=	0,
		ByteN		=	0,
		BitMask	=	0,
		b				=	0,
		result	=	[],
		i				=	0,
		y				=	0;
	for (i = 0; i < 8; i++)
	{
		result[i] = 0;
	}
	i	=	0;
	while (i < NumArgs)
	{
		Arg	=	arguments[i];
		if (Arg instanceof Array)
		{
			Assert(Arg.length === 2);
			MinInd	=	Arg[0];
			MaxInd	=	Arg[1];
			if (typeof(MinInd) === 'string')
			{
				MinInd = ord(MinInd);
			}
			if (typeof(MaxInd) === 'string')
			{
				MaxInd = ord(MaxInd);
			}
			Assert((MinInd <= MaxInd) && (MinInd >= 0) && (MaxInd <= 255));
			for (y = MinInd; y <= MaxInd; y++)
			{
				ByteN					=	(y / 32) | 0;
				BitMask				=	1 << (y % 32);
				result[ByteN]	=	result[ByteN] | BitMask;
			}
		}
		else
		{
			if (typeof(Arg) === 'string')
			{
				b	=	ord(Arg);
			}
			else if (typeof(Arg) === 'number')
			{
				b	=	Arg | 0;
			}
			else
			{
				Assert(false);
			}
			Assert((b >= 0) && (b <= 255));
			ByteN		=	(b / 32) | 0;
			BitMask	=	1 << (b % 32);
			result[ByteN] = result[ByteN] | BitMask;
		}
		i++;
	}
	return result;
} // .function set

function inset (c, Set)
{
	var
		MinInd	=	0,
		MaxInd	=	0,
		b				=	0,
		ByteN		=	0,
		BitMask	=	0;
	if (typeof(c) === 'string')
	{
		b	=	ord(c);
	}
	else
	{
		b	=	c;
	}
	if (b <= 255)
	{
		ByteN		=	parseInt(b / 32);
		BitMask	=	1 << (b % 32);
		return ((Set[ByteN] & BitMask) !== 0);
	}
	else
	{
		return false;
	}
} // .function inset

function addset (ASet, BSet) /* set */
{
	Assert(ASet instanceof Array);
	Assert(BSet instanceof Array);
	var
		result	=	[],
		i				=	0;
	for (i = 0; i < 8; i++)
	{
		result[i]	=	ASet[i] | BSet[i];
	}
	return result;
} // .function addset

function subset (ASet, BSet) /* set */
{
	Assert(ASet instanceof Array);
	Assert(BSet instanceof Array);
	var
		result	=	[],
		i				=	0;
	for (i = 0; i < 8; i++)
	{
		result[i]	=	ASet[i] & ~BSet[i];
	}
	return result;
} // .function subset

function TScanner ()
{
	this.Connect('');
}

TScanner.prototype.Connect = function (Buf)
{
	Assert(typeof(Buf) === 'string');
	this.Buf			=	Buf;
	this.Pos			=	0;
	this.Len			=	Buf.length;
	this.TextEnd	=	Buf.length === 0;
} // .function TScanner.Connect

TScanner.prototype.GetCurrChar = function () /* char or false */
{
	var	result	=	!this.TextEnd;
	if (result)
	{
		result	=	this.Buf.charAt(this.Pos);
	}
	return result;
} // .function TScanner.GetCurrChar

TScanner.prototype.GetCharAtPos = function (Pos) /* char or false */
{
	var	result	=	(Pos >= 0) && (Pos < this.Len);
	if (result)
	{
		result	=	this.Buf.charAt(Pos);
	}
	return result;
} // .function TScanner.GetCharAtPos

TScanner.prototype.GetCharAtRelPos = function (RelPos) /* char or false */
{
	return this.GetCharAtPos(this.Pos + RelPos);
} // .function TScanner.GetCharAtRelPos

TScanner.prototype.GetStrAtPos = function (StrLen, Pos) /* string */
{
	return this.Buf.slice(Pos, Pos + StrLen);
} // .function TScanner.GetStrAtPos

TScanner.prototype.GetStrAtRelPos = function (StrLen, RelPos) /* string */
{
	return this.GetStrAtPos(StrLen, this.Pos + RelPos);
} // .function TScanner.GetStrAtRelPos

TScanner.prototype.GotoNextChar = function () /* bool */
{
	this.Pos++;
	this.TextEnd	=	this.Pos >= this.Len;
	if (this.TextEnd)
	{
		this.Pos	=	this.Len;
	}
	return !this.TextEnd;
} // .function TScanner.GotoNextChar

TScanner.prototype.GotoPos = function (Pos) /* bool */
{
	var	result = (Pos >= 0) && (Pos < this.Len);
	if (result)
	{
		this.Pos	=	Pos;
	}
	return result;
} // .function TScanner.GotoPos

TScanner.prototype.GotoRelPos = function (RelPos) /* bool */
{
	return this.GotoPos(this.Pos + RelPos);
} // .function TScanner.GotoRelPos

TScanner.prototype.FindChar = function (c) /* bool */
{
	var	result = !this.TextEnd;
	if (result)
	{
		while ((this.GetCurrChar() !== c) && this.GotoNextChar()) {};
		result	=	!this.TextEnd;
	}
	return result;
} // .function TScanner.FindChar

TScanner.prototype.FindCharset = function (Charset) /* bool */
{
	var	result = !this.TextEnd;
	if (result)
	{
		while (!inset(this.GetCurrChar(), Charset) && this.GotoNextChar()) {};
		result	=	!this.TextEnd;
	}
	return result;
} // .function TScanner.FindCharset

TScanner.prototype.SkipChars = function (c) /* bool */
{
	var	result = !this.TextEnd;
	if (result)
	{
		while ((this.GetCurrChar() === c) && this.GotoNextChar()) {};
		result	=	!this.TextEnd;
	}
	return result;
} // .function TScanner.SkipChars

TScanner.prototype.SkipCharset = function (Charset) /* bool */
{
	var	result = !this.TextEnd;
	if (result)
	{
		while (inset(this.GetCurrChar(), Charset) && this.GotoNextChar()) {};
		result	=	!this.TextEnd;
	}
	return result;
} // .function TScanner.SkipCharset

TScanner.prototype.ReadTokenTillDelim = function (Charset) /* string or false */
{
	var
		StartPos	=	0,
		result		= !this.TextEnd;
	if (result)
	{
		StartPos	=	this.Pos;
		this.FindCharset(Charset);
		result	=	this.GetStrAtPos(this.Pos - StartPos, StartPos);
	}
	return result;
} // .function TScanner.ReadTokenTillDelim

function TStrBuilder ()
{
	this.Clear();
} // .function TStrBuilder

TStrBuilder.prototype.Clear	=	function ()
{
	this.Buf	=	[];
} // .function TStrBuilder.Clear

TStrBuilder.prototype.Append	=	function (Str)
{
	this.Buf.push(Str);
} // .function TStrBuilder.Append

TStrBuilder.prototype.BuildStr	=	function () /* string */
{
	return this.Buf.join('');
} // .function TStrBuilder.BuildStr

function TErmHighlighter ()
{

} // .function TErmHighlighter

TErmHighlighter.prototype.Highlight	=	function (SrcText) /* html string */
{
	/* const */
	var
		LINE_END_MARKER	=	"\n",
		COMMENT_MARKER	=	';',
		CMD_MARKER			=	'!',
		INSTR_MARKER		=	'#',
		TRIGGER_MARKER	=	'?',
		POSTTRIG_MARKER	=	'$',
		CAP_LETTERS			=	set(['A', 'Z']),
		VAR_MARKER			=	'$',
		FLAG_MARKER			=	'@',
		MACRO_MARKERS		=	set(VAR_MARKER, FLAG_MARKER),
		SPEC_CHARS			=	set('?', '&', '|', '/'),
		STR_MARKER			=	'^',
		
		COMMENTMODE_STOPCHARS	=	set(LINE_END_MARKER, CMD_MARKER),
		TEXTMODE_STOPCHARS		=	addset(addset(set(LINE_END_MARKER, CMD_MARKER, COMMENT_MARKER, STR_MARKER), MACRO_MARKERS), SPEC_CHARS),
		
		ERM_CMD_PREFIX_LEN	=	2,
		ERM_CMD_LEN					=	2,

		TEXT_MODE			=	0,
		COMMENT_MODE	=	1;
	
	/* var */
	var
		Res				=	new TStrBuilder(),
		Scanner		=	new TScanner(),
		Mode			=	TEXT_MODE,
		Token			=	'',
		Cmd				=	'',
		c					=	'',
		c1				=	'';

	function StrReplace (What, With, Str)
	{
		if (What instanceof Array)
		{
			if ((!(With instanceof Array)) || (What.length != With.length))
			{
				Assert(false);
			} // .if
			var Len = What.length;
			Str = String(Str);
			for(var i=0; i<Len; i++)
			{
				Str = Str.split(What[i]).join(With[i]);
			} // .for
			return Str;
		} // .if
		else {
			if (With instanceof Array)
			{
				Assert(false);
			} // .if
			return String(Str).split(What).join(With);
		} // .else
	} // .function StrReplace

	function NoHtml (Str)
	{
		return StrReplace(['&', '<', '>', '\'', '"'], ['&amp;', '&lt;', '&gt;', '&#039;', '&quot;'], Str);
	} // .function NoHtml
	
	function AppendText (Str)
	{
		if (Str !== '')
		{
			if (Mode === TEXT_MODE)
			{
				Res.Append(NoHtml(Str));
			}
			else if (Mode === COMMENT_MODE)
			{
				Res.Append('<span class="erm-comment">' + NoHtml(Str) + '</span>');
			}
		}
	} // .function AppendText

	function BeginLine ()
	{
		Res.Append('<li class="erm-line">');
	} // .function BeginLine

	function EndLine ()
	{
		Res.Append('</li>');
	} // .function BeginLine

	function WriteCmd ()
	{
		var	Style	=	'';
		switch (Scanner.GetCharAtRelPos(+1))
		{
			case CMD_MARKER:			Style	=	'erm-cmd'; break;
			case INSTR_MARKER:		Style	=	'erm-instr'; break;
			case TRIGGER_MARKER:	Style	=	'erm-trigger'; break;
			case POSTTRIG_MARKER:	Style	=	'erm-posttrigger'; break;
		}
		Res.Append('<span class="' + Style + '">' + NoHtml(Scanner.GetStrAtRelPos(ERM_CMD_PREFIX_LEN + ERM_CMD_LEN, +0)) + '</span>');
	} // .function WriteCmd

	function ProcessTag ()
	{
		var
			TagChar					=	Scanner.GetCurrChar(),
			TagStopCharset	=	[],
			FoundClosingTag	=	false,
			Style						=	'';
		switch (TagChar)
		{
			case STR_MARKER:	Style	=	'erm-string'; break;
			case VAR_MARKER:	Style	=	'erm-var'; break;
			case FLAG_MARKER:	Style	=	'erm-flag'; break;
		}
		Res.Append('<span class="' + Style + '">' + TagChar);
		Scanner.GotoNextChar();
		TagStopCharset	=	set(TagChar, LINE_END_MARKER);
		FoundClosingTag	=	false;
		while (!FoundClosingTag && !Scanner.TextEnd)
		{
			Token	=	Scanner.ReadTokenTillDelim(TagStopCharset);
			Res.Append(NoHtml(Token));
			c	=	Scanner.GetCurrChar();
			if (c === TagChar)
			{
				Res.Append(TagChar);
				FoundClosingTag	=	true;
			}
			Res.Append('</span>');
			if (c === LINE_END_MARKER)
			{
				EndLine();
				BeginLine();
				Res.Append('<span class="' + Style + '">');
			}
			Scanner.GotoNextChar();
		}
	} // .function ProcessTag

	Scanner.Connect(SrcText);
	Res.Append('<ol class="erm-code">');
	BeginLine();
	while (!Scanner.TextEnd)
	{
		if (Mode === TEXT_MODE)
		{
			Token	=	Scanner.ReadTokenTillDelim(TEXTMODE_STOPCHARS);
		}
		else if (Mode === COMMENT_MODE)
		{
			Token	=	Scanner.ReadTokenTillDelim(COMMENTMODE_STOPCHARS);
		}
		AppendText(Token);
		c	=	Scanner.GetCurrChar();
		if (c !== false)
		{
			if (c === LINE_END_MARKER)
			{
				EndLine();
				BeginLine();
				Scanner.GotoNextChar();
				Mode	=	TEXT_MODE;
			}
			else if (c === CMD_MARKER)
			{
				c1	=	Scanner.GetCharAtRelPos(+1);
				if ((c1 === CMD_MARKER) || (c1 === INSTR_MARKER) || (c1 === TRIGGER_MARKER) || (c1 === POSTTRIG_MARKER))
				{
					Mode	=	TEXT_MODE;
					Cmd		=	Scanner.GetStrAtRelPos(ERM_CMD_LEN, +ERM_CMD_PREFIX_LEN);
					if ((Cmd.length === ERM_CMD_LEN) && inset(Cmd.charAt(0), CAP_LETTERS) && inset(Cmd.charAt(1), CAP_LETTERS))
					{
						WriteCmd();
						Scanner.GotoRelPos(ERM_CMD_PREFIX_LEN + ERM_CMD_LEN);
					}
					else
					{
						Res.Append(c);
						Scanner.GotoNextChar();
					}
				}
				else
				{
					Res.Append(c);
					Scanner.GotoNextChar();
				}
			}
			else if (Mode === TEXT_MODE)
			{
				if (inset(c, SPEC_CHARS))
				{
					Res.Append('<b>' + NoHtml(c) + '</b>');
					Scanner.GotoNextChar();
				}
				else if (c === COMMENT_MARKER)
				{
					if (Scanner.GetCharAtRelPos(-1) !== LINE_END_MARKER)
					{
						Res.Append(c);
						Scanner.GotoNextChar();
					}
					Mode	=	COMMENT_MODE;
				}
				else if ((c === STR_MARKER) || (c === VAR_MARKER) || (c === FLAG_MARKER))
				{
					ProcessTag();
				}
			}			
		}
	}
	EndLine();
	Res.Append('</ol>');
	return Res.BuildStr();
} // .function TErmHighlighter.Highlight

TErmHighlighter.prototype.HighlightScripts = function (ScriptsType)
{
	var
		Scripts			=	document.getElementsByTagName('script'),
		Script			=	null,
		Container		=	null,
		NumScripts	=	0,
		i						=	0;
	
	NumScripts	=	Scripts.length;
	for (i = 0; i < NumScripts; i++)
	{
		if (Scripts[i].type === ScriptsType)
		{
			Container						=	document.createElement('div');
			Container.className	=	'erm-container';
			Container.innerHTML	=	this.Highlight(Scripts[i].text);
			Scripts[i].parentNode.insertBefore(Container, Scripts[i]);
		}
	}
} // .function TErmHighlighter.HighlightScripts

TErmHighlighter.prototype.HighlightDivs = function (AttrName)
{
	var
		Divs			=	document.getElementsByTagName('pre'),
		NumDivs		=	0,
		Container	=	null,
		i					=	0;
	
	NumDivs	=	Divs.length;
	for (i = 0; i < NumDivs; i++)
	{
		if (Divs[i].getAttribute(AttrName))
		{
			Container						=	document.createElement('div');
			Container.className	=	'erm-container';
			Container.innerHTML	=	this.Highlight(Divs[i].innerText);
			Divs[i].parentNode.replaceChild(Container, Divs[i]);
			NumDivs--;
			i--;
		}
	}
} // .function TErmHighlighter.HighlightDivs

new TErmHighlighter().HighlightDivs('erm');