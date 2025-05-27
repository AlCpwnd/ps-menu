# PS-Menu

Simple module to generate interactive console menus (like yeoman)

## Examples

```ps
menu @("option 1", "option 2", "option 3")
```

 ![Example](https://github.com/chrisseroka/ps-menu/raw/master/docs/example1.gif)

More useful example:

 ![Example](https://github.com/chrisseroka/ps-menu/raw/master/docs/example2.gif)

## Installation

You can install it from the PowerShellGallery using PowerShellGet

```ps
Install-Module PS-Menu
```

## Features

* Returns value of selected menu item
* Returns index of selected menu item (using `-ReturnIndex` switch)
* Displays the menu in multiple columns (using the `-Table` switch)
* Navigation with `up/down/left/right` arrows
* Navigation with `h/j/k/l` (vim style)
* Esc key quits the menu (`null` value returned)

## Contributing

* Source hosted at [GitHub][repo]
* Report issues/questions/feature requests on [GitHub Issues][issues]

Pull requests are very welcome!
