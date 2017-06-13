#! /bin/sh

inbufgetaddr() {
  to_in; fetch; pop in
  "$expr" $in + $inbuf
}

inbufadv() {
  push "`\"$expr\" $in + 1`"; to_in; store
}

inbufpeek() {
  to_in; fetch; pop in
  if expr $in '>=' $inbuflen >/dev/null; then
    return 1
  fi
  push "`\"$expr\" $in + $inbuf`"; fetch; pop $1  
  return 0
}

inbufget() {
  if inbufpeek $1; then
    inbufadv
    return 0
  else
    return 1
  fi
}

readbyt() {
  c=`"$dd" bs=1 count=1 2>/dev/null | "$od" -t d1 -An`
}

graphic_32=' '
graphic_33='!'
graphic_34='"'
graphic_35='#'
graphic_36='$'
graphic_37='%'
graphic_38='&'
graphic_39="'"
graphic_40='('
graphic_41=')'
graphic_42='*'
graphic_43='+'
graphic_44=','
graphic_45='-'
graphic_46='.'
graphic_47='/'
graphic_48='0'
graphic_49='1'
graphic_50='2'
graphic_51='3'
graphic_52='4'
graphic_53='5'
graphic_54='6'
graphic_55='7'
graphic_56='8'
graphic_57='9'
graphic_58=':'
graphic_59=';'
graphic_60='<'
graphic_61='='
graphic_62='>'
graphic_63='?'
graphic_64='@'
graphic_65='A'
graphic_66='B'
graphic_67='C'
graphic_68='D'
graphic_69='E'
graphic_70='F'
graphic_71='G'
graphic_72='H'
graphic_73='I'
graphic_74='J'
graphic_75='K'
graphic_76='L'
graphic_77='M'
graphic_78='N'
graphic_79='O'
graphic_80='P'
graphic_81='Q'
graphic_82='R'
graphic_83='S'
graphic_84='T'
graphic_85='U'
graphic_86='V'
graphic_87='W'
graphic_88='X'
graphic_89='Y'
graphic_90='Z'
graphic_91='['
graphic_92='\'
graphic_93=']'
graphic_94='^'
graphic_95='_'
graphic_96='`'
graphic_97='a'
graphic_98='b'
graphic_99='c'
graphic_100='d'
graphic_101='e'
graphic_102='f'
graphic_103='g'
graphic_104='h'
graphic_105='i'
graphic_106='j'
graphic_107='k'
graphic_108='l'
graphic_109='m'
graphic_110='n'
graphic_111='o'
graphic_112='p'
graphic_113='q'
graphic_114='r'
graphic_115='s'
graphic_116='t'
graphic_117='u'
graphic_118='v'
graphic_119='w'
graphic_120='x'
graphic_121='y'
graphic_122='z'
graphic_123='{'
graphic_124='|'
graphic_125='}'
graphic_126='~'
