
mod.json file structure
---------------------------

#### Notes
Any section, defined as `"section": lng` means that section is defined as following instead (to reduce boilerplate)
```
"section": {
  "en" : "value",
  "ru" : "value",
  "<code>" : "value"
}
```
MM will try to load entry for current language first. If it's not possible - english will be used instead. 
All paths are relative to mod directory.
MM will try to load data from deprecated fields if data is not present in expected format.

## Structure
```
{
  "name" : lng,
  "description" : lng,
  "author" : "SyDr",
  "homepage" : "https://...",
  "icon" : "icon.png",
  "version" : "1.0",
  "category" : "gameplay",
  "compatibility" : {
    "requires" : [ "WoG", "Test1" ],
    "load_after" : [ "WoG", "Test2" ],
    "incompatible" : [ "Test3" ]
  }
```
### Category
See files in "lng" directory for list of available values.

### Compatibility
When looking for a some file, Era II will start from mod with greatest priority. I will refer to load order - exact opposite thing. For example if i say `Mod 2` loaded after `Mod 1` this means that `Mod 2` will have greater priority, and game will took files from it instead of `Mod 1` where it possible. Don't be confused :).

`incompatible` lists mods, with which game cannot be loaded or this action will not make any sense in combination with this mod.  
`requires` lists mods, without which game cannot be loaded or this action will not make any sense in combination with this mod (this will also automatically adds this mod to load order).  
`load_after` lists mods, which should have less priority than this mod (i.e. game will load files from this mod if they are sorted correctly).

`WoG` is implicitly added to `requires` and `load_after`, unless you modify them (i.e., you probably want add WoG to `requires` too).