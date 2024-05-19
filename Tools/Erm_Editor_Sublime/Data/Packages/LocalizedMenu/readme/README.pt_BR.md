# LocalizedMenu
Localize Tool & Localized Menu para Usuário Final do Sublime Text 2/3/4

- Fornecer uma maneira fácil de adicionar novos idiomas
- Suporta várias versões/plataformas
- Suporta compartilhamento de menus comuns
- Backup automático de menus locais
- Descompacta automáticamente novas compilações de menus em inglês

# README.md
- de_DE [Deutsch](readme/README.de_DE.md)
- en [English](README.md)
- es_ES [Español](readme/README.es_ES.md)
- fr_FR [Français](readme/README.fr_FR.md)
- hu [Magyar](readme/README.hu.md)
- hy [Հայերեն](readme/README.hy.md)
- pt_BR [Português do Brasil](readme/README.pt_BR.md)
- ru [Русский](readme/README.ru.md)
- sv_SE [Svenska](readme/README.sv_SE.md)
- zh_CN [简体中文](readme/README.zh_CN.md)
- zh_TW [繁体中文](readme/README.zh_TW.md)

# Este projeto também está hospedado em
- [GitHub](https://github.com/zam1024t/LocalizedMenu)
- [Gitee](https://gitee.com/zam1024t/LocalizedMenu)

# Capturas de tela
#### Trabalha no Windows
![Trabalho no Windows](https://raw.githubusercontent.com/zam1024t/LocalizedMenu/shots/shots/LocalizedMenu_win.gif)
#### Trabalha no OS X
![Trabalho no OS X](https://raw.githubusercontent.com/zam1024t/LocalizedMenu/shots/shots/LocalizedMenu_osx.gif)
#### Trabalha no Ubuntu
![Trabalho no Ubuntu](https://raw.githubusercontent.com/zam1024t/LocalizedMenu/shots/shots/LocalizedMenu_linux.gif)

# Instalação
- Com Package Control
	- instale o [Package Control](https://packagecontrol.io/installation)
	- procure por `LocalizedMenu`
- Manualmente
	- baixe [master.zip](https://github.com/zam1024t/LocalizedMenu/archive/master.zip), descompacte para `Packages`, em seguida, renomei `LocalizedMenu-master` para `LocalizedMenu`
	- git clone para `Packages`
	```
	git clone https://github.com/zam1024t/LocalizedMenu
	```

# Uso
- Alterne no menu
	- via `Preference` -> `Languages`
- Alterne na paleta de comando
	- `Ctrl+Shift+P`, digite `lmxx`(*xx* é o código local) para alternar

# Adicionar um Idioma
- copie `locale/en/en.json` para `locale/<locale>/<locale>.json`, seu idioma local
- copie `menu/<version>/en/*` para `menu/<version>/<locale>/*`, seu idioma local
- Por exemplo, agora adicione o idioma chamado `my` para Sublime Text Build 3999
	- abra a pasta `LocalizedMenu`, via `Preference` -> `Languages` -> `Adicionar um idioma`
	- entre em `locale`, copie `en` para `my`
	- entre em `my`, renomei `en.json` para `my.json`, edite como:

	```JavaScript
	{
		"link": "",
		"hidden": false,
		"caption": "MyLanguage",
		"mnemonic": "m"
	}
	```

	- entre em `menu/3999`, copie `en` para `my`, e traduza tudo em `caption` nos arquivos de menu
	- detectar idioma via `Preference` -> `Languages` -> `Detect`, então exibe `MyLanguage (my)`

	> **locale configs**<br>
	> link： o local de destino vinculado<br>
	> hidden： item do menu oculto<br>
	> caption： nome do idioma, código local irá adicionar extramente<br>
	> mnemonic： tecla de atalho, opcional, certifique-se de contê-lo em caption, diferencia maiúscula e minúscula

# Enviar um Idioma
- nome do local deve ser nomeado como `<languageCode>` ou `<languageCode>_<countryCode>`
	- `<languageCode>` minúscula, `<countryCode>` maiúscula, (ignore isso se trabalhar localmente)
	- Language: https://www.wikipedia.org/wiki/ISO_639-1
	- Country: https://www.wikipedia.org/wiki/ISO_3166-1
- Fork do repositório
- Faça um pull request

# Idiomas e Colaboradores
- de_DE Deutsch *por [Standarduser](https://github.com/Standarduser)*
- es Español *por [Christopher](https://t.me/Azriel_7589)*
- es_ES Español *por [Dastillero](https://github.com/dap39)*
- fr_FR Français *por [fxbenard](https://github.com/fxbenard)*
- hu Magyar *by [Tamás Balog](https://github.com/picimako)*
- hy Հայերեն *por [Arman High Foundation](https://github.com/ArmanHigh)*
- pt Português do Brasil *por [JNylson](https://github.com/jnylson)*
- ru Русский *por [Dimox](http://dimox.name) & [Ant0sh](https://github.com/Ant0sh) & [Maksim Arhipov](https://github.com/OSPanel)*
- sv_SE Svenska *por [H2SO4JB](https://github.com/H2SO4JB)*
- zh_CN 简体中文 *por [Zam](https://github.com/zam1024t)*
- zh_TW 繁体中文 *por [Zam](https://github.com/zam1024t)*

# Discussão Relacionada
- https://github.com/wbond/package_control_channel/pull/5665
- https://github.com/rexdf/ChineseLocalization/issues/10

# Licença
[Licença MIT](LICENSE)
