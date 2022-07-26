use strict;
use warnings;
use Data::Dumper;
use XML::Simple;

#==============================
#            main
#==============================
# 1. 这里读取一个XML文件的输入
my $file = "data";
# 2. 通过使用XMLin的方法，将内容保存成HASH结构
my $xml = XMLin("$file\.xml");
#### print Dumper \$xml;
# 3. 读取*.txt文件的内容，保存到HASH中
my %txt = &parsing("$file\.txt");
#### print Dumper \%txt;
# 4. 对比解析XML和TXT得到的数据结构
my $hack = 0;
&diff($xml,%txt);
# 5. 对比解析XML和TXT得到的数据结构
&hack(%txt);


#==============================
#         Subroutines
#==============================
sub parsing {
  my ($txt_file) = @_;
  my %txt;
  my $country;
  my $city;
  my $region;
  open TXT, "$txt_file" or die $!;
  while(<TXT>) {
    next if ($_ =~ /^(\s+)?\}/);
    if($_ =~ /country (\w+) \{/) {
      $country = $1;
    } elsif($_ =~ /city (\w+) \{/) {
      $city = $1;
    } elsif($_ =~ /people (.*);/) {
      $txt{$country}{$city}{'people'} = $1;
    } elsif($_ =~ /region (\w+) \{/) {
      $region = $1;
    } elsif($_ =~ /area ([\w\.]+);/) {
      $txt{$country}{$city}{$region}{'area'}= $1;
    } elsif($_ =~ /attribute (\w+);/) {
      $txt{$country}{$city}{$region}{'attribute'}= $1;
    } else {
      die "[country]: $country, [city]: $city, [region]: $region. Unknow parameter found: $_\n ";
    }
  }
  close TXT;
  return %txt;
}

sub diff {
  my ($xml,%txt) = @_;
  while((my $key1, my $citys) = each %$xml){
    my $country = %$xml{'spirit:name'};
    next unless ($key1 =~ /spirit:city/);
    # HASH ARRAY of city
    foreach my $city_hash(@$citys){
      while((my $key2, my $regions) = each %$city_hash) {
        my $city = %$city_hash{'spirit:name'};
        ($txt{$country}{$city}{'people'} eq $city_hash->{'spirit:people'}) ? do{} : do {$hack=1; print "[city] $city. Replace people from \"$txt{$country}{$city}{'people'}\" to \"$city_hash->{'spirit:people'}\"\n"; $txt{$country}{$city}{'city_hash'} = $city_hash->{'spirit:people'};} if(exists $city_hash->{'spirit:people'});
        next unless ($key2 =~ /spirit:region/);
        # HASH ARRAY of region
        foreach my $region_hash(@$regions) {
          my $region = %$region_hash{'spirit:name'};
          ($txt{$country}{$city}{$region}{'area'} eq $region_hash->{'spirit:area'}) ? do{} : do {$hack=1; print "[region] $region. Replace area from \"$txt{$country}{$city}{$region}{'area'}\" to \"$region_hash->{'spirit:area'}\"\n"; $txt{$country}{$city}{$region}{'area'} = $region_hash->{'spirit:area'};} if(exists $region_hash->{'spirit:area'});
          ($txt{$country}{$city}{$region}{'attribute'} eq $region_hash->{'spirit:attribute'}) ? do{} : do {$hack=1; print "[region] $region. Replace attribute from \"$txt{$country}{$city}{$region}{'attribute'}\" to \"$region_hash->{'spirit:attribute'}\"\n"; $txt{$country}{$city}{$region}{'attribute'} = $region_hash->{'spirit:attribute'};} if(exists $region_hash->{'spirit:attribute'});       
        }
      }
    }
  }
}

sub hack {
  my (%txt) = @_;
  open DATA, ">data.new.txt" or die $!;
    while((my $county, my $citys) = each %txt){
      print DATA "country $county {\n";
      while((my $city, my $regions) = each %$citys){
        print DATA "  city $city {\n";
        print DATA "    people $regions->{'people'};\n";
        while((my $region, my $parameters) = each %$regions){
          next if ($region =~ /people/);
          print DATA "    region $region {\n";
          while((my $key, my $value) = each %$parameters){
            print DATA "        $key $value ;\n";
          }
          print DATA "    }\n" # region
        }
        print DATA "  }\n" # city     
      }
      print DATA "}" # coutry
    }
  close DATA;
}