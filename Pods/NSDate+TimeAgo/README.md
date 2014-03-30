## Description

This is an iOS, Objective-C, Cocoa Touch, iPhone, iPad category for `NSDate`. It gives `NSDate` the ability to report times like `"A moment ago"`, `"30 seconds ago"`, `"5 minutes ago"`, `"Yesterday"`, `"Last month"`, `"2 years ago"`, and so on.

This functionality has variously been referred to as a "time ago", "time since", "relative date", or "fuzzy date" feature.

`NSDate+TimeAgo` currently supports the following languages: 

- en (English)
- es (Spanish)
- zh_Hans (Chinese Simplified)
- zh_Hant (Chinese Traditional)
- pt (Portuguese)
- fr (French)
- it (Italian)
- ru (Russian)
- de (German)
- nl (Dutch)
- hu (Hungarian)
- fi (Finnish)
- ja (Japanese)
- vi (Vietnamese)
- ro (Romanian)
- da (Danish)
- cs (Czech)
- nb (Norwegian)
- lv (Latvian)
- tr (Turkish)
- ko (Korean)
- bg (Bulgarian)
- he (Hebrew)
- ar (Arabic)
- gre (Greek)
- pl (Polish)
- sv (Swedish)
- th (Thai)

If you know a language not listed here, please consider submitting a translation. [Localization codes by language](http://stackoverflow.com/questions/3040677/locale-codes-for-iphone-lproj-folders).

This project is user driven (by people like you). Pull requests close faster than issues (merged or rejected).

## Use

1.  `Add` the files to your project - manually or via Cocoapods (`pod 'NSDate+TimeAgo'`)
2.  Import the header using  `#import "NSDate+TimeAgo.h"`
3.  Call the `timeAgo` method in the following way:

<pre>
NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:0];
NSString *ago = [date timeAgo];
NSLog(@"Output is: \"%@\"", ago);
2011-11-12 17:19:25.608 Proj[0:0] Output is: "41 years ago"
</pre>

2 other methods are available:

* `dateTimeAgo`: returns times with only strings of the type: "*{value}* *{unit}* ago"
* `dateTimeUntilNow`: returns only "yesterday" / "this morning" / "last week" / "this month" -- less precise than `dateTimeAgo` but more natural

Those three methods can be interchanged as they have the same signature.

## Future Directions

Would be nice to

1.  add customization options (e.g., should it report seconds or just "a minute ago") 
2.  add string customization
3.  have more localizations
4.  make `dateTimeUntilNow` more precise: instead of "Last week" use "Last Friday", "Last Monday" etc.
5.  other

## License

Released under ISC (similar to 2-clause BSD)

http://wikipedia.org/wiki/ISC_license

## Credits

Originally based on code Christopher Pickslay posted to Forrst. Used with permission. http://twitter.com/cpickslay 

Ramon Torres began support for internationalization/localization. Added `es` strings. http://rtorres.me/

Dennis Zhuang added `zh_Hans` Chinese Simplified strings. http://fnil.net/

Mozart Petter added `pt_BR` Brazilian Portuguese strings. http://www.mozartpetter.com/

Stéphane Gerardot added `fr` French strings.

Marco Sanson added `it` Italian strings. http://marcosanson.tumblr.com/

Almas Adilbek added `ru` Russian strings. Extended logic to support Russian idioms. http://mixdesign.kz/

Mallox51 added `de` German strings. https://github.com/Mallox51

Tieme van Veen added `nl` Dutch strings. http://www.tiemevanveen.nl

Árpád Goretity added `hu` Hungarian strings. http://apaczai.elte.hu/~13akga/

Anajavi added `fi` Finnish strings. https://github.com/anajavi

Tonydyb added `ja` Japanese strings.

Vinhnx added `vi` Vietnamese strings. http://vinhnx.github.io/

Ronail added `zh_Hant` Traditional Chinese strings. https://github.com/ronail

SorinAntohi added `ro` Romanian strings. https://github.com/SorinAntohi

spookd added `da` Danish strings. https://github.com/spookd

Barrett Jacobsen added `cs` Czech strings.  https://github.com/barrettj

Dmitry Shmidt added `nb` Norwegian strings. https://github.com/shmidt

Martins Rudens added `lv` Latvian strings. https://github.com/rudensm

Osman Saral added `tr` Turkish strings. https://github.com/osrl

analogstyle added `ko` Korean strings. http://almacreative.net/

Flavio Caetano fixed `pt` Portuguese strings. http://flaviocaetano.com

kolarski added `bg` Bulgarian strings. http://github.com/kolarski

Vladimir Kofman added `he` Hebrew strings. https://github.com/vladimirkofman

Viraf Sarkari added `ar` Arabic, `gre` Greek, `pl` Polish, `sv` Swedish, and `th` Thai strings. https://github.com/viraf

