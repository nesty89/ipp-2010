#!/usr/bin/perl -w

#CSV:xpavlu06
##################################################################
# IPP - projekt c.1 CSV (CSV2XML) - Perl
# Autor: Igor Pavlu, xpavlu06@stud,fit.vutbr.cz
#
# Program generuje na zaklade csv obsahu souboru xml dokument
# podle zadanych parametru.
#
##################################################################

use Getopt::Long;
use encoding 'utf8';
use utf8;

# zaloha parametru
my @params = @ARGV;

# unikatnost polozek - pokud se parametr vyskytuje zjistuje se pocet vyskytu v poli s parametry
#                    - pri nekorektnim zadani vraci 1 jinak 0
sub check
{
  if($test = eval(grep /^--padding$/, @_) != 0)  {return 1 if($test = eval(grep /^--padding$/, @params) == 1); }
  if($test = eval(grep /^-n$/, @_) != 0) {return 1 if($test = eval(grep /^-n$/, @params) == 1); }
  if($test = eval(grep /^(--error-recovery|-e)$/, @_) != 0) {return 1 if($test = eval(grep /^(--error-recovery|-e)$/, @params) == 1); }
  if($test = eval(grep /^-i$/, @_) != 0) {return 1 if($test = eval(grep /^-i$/, @params) == 1); }
  if($test = eval(grep /^-h$/, @_) != 0) {return 1 if($test = eval(grep /^-h$/, @params) == 1); }
  if($test = eval(grep /^--help$/, @_) != 0) {return 1 if($test = eval(grep /^--help$/, @params) == 1); }
  if($test = eval(grep /^--output=.*$/, @_) != 0) {return 1 if($test = eval(grep /^--output=.*$/, @params) == 1); }
  if($test = eval(grep /^--input=.*$/, @_) != 0) {return 1 if($test = eval(grep /^--input=.*$/, @params) == 1); }
  if($test = eval(grep /^-r=.*$/, @_) != 0) {return 1 if($test = eval(grep /^-r=.*$/, @params) == 1); }
  if($test = eval(grep /^-s=(.|TAB)$/, @_) != 0) {return 1 if($test = eval(grep /^-s=(.|TAB)$/, @params) == 1); }
  if($test = eval(grep /^-l=.*$/, @_) != 0) {return 1 if($test = eval(grep /^-l=.*$/, @params) == 1); }
  if($test = eval(grep /^--start=[^-][0-9]*$/, @_) != 0) {return 1 if($test = eval(grep /^--start=[^-][0-9]*$/, @params) == 1); }
  if($test = eval(grep /^--missing-value=.*$/, @_) != 0) {return 1 if($test = eval(grep /^--missing-value=.*$/, @params) == 1); }
  if($test = eval(grep /^--all-columns$/, @_) != 0) {return 1 if($test = eval(grep /^--all-columns$/, @params) == 1); }
  return 0;
}
#  zpracovani parametru volanim subrutiny 
for($test = 1, $i = 0; $test == 1 and defined($params[$i]); $i++)
{
  $test = check($params[$i]);
  exit(1) if($test == 0);
}

# nastaveni flagu/pracovnich dat
my $opt_n = 0;
my $opt_h = 0;
my $opt_i = 0;
my $opt_e = 0;
my $help = 0;
my $inputfile = "";
my $outputfile = "";
my $rootelement = "";
my $separator = ",";
my $lineelement = "";
my $start = -1;
my $missingvalue = "";
my $allcol = 0;
my $padding = 0;

# nebyly zadany parametry
# exit(1) if(!defined($ARGV[0]));

# predzpracovani parametru
my $gettest = GetOptions(
 "padding"=> \$padding,
 "n" => \$opt_n,
 "e" => \$opt_e,
 "i" => \$opt_i,
 "h" => \$opt_h,
 "help" => \$help,
 "output=s" => \$outputfile,
 "r=s" => \$rootelement,
 "s=s" => \$separator,
 "input=s" => \$inputfile,
 "l=s" => \$lineelement,
 "start=i" => \$start,
 "error-recovery" => \$opt_e,
 "missing-value=s" => \$missingvalue,
 "all-columns" => \$allcol
);

if($gettest == 0){exit(1);}
if(defined($ARGV[0])){exit(1);} # kdyby byly prebytecne parametry

# sekce zpracovani parametru
# zpracovani parametru --help
$test = grep /^--help$/, @params;
if($help == 1 and $test==1 and !defined($params[1]))
{
  print "CSV: CSV2XML\n";
  print "Autor: Igor Pavlu, xpavlu06\@stud.fit.vutbr.cz\n";
  print "Preformatovani CSV souboru do XML dle zadanych parametru\n";
  print "Parametry:\n";
  print "--help\t\t\tvypis napovedy\n";
  print "--input=filename\tvstupni soubor s CSV\n";
  print "--output=filename\tvystupni soubor pro XML,\n\t\t\tv pripade nezadani bude vypsano na standardni vystup\n";
  print "-n\t\t\tnegeneruje se XML hlavicka\n";
  print "-r=root-element\t\tjmeno korenoveho elementu XML\n";
  print "-s=separator\t\toddelovaci znak\n";
  print "-h\t\t\tprvni radek slouzi jako hlavicka pro zaznamy v XML\n";
  print "-l=line-element\t\tnazev pro XML element obalujici radek\n";
  print "-i\t\t\tvlozeni atributu index\n";
  print "--start=n\t\tnastaveni hodnoty pro indexaci (n>=0) pro parametr -i\n";
  print "-e, --error-recovery\trezim zotavovani z chyb\n";
  print "--missing-value=val\tv kombinaci s prepinaci -e, --error-recovery,\n\t\t\tprazdna pole nahrazena hodnotou val\n";
  print "--all-columns\t\tv kombinaci s prepinaci -e, --error-recovery,\n\t\t\tnekorektni zadani sloupcu neni ignorovano\n";
  print "--padding\t\tdoplneni korektniho poctu nul u parametru -i a u nezadaneho parametru -h"
  exit(0);
}
elsif($help == 1) {exit(1);} # nekorektni zadani parametru --help (dalsi parametr)
else{undef $test;}
# nastaveni separatoru
$separator = "," if($separator eq "");
$separator = "\t" if($separator eq "TAB");
# zpracovani parametru missing-value
if($opt_e == 0 and $missingvalue ne ""){exit(1);}
if($missingvalue ne "")
{
  utf8::encode($missingvalue);
  exit(30) if(($test = eval(grep /^:A-Z_a-zì¹èø¾ıáíéúù»òóïÌ©ÈØ®İÁÍÉÙÚ«ÒÏ\x{C0}-\x{D6}\x{D8}-\x{F6}\x{F8}-\x{FF}\-\.0-9\x{B7}*$/, $missingvalue)) == 0);
}
# zpracovani parametru root element
if($rootelement ne "")
{
  utf8::encode($rootelement);
  exit(30) if(($test = eval(grep /^[:A-Z_a-zì¹èø¾ıáíéúù»òóïÌ©ÈØ®İÁÍÉÙÚ«ÒÏ\x{C0}-\x{D6}\x{D8}-\x{F6}\x{F8}-\x{FF}]
                                   [:A-Z_a-zì¹èø¾ıáíéúù»òóïÌ©ÈØ®İÁÍÉÙÚ«ÒÏ\x{C0}-\x{D6}\x{D8}-\x{F6}\x{F8}-\x{FF}\-\.0-9\x{B7}]*$/, $rootelement)) == 0);
}
# zpracovani parametru all-columns
if($opt_e == 0 and $allcol != 0){exit(1);}
# zpracovani parametru -i zavysleho na parametru -l
if($lineelement eq "" and $opt_i == 1){exit(1);}
# zpracovani parametru -l - navratovy kod 30 pri spatne zadanem val
if($lineelement ne "")
{
  utf8::encode($lineelement);
  exit(30) if(($test = eval(grep /^[:A-Z_a-zì¹èø¾ıáíéúù»òóïÌ©ÈØ®İÁÍÉÙÚ«ÒÏ\x{C0}-\x{D6}\x{D8}-\x{F6}\x{F8}-\x{FF}]
                                   [:A-Z_a-zì¹èø¾ıáíéúù»òóïÌ©ÈØ®İÁÍÉÙÚ«ÒÏ\x{C0}-\x{D6}\x{D8}-\x{F6}\x{F8}-\x{FF}\-\.0-9\x{B7}]$/, $lineelement)) == 0);
}
if($lineelement eq ""){$lineelement = "row";}

#zpracovani parametru --start
if($opt_i == 1 and $start == -1) {$start = 1;}
if($opt_i == 1 and $start < 0) {exit(1);}

undef(@params);
# zpracovani parametru --input -vstupni soubor
my @lines;
if($inputfile eq ""){@lines = <STDIN>;}
else
{
  chmod 0777, $inputfile;
  open(F_IN, $inputfile) or exit(2);
  @lines = <F_IN>;
  close(F_IN);  
}
# test na pocet uvozovek v pripade licheho poctu se jedna o nevalidni soubor
$test = 0;
for($i = 0; defined($lines[$i]); $i++)
{
  $vyskyt = $lines[$i] =~ tr/\"/\"/;
  $test += $vyskyt;
  undef($vyskyt);
}
exit(4) if(($test % 2) != 0);

# zpracovani parametru --output -vystupni soubor
if($outputfile eq ""){$outputfile = STDOUT;}
else
{
  open(F_OUT, ">$outputfile") or exit(3);
  chmod 0777, $outputfile;
  $outputfile = F_OUT;
}

# vykonna cast programu

# hlavicka xml
if($opt_n == 0){ print $outputfile "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n";}

# koren
if($rootelement ne ""){utf8::decode($rootelement); print $outputfile "<$rootelement>\r\n";}

my $col_count = 1; # citac pro pripad vypisu sloupcu colX
my $linecounter = 0; # citac pro pocet radku
# nastaveni headu nebo poctu polozek
my @csv_head; # pole pro polozky hlavicky
$csv_head[0] = "";
my $quote = 0; # pomocna promenna pro detekci uvozovek
my @tmp; # pomocne pole pro zpracovani uvozovek
$tmp[0] = "";
# test na uvozovky v prvnim radku
utf8::encode($lines[$linecounter]);
if(($test = grep /^.*\".*$/, $lines[$linecounter]) == 0)
{
  @csv_head = split /$separator/o, $lines[$linecounter];
  $linecounter = 1 if($opt_h == 1);
}
else
{
  @tmp = split "", $lines[$linecounter];
  for($i = 0, $j = 0; ($quote != 0 and defined($lines[$linecounter])) or defined($tmp[$i]); $i++)
  {
    if($tmp[$i] eq $separator and $quote != 1){$j++;$csv_head[$j] = "";}# novy prvek
    elsif($tmp[$i] eq "\"") # nalezeni uvozovky
    {
      if(defined($tmp[$i+1]) and $tmp[$i+1] eq "\"") # dve uvozovky za sebou - vlozeno "
      {
        $i++;
        $csv_head[$j] = "$csv_head[$j]"."$tmp[$i]";
      }
      else # prenastaveni uvozovek
      {
        if($quote == 1) {$quote = 0;}
        else {$quote = 1; }
      }
    }
    else {$csv_head[$j] = "$csv_head[$j]"."$tmp[$i]";} # nacteni dat do pole head
    if($quote == 1 and !defined($tmp[$i+1])) # v pripade uvozovek nekoncicich na poslednim radku - v pripade lichych uvozovek
    {
      $linecounter++;
      if(defined($lines[$linecounter])){utf8::encode($lines[$linecounter]);@tmp = split "", $lines[$linecounter]; $i = 0;}# nova data na zpracovani
    }
  }
  $linecounter++;  
}
$quote = 0;
undef(@tmp);

$linecounter = 0 if($opt_h == 0);
my @csv_data;
$csv_data[0] = "";
if(($test = grep /^.*[\n]$/, $csv_head[$#csv_head]) == 0) {exit(4);}
else{substr $csv_head[$#csv_head],-1,1,"";}
if(($test = grep /^.*[\r]$/, $csv_head[$#csv_head]) == 0) {exit(4);}
else{substr $csv_head[$#csv_head],-1,1,"";}
undef($test);
for($i = 0; $i <= $#csv_head; $i++)
{
  # test na prvni pismeno radku
  exit(31) if(($test = eval(grep /[:A-Z_a-zì¹èø¾ıáíéúù»òóïÌ©ÈØ®İÁÍÉÙÚ«ÒÏ\x{C0}-\x{D6}\x{D8}-\x{F6}\x{F8}-\x{FF}]/, $csv_head[$i]) == 0);
  $csv_head[$i] =~ tr/:A-Z_a-zì¹èø¾ıáíéúù»òóïÌ©ÈØ®İÁÍÉÙÚ«ÒÏ\x{C0}-\x{D6}\x{D8}-\x{F6}\x{F8}-\x{FF}\-\.0-9\x{B7}/-/c;
}
# vypis tela XML
while(defined($lines[$linecounter]))
{
  utf8::encode($lines[$linecounter]);
  # test na uvozovky + zpracovani
  if(($test = grep /^.*\".*$/, $lines[$linecounter]) == 0){@csv_data = split /$separator/o, $lines[$linecounter];}# bez uvozovek
  else
  {
    @tmp = split "", $lines[$linecounter]; # nacteni dat
    for($i = 0, $j = 0; ($quote != 0 and defined($lines[$linecounter])) or defined($tmp[$i]); $i++)
    {
      if($tmp[$i] eq $separator and $quote != 1){$j++;$csv_data[$j] = "";} # dalsi polozka do vystupniho datoveho pole
      elsif($tmp[$i] eq "\"") # nasla se uvozovka
      {
        if(defined($tmp[$i+1]) and $tmp[$i+1] eq "\"") # dve uvozovky nahrada za uvozovku
        {
          $i++;
          $csv_data[$j] = "$csv_data[$j]"."$tmp[$i]";
        }
        else # prenastaveni uvozovek
        {
          if($quote == 1) {$quote = 0;}
          else {$quote = 1;}
        }
      }
      else {$csv_data[$j] = "$csv_data[$j]"."$tmp[$i]";} # pridani dat
      if($quote == 1 and !defined($tmp[$i+1])) # dalsi data k zpracovani
      {
        $linecounter++;
        if(defined($lines[$linecounter])){utf8::encode($lines[$linecounter]);@tmp = split "", $lines[$linecounter]; $i = 0;}
      }
    }	
  }
  $quote = 0;
  undef(@tmp);
  # spatny pocet sloupcu
  exit(32) if($opt_e == 0 and defined($csv_data[$#csv_head+1])); 
  exit(32) if($opt_e == 0 and !defined($csv_data[$#csv_head]));
  # oriznuti o \r\n ukonceni
  if(($test = grep /^.*[\n]$/, $csv_data[$#csv_data]) == 0 and $linecounter < $#lines) {exit(4);}
  else{substr $csv_data[$#csv_data],-1,1,"";}
  if(($test = grep /^.*[\r]$/, $csv_data[$#csv_data]) == 0 and $linecounter < $#lines) {exit(4);}
  else{substr $csv_data[$#csv_data],-1,1,"";}
  # zacatek line elementu / row
  utf8::decode($lineelement);
  print $outputfile "<$lineelement";
  if($opt_i != 0) 
  {
    print $outputfile " index=\"";
    if($padding == 1)
    {
      @i_length = split "", eval($#lines+$start+1);
      @i_data = split "", $start;
      for($i = $#i_data; $i < $#i_length; $i++)
      {
        print $outputfile "0";
      }
    }
    print $outputfile "$start\">\r\n";   
  } 
  else {print $outputfile ">\r\n";}
  for(; $col_count <= $#csv_head+1 or (defined($csv_data[$col_count-1]) and $allcol == 1); $col_count++)
  {
    # zacatek radkovani 
    if($opt_h == 0)
    {
      print $outputfile "<col";
      if($padding == 1)
      {
        @h_col = split "", $col_count;
        @data_n = split "", eval($test = $#csv_data+1);
        for($i = $#h_col; $i < $#data_n; $i++)
        {
          print $outputfile "0";
        }
      }
      print $outputfile "$col_count>";
    }
    else
    {
      if(defined($csv_head[$col_count-1]))
      {
        utf8::decode($csv_head[$col_count-1]);
        print $outputfile "<$csv_head[$col_count-1]>";
      }
      else
      {
        print $outputfile "<col";
        if($padding == 1)
        {
          @h_col = split "", $col_count;
          @data_n = split "", $#csv_data;
          for($i = $#h_col; $i < $#data_n; $i++)
          {
            print $outputfile "0";
          }
        }
        print $outputfile "$col_count>"   
      }
    }
    # vlastni data    
    if(defined($csv_data[$col_count-1]))
    {
      # test na korektni data (nahrazeni pomlckou) a prekodovani ", >, < a &
      $csv_data[$col_count-1] =~ tr/:A-Z_a-zì¹èø¾ıáíéúù»òóïÌ©ÈØ®İÁÍÉÙÚ«ÒÏ\x{C0}-\x{D6}\x{D8}-\x{F6}\x{F8}-\x{FF}\-\.0-9\x{B7}/-/c;
      $csv_data[$col_count-1] =~ s/\"/&quot;/g;
      $csv_data[$col_count-1] =~ s/&/&amp;/g;
      $csv_data[$col_count-1] =~ s/</&lt;/g;
      $csv_data[$col_count-1] =~ s/>/&gt;/g;
      utf8::decode($csv_data[$col_count-1]);
      print $outputfile "$csv_data[$col_count-1]";
    }
    else
    {
      if($missingvalue eq ""){ print $outputfile "";}
      else{utf8::decode($missingvalue);print $outputfile "$missingvalue";}
    }
    # konec radkovani
    if($opt_h == 0)
    {
      print $outputfile "</col";
      if($padding == 1)
      {
        for($i = $#h_col; $i < $#data_n; $i++)
        {
          print $outputfile "0";
        }
      }
      print $outputfile "$col_count>\r\n";
    }
    else
    {
      if(defined($csv_head[$col_count-1]))
      {
        print $outputfile "<$csv_head[$col_count-1]>\r\n";
      }
      else
      {
        print $outputfile "</col";
        if($padding == 1)
        {
          @h_col = split "", $col_count;
          @data_n = split "", $#csv_data;
          for($i = $#h_col; $i < $#data_n; $i++)
          {
            print $outputfile "0";
          }
        }
        print $outputfile "$col_count>\r\n";
      }
    } 
  }
  # konec lineelementu / row
  print $outputfile "</$lineelement>";
  $col_count = 1;
  $linecounter++;
  $start++; 
  # pripadne odradkovani
  if($rootelement ne "" or defined($lines[$linecounter])) {print $outputfile "\r\n";}
}
# konec elementu korene
if($rootelement ne ""){print $outputfile "</$rootelement>";}
close($outputfile) if($outputfile ne STDOUT);
