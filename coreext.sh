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
