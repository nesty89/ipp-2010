#!/usr/bin/python3
# -*- coding: iso-8859-2 -*-
#CST:xpavlu06

import os, glob, re, sys
# n-tice (tuple) pro ulozeni klicovich slov, operatoru a znaku urcenych pro vymazani
keywords = ("\\bauto\\b", "\\bbreak\\b", "\\bcase\\b", "\\bchar\\b", "\\bconst\\b", "\\bcontinue\\b", "\\bdefault\\b", "\\bdo\\b", "\\bdouble\\b", "\\belse\\b", "\\benum\\b", "\\bextern\\b", "\\bfloat\\b", "\\bfor\\b", "\\bgoto\\b", "\\bif\\b", "\\binline\\b", "\\bint\\b", "\\blong\\b", "\\bregister\\b", "\\brestrict\\b", "\\breturn\\b", "\\bshort\\b", "\\bsigned\\b", "\\bsizeof\\b", "\\bstatic\\b", "\\bstruct\\b", "\\bswitch\\b", "\\btypedef\\b", "\\bunion\\b", "\\bunsigned\\b", "\\bvoid", "\\bvolatile\\b", "\\bwhile\\b", "\\b_Bool\\b", "\\b_Complex\\b", "\\b_Imaginary\\b")
operators = ("\<\<\=","\>\>\=", "\+\+", "\-\-", "\+\=", "\-\=",  "\*\=",  "\/\=",  "\%\=",  "\<\=",  "\>\=", "\=\=", "\!\=",  "\&\&", "\|\|", "\<\<", "\>\>", "\&\=", "\|\=",  "\^\=",  "\-\>", "\+", "\-","\*","\/","\%","\<","\>","\!","\~", "\&","\|", "\^","\.","\=")
other = ("\.\.\.","\,", "\[", "\]", "\:", "\{","\}","\(","\)","\;")
# inicializace globalnich promennych a flagu
out_file = ""
in_file = ""
w = ""
flag_i = 0
flag_h = 0
flag_k = 0
flag_o = 0
flag_ik = 0
flag_c = 0
flag_p = 0
flag_w = 0
flag_in = 0
flag_out = 0
paramcounter = 0
# startovni pozice
startdir = os.getcwd()
# napoveda
def help():
  print("CST: statistiky .c a .h souboru")
  print("Parametry:")
  print("--help.................napoveda")
  print("--input=<nazev>........soubor nebo adresar pro zpracovani bez zadani")
  print("                       se vyhodnoti adresarova struktura od aktualni pozice")
  print("--output=<nazev>.......vystupni soubor v pripade nezadani standardni vystup")
  print("-i.....................pocet vyskytu identifikatoru")
  print("-o.....................pocet vyskytu operatoru")
  print("-k.....................pocet vyskytu klicovich slov")
  print("-ik....................soucet poctu vyskytu identifikatoru a klicovich slov")
  print("-c.....................delka vsech komentaru")
  print("-w=<pattern>...........pocet vyskytu vsech podretezcu <pattern>")
  print("-p.....................pokud je zadano vypisuji se jen nazvy souboru")
  print("                       jinak i absolutni cesty k nim")
  
# vyhodnoceni parametru - nastaveni flagu
for i in range(1,len(sys.argv)):
  if sys.argv[i] == "-i":
    flag_i += 1
    paramcounter += 1
  elif sys.argv[i] == "--help":
    flag_h += 1
  elif sys.argv[i] == "-k":
    flag_k += 1
    paramcounter += 1
  elif sys.argv[i] == "-o":
    flag_o += 1
    paramcounter += 1
  elif sys.argv[i] == "-ik":
    flag_ik += 1
    paramcounter += 1
  elif sys.argv[i] == "-c":
    flag_c += 1
    paramcounter += 1
  elif sys.argv[i] == "-p":
    flag_p += 1
  elif re.search("^-w=.+$", sys.argv[i]):
    flag_w += 1
    paramcounter += 1
    w = re.sub("^-w=","",sys.argv[i])
  elif re.search("^--input=.+$", sys.argv[i]):
    flag_in += 1
    in_file=re.sub("^--input=","",sys.argv[i])
  elif re.search("^--output=.+$", sys.argv[i]):
    out_file=re.sub("^--output=","",sys.argv[i])
    flag_out += 1
  else:
    sys.stderr.write("Chyba zadanych parametru pro dalsi info --help\n")
    sys.exit(1)
# testovani zadanych parametru
if flag_h == 1:
  if len(sys.argv) == 2:
    help()
    sys.exit(0)
  else:
    sys.stderr.write("Chyba zadanych parametru pro dalsi info --help\n")
    sys.exit(1)
# korektnost parametru
if paramcounter > 1:
  sys.stderr.write("Chyba zadanych parametru pro dalsi info --help\n")
  sys.exit(1) 
# duplicita parametru
if flag_i > 1 or flag_h > 1 or flag_k > 1 or flag_o > 1 or flag_ik > 1 or flag_c > 1 or flag_p > 1 or flag_w > 1 or flag_in > 1 or flag_out > 1:
  sys.stderr.write("Chyba zadanych parametru pro dalsi info --help\n")
  sys.exit(1)
# nezadani parametru
if flag_i == 0 and flag_h == 0 and flag_k == 0 and flag_o == 0 and flag_ik == 0 and flag_c == 0 and flag_w == 0:
  sys.stderr.write("Chyba zadanych parametru pro dalsi info --help\n")
  sys.exit(1)
# pole absolutnich cest
ways = []
# pole souboru
files = []
# slovnik pro ukladani dvojic soubor s absolutni cestou : pocet vyskytu hledaneho elementu
alist = {}
# surovy retezec znaku ze souboru
raw = ""
# funkce pro ziskani souboru a absolutnich cest - naplni globalni promenne ways a files
def getFiles():
  global ways, files
  fl = []
  if os.path.isdir(in_file):
    os.chdir(in_file)
  ways.append(os.getcwd()+'/')
  subd = []
  for a in ways:
    os.chdir(a)
    subd = glob.glob('*/') # podslozky
    for c in subd:
      z = os.getcwd()+'/'+c # absolutni cesta
      ways.append(z)
    fl = glob.glob('*.[chCH]')# filtrovani souboru
    for i in fl:
      files.append(a+i)

# vyhledani pozadovanych polozek 
# return pocet polozek hledaneho typu
def findT():
  global raw, files, in_file, flag_i, flag_o, flag_k, flag_ik
  if raw == "":
    return 0
  s = raw.split(' ')
  c = 0
  idn = 0
  kw = 0
  op = 0
  tmp = []
  # operatory
  for i in range(0,len(s)):
    for j in range(0,len(operators)):
      if re.search(operators[j],s[i]):
        tmp = re.findall(operators[j],s[i])
        op += len(tmp)
        s[i] = re.sub(operators[j],' ',s[i])
  # klicova slova		
  for i in range(0,len(s)):
    for j in range(0,len(keywords)):
      if re.search(keywords[j],s[i]):
        tmp = re.findall(keywords[j],s[i])
        kw += len(tmp)
        s[i] = re.sub(keywords[j],' ',s[i])
  # identifikatory
  for i in s:
    if re.search("\\b[_a-zA-Z][_0-9a-zA-Z]*\\b", i):
      tmp = re.findall("\\b[_a-zA-Z][_0-9a-zA-Z]*\\b", i)
      idn += len(tmp)
  if flag_i:
    c = idn
  elif flag_o:
    c = op
  elif flag_k:
    c = kw
  elif flag_ik:
    c = kw + id

  return c

# funkce ridici trideni dat na komentare, text, makra (zahazuji se)
# provedeni zakladni filtrace znaku a plneni slovniku daty
def findIt():
  global flag_c, fralg_w, files, alist, raw, w, other
  # nastaveni flagu pro rizeni pruchodu a promennych
  esc_f = 0 # pritomnost escape sekvence
  com_f = 0 # komentar: 1 - radkovy, 2 - blokovy
  text_f = 0 # text: 1 - uvozovky, 2 - apostrofy
  mak_f = 0  # makro
  ctrl_f = 0 # vyhodnoceni: 0 - ziskani typu stavu, 1 - jsem jiz ve stavu dale dle ostatnich flagu
  text = "" # textova cast
  com = "" # komentare
  start_f = 0 # pomocny flag pro komentare urcuje zda jsme do nej prave vesli a podili se na dalsim rizeni
  count = 0 # pocet vyskytu

  for f in files:
    try:
      d = open(f, 'r')
    except:
      sys.stderr.write("Chyba otevteni souboru: ")
      sys.stderr.write(f)
      sys.stderr.write("\n")
      continue
    raw = ""
    raw = d.read()
    d.close()
    for i in raw:
      if ctrl_f == 0:
        if i == '#':
          ctrl_f = 1
          mak_f = 1
        elif i == "\"":
          ctrl_f = 1
          text_f = 1
        elif i == '\'':
          text_f = 2
          ctrl_f = 1
        elif i == "/" and start_f == 0:
          start_f = 1
        elif start_f == 1:
          if i == "/":
            start_f = 0
            com_f = 1
            com += "//"
            ctrl_f = 1
          elif i == "*":
            start_f = 0
            com_f = 2
            com += '/*'
            ctrl_f = 1
          else:
            start_f = 0
            text += '/'
            text += i 
        else:
          text += i
      else:
        if text_f == 1:# uvozovky
          if i == "\\":
            esc_f = 1
          if i == "\"" and esc_f == 1:
            esc_f = 0
          if i == "\"" and esc_f == 0:
            text_f = 0
            ctrl_f = 0
            text += ' '
        if text_f == 2:# apostrof
          if i == '\'':
            text_f = 0
            ctrl_f = 0
            text += ' '
        if com_f == 1: # radkovy komentar
          com += i
          if i == '\\' and esc_f == 0:
            esc_f = 1
          elif esc_f == 1 and i == '\\':
            esc_f = 0
          elif i == '\n' and esc_f == 0:
            com_f = 0
            ctrl_f = 0
            text += " "
          elif esc_f == 1 and i != '\n':
            esc_f = 0
        if com_f == 2: # blokovy komentar
          com += i
          if i == "*":
            start_f = 1
          elif i == "/" and start_f == 1:
            ctrl_f = 0
            start_f = 0
            com_f = 0
            text += " "
          else:
            if start_f == 1:
              start_f = 0
        if mak_f == 1:# makro
          if i == "\\":
            esc_f = 1
          elif i == "\n" and esc_f == 1:
             esc_f = 0
          elif i == "\n" and esc_f == 0:
            ctrl_f = 0
            mak_f = 0
            esc_f = 0
            text += ' '
    if flag_c == 0 and flag_w == 0:
      for i in other:
        text = re.sub(i,' ',text)
      raw = text
      count = findT()
    elif flag_c == 1:
      count = len(com)
    elif flag_w == 1:
      count = len(re.findall(w, raw))
    alist.update({f:count}) # do vysledneho slovniku pridame vysledek
	# resetujeme flagy
    esc_f = 0
    com_f = 0
    text_f = 0
    mak_f = 0
    ctrl_f = 0
    text = ""
    com = ""
    start_f = 0
		
# vytiskne do souboru nebo na STDOUT
def printList():
  global alist, out_file, startdir
  celkem = 0
  gap = 8
  p = []
  sl = []
  psl = []
  sl = list(alist.keys()) # naplneni pomocneho pole klicovimy hodnotami slovniku
  tmp = ""
  for k, v in alist.items():#nejdelsi retezec a celkovy pocet vyskytu
    celkem += v
    if flag_p == 0:
      if gap < len(k)+len(str(v))+1:
        gap = len(k)+len(str(v))+1
    else:
      p = k.split('/')
      psl.append(p[-1])
      if gap < len(p[-1])+len(str(v))+1:
        gap = len(p[-1])+len(str(v))+1
  if gap < len("celkem: ")+len(str(celkem)):
    gap = len("celkem: ")+len(str(celkem))
  if flag_p == 1: # serazeni vypisu
    psl.sort()
    for i in range(0,len(psl)):
      a = sl[i].split('/')
      if psl[i] != a[-1]:
        for j in range(i+1, len(psl)):
          b = sl[j].split('/')
          if b[-1] == psl[i]:
            c = sl[j]
            sl[j] = sl[i]
            sl[i] = c
  else:
    sl.sort()
  if out_file != "": # vypis do souboru
    os.chdir(startdir)
    try:
      d = open(out_file, 'w')
    except:
      sys.stderr.write("Chyba otevreni souboru: ")
      sys.stderr.write(out_file)
      sys.stderr.write("\n")
      sys.exit(3)
    for l in sl:
      tmp = ""
      if flag_p == 1:
        p = l.split('/')
        for i in range(0, gap-len(p[-1])-len(str(alist[l]))):
          tmp += ' '
        d.write(p[-1])
      else:
        for i in range(0,gap-len(l)-len(str(alist[l]))):
          tmp += ' '
        d.write(l)
      d.write(tmp)
      d.write(str(alist[l]))
      d.write("\n")
    tmp = ""    
    for i in range(0,gap-len("CELKEM:")-len(str(celkem))):
      tmp += ' '
    d.write('CELKEM:')
    d.write(tmp)
    d.write(str(celkem))
    d.write('\n')
    d.close()
    sys.exit(0)
  else: # vypis na STDOUT
    for l in sl:
      tmp = ""
      if flag_p == 1: # vypocet mezery
        p = l.split('/')
        for i in range(0, gap-len(p[-1])-len(str(alist[l]))):
          tmp += ' '
        sys.stdout.write(p[-1])
        sys.stdout.write(tmp)
        sys.stdout.write(str(alist[l]))
        sys.stdout.write('\n')
      else:
        for i in range(0,gap-len(l)-len(str(alist[l]))):
          tmp += ' '
        sys.stdout.write(l)
        sys.stdout.write(tmp)
        sys.stdout.write(str(alist[l]))
        sys.stdout.write('\n')
    tmp = ""    
    for i in range(0,gap-len("CELKEM:")-len(str(celkem))):
      tmp += ' '
    sys.stdout.write ('CELKEM:')
    sys.stdout.write(tmp)
    sys.stdout.write(str(celkem))
    sys.stdout.write('\n')
    sys.exit(0)

# urceni zda byl zadan adresar nebo soubor a volani patricne fce  
if flag_in == 1 and not os.path.isdir(in_file):
  tmp = []
  tmp = in_file.split('/')
  try:
    t = open(in_file,'r')
  except:
    sys.stderr.write("Chyba otevreni souboru: ")
    sys.stderr.write(in_file)
    sys.stderr.write("\n")
    sys.exit(2)
  t.close()
  for i in tmp:
    if i == tmp[-1]:
      break
    os.chdir(i)
  files.append(os.getcwd()+'/'+tmp[-1])
else:
  if flag_in == 0 and os.path.isdir(in_file):
    os.chdir(infile)
  getFiles()
findIt()
printList()
sys.exit(0)

