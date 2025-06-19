#`mod.json` file structure (project)

###Notes

Any section, in which data can be translated, defined in the same way:

    "<Section Name>": {
      "en_US" : "English variant",
      "ru_RU" : "Russian variant",
      "<LngCode>" : "Other lng variant"
    }
These sections will be referred as `"<Section Name>" : lng`.  
In any case, if current language value is empty, invalid or not defined, then English variant will be used instead.

Everything related to file path uses mod directory as base.

###Basic mod info
    "caption": lng,
    "description": {
       "full": lng,
       "short": lng
    }
Caption is self explanatory.  
Full description refers to file with description (plain text format).  
Short description is used for web and other places (maybe).

    "author": "SyDr",
    "homepage": "http://wforum.heroes35.net",  
    "icon": {
      "file": "icon.ico",
      "index": 0
    },
    "video" : "w46whZ-SKQ4"
Author is self explanatory.  
Homepage must start with `http://` or `https://`.  
If icon is not defined - standard icon will be used. Icon index is zero based.  
Video is just ID of YouTube video.

    "plugins": {
      "<Plugin filename>" : {
        "hidden" : false,
        "caption" : lng,
        "description" : lng
      }
    },
    "packages": {
      "<Package filename>" : {
        "caption" : lng,
        "description" : lng
      }
    },
Filenames are listed without `.off` extension.  
By default MM will show all plugins and no packages. To hide plugin set `hidden` to `true`. To show package you should simple define an entry for it.

    "category": "gameplay"
MM groups mods by this tag in view. See language files `category` tag for predefined values. These values will be automatically translated by MM on view.

###Version info (`version` tag)
    "platform": "era",
    "mod": "1.0",
    "info": "1.0"
Platform is `era`. Can be safely ignored. This is not used for anything.
Combination of `mod` and `info` must be unique. This means:
  
* If something in package changed -> `mod` must be increased (`info` can be reset then)
* If only `mod.json` file changed -> `info` must be increased

### Compatibility / Mod load order optimization (`compatibility` tag)
When looking for a some file, Era II will start from mod with greatest priority. I will refer to load order - exact opposite thing. For example if i say `Mod 2` loaded after `Mod 1` this means that `Mod 2` will have greater priority, and game will took files from it instead of `Mod 1` where it possible. Don't be confused :).

    "incompatible" : ["<Mod ID>"],
    "required" : ["Mod ID"],
    "hints" : (1)[
        (2)["<Mod ID 1>", (3)["<Mod ID 2>", "<Mod ID 3>"], "@mod"],
        ["@mod", "Mod ID"],
        ["<Mod ID 1>", "<Mod ID 2>"]
    ]    
    "priority" : 0
`incompatible` lists mods, with which game cannot be loaded or this action will not make any sense.  
`required` lists mods, without which game cannot be loaded or this action will not make any sense (this will not restrict mod load order).  
`hints` is a list (1) of ordered lists (2) of unordered lists (3). Yep. It's simple. Read this as:

 * `@mod` - just a shortcut to current mod ID (directory name)
 * `["<Mod ID 1>", "<Mod ID 2>"]` - `Mod 2` should be loaded after `Mod 1`
 * `["<Mod ID 1>", ["<Mod ID 2>", "<Mod ID 3>"]]` - `Mod 2` and `Mod 3` should be loaded after `Mod 1` (this not restricts `Mod 2` and `Mod 3` load order)

`priority` used for additional mod load order optimizations. It will be ignored if mods are successfully sorted by other info.
