#! /bin/sh

parse() {
  pop c
  push `inbufgetaddr`
  n=0;
  while inbufget xc; do
    if test $xc = $c; then break; fi
    n="`\"$expr\" $n + 1`"
  done
  push $n
}
builtin 'parse' parse

dot_s() { # .s
  n=0
  while expr $n '<' $sp >/dev/null; do
    eval "echo $n : \$stk_$n"
    n="`\"$expr\" $n + 1`"
  done
}
builtin '.s' dot_s

bye() {
  exit
}
builtin 'bye' bye

nip() {
  pop x2
  pop x1
  push "$x2"
}
builtin 'nip' nip

tuck() {
  pop x2
  pop x1
  push "$x2"
  push "$x1"
  push "$x2"
}
builtin 'tuck' tuck
