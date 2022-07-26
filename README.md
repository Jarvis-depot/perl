# Converting XML to TXT
## 1. Introduction
This branch containing with files below:
+ xml_parsing.pl
+ data.xml
+ data.txt

Where **xml_parsing.pl** is the main script, which mainly used for hacking ***.txt** based on ***.xml** database

## 2. xml_parsing.pl
This script accepts a *.txt as input, parsing data-structure with simple ***FILE open*** function

It also accepts a *.xml as input, by using XML::Simple package && XMLin function, constructing XML DB

Finally do XML && TXT DB comparing, and a *.new.txt generated
