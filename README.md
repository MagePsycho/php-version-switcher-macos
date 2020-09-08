# Bash Script: PHP Version Switcher for MacOS

This utility script helps you to switch the version for your PHP installed via Homebrew on MacOS.
*Currently it only supports PHP versions: `7.1`, `7.2`, `7.3` & `7.4`*


## INSTALL
You can simply download the script file and give the executable permission.
```
curl -0 https://raw.githubusercontent.com/MagePsycho/php-version-switcher-macos/master/src/php-switcher.sh -o php-switcher.sh
chmod +x php-switcher.sh
```

To make it system wide command
```
mv php-switcher.sh ~/bin/php-switcher
```

## USAGE
### To display help
```
php-switcher --help
```

### To switch PHP version
```
php-switcher 7.4
```

## Screenshots
![PHP Switcher Help](https://github.com/MagePsycho/php-version-switcher-macos/raw/master/docs/php-switcher-script-help-1.0.1.png "PHP Switcher Help")

