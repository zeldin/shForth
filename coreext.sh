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

true_() {
  push -1
}
builtin 'true' true_

tuck() {
  pop x2
  pop x1
  push "$x2"
  push "$x1"
  push "$x2"
}
builtin 'tuck' tuck

not_equals() { # <>
  pop n2
  pop n1
  if "$expr" "$n1" '!=' "$n2" >/dev/null; then
    push -1
  else
    push 0
  fi
}
builtin '<>' not_equals

zero_not_equals() { # 0<>
  pop n
  if "$expr" 0 '!=' "$n" >/dev/null; then
    push -1
  else
    push 0
  fi
}
builtin '0<>' zero_not_equals

zero_greater() { # 0>
  pop n
  if "$expr" 0 '<' "$n" >/dev/null; then
    push -1
  else
    push 0
  fi
}
builtin '0>' zero_greater
