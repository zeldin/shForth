#! /bin/sh

# 
# not implemented yet:
# 
# fm/mod, key, lshift, rshift, sm/rem, um/mod, xor
# 

immediate() {
  eval "im$currdef=1"
}
builtin 'immediate' immediate

store() { # ! / c!
  pop addr
  pop x
  poke "$addr" "$x"
}
builtin '!' store
builtin 'c!' store

number_sign() {
  pop n
  pop n
  b=`peek $base_addr`
  push `"$expr" "$n" / "$b"`
  push 0
  n=`"$expr" "$n" '%' "$b"`
  if "$expr" 10 '>' "$n" >/dev/null; then
    push `"$expr" 48 + "$n"`
  else
    push `"$expr" 87 + "$n"`
  fi
  hold
}
builtin '#' number_sign

number_sign_greater() { # #>
  pop x
  pop x
  push $hold_addr
  push `"$expr" $hold_base - $hold_addr`
}
builtin '#>' number_sign_greater

number_sign_s() { # #s
  n=1
  while test 0 != "$n"; do
    number_sign
    pop n
    pop n
    push "$n"
    push 0
  done
}
builtin '#s' number_sign_s

tick() { # '
  push 32; word
  find
  pop x
}
builtin "'" tick

paren() { # (
  push 41; parse
  pop x; pop x
}
builtin "(" paren
immediate

star() { # *
  pop n2
  pop n1
  push `"$expr" "$n1" '*' "$n2"`  
}
builtin '*' star

star_slash() { # */
  pop n3
  pop n2
  pop n1
  push `"$expr" "$n1" '*' "$n2" / "$n3"`
}
builtin '*/' star_slash

star_slash_mod() { # */mod
  pop n3
  pop n2
  pop n1
  push `"$expr" "$n1" '*' "$n2" '%' "$n3"`
  push `"$expr" "$n1" '*' "$n2" / "$n3"`
}
builtin '*/mod' star_slash_mod

plus() { # +
  pop n2
  pop n1
  push `"$expr" "$n1" + "$n2"`
}
builtin '+' plus

plus_store() { # +!
  pop addr
  pop x
  y="`peek \"$addr\"`"
  poke "$addr" "`\"$expr\" \"$x\" + \"$y\"`"
}
builtin '+!' plus_store

plus_loop() { # +loop
  pop y
  pop x
  push 'pop n; rpop i; rpop limit; i2="`\"$expr\" "$n" + "$i"`"; if test `"$expr" "$i" "<" "$limit"` = `"$expr" "$i2" "<" "$limit"`; then rpush "$limit"; rpush "$i2"; ip='"'$x'"'; fi'; comma
  for i in $y; do
    poke $i "rpop i; rpop limit; ip='$dsp'"
  done
}
builtin '+loop' plus_loop
immediate

comma() { # , / c,
  pop x
  poke $dsp "$x"
  dsp="`\"$expr\" $dsp + 1`"
}
builtin ',' comma
builtin 'c,' comma

minus() { # -
  pop n2
  pop n1
  push `"$expr" "$n1" - "$n2"`
}
builtin '-' minus

dot() { # .
  less_number_sign
  dup; abs
  push 0; number_sign_s; rote; sign
  number_sign_greater
  type_
  space
}
builtin '.' dot

dot_quote() { # ."
  push 34; parse
  if test `peek $state` = 0; then
    type_
  else
    pop n
    pop addr
    s=""
    while test $n != 0; do
      eval 's="$s$graphic_'"`peek $addr`"'"'
      addr="`\"$expr\" $addr + 1`"
      n="`\"$expr\" $n - 1`"
    done
    poke "$dsp" "x='\"'\"'`echo \"$s\" | \"$sed\" -e \"s/'/'\\\"'\\\"'\\\"'\\\"'\\\"'\\\"'\\\"'\\\"'/g\"`'\"'\"'; eval \"\$echo_nocr\""
    push 1; allot
  fi
}
builtin '."' dot_quote
immediate

slash() { # /
  pop n2
  pop n1
  push `"$expr" "$n1" / "$n2"`
}
builtin '/' slash

slash_mod() { # /mod
  pop n2
  pop n1
  push `"$expr" "$n1" '%' "$n2"`
  push `"$expr" "$n1" / "$n2"`
}
builtin '/mod' slash_mod

zero_less() { # 0<
  pop n
  if "$expr" 0 '>' "$n" >/dev/null; then
    push -1
  else
    push 0
  fi
}
builtin '0<' zero_less

zero_equals() { # 0=
  pop n
  if "$expr" 0 '=' "$n" >/dev/null; then
    push -1
  else
    push 0
  fi
}
builtin '0=' zero_equals

one_plus() { # 1+
  pop n
  push "`\"$expr\" 1 + \"$n\"`"
}
builtin '1+' one_plus

one_minus() { # 1-
  pop n
  push "`\"$expr\" \"$n\" - 1`"
}
builtin '1-' one_minus

two_store() { # 2!
  swap; over; store; cell_plus; store
}
builtin '2!' two_store

two_star() { # 2*
  pop n
  push "`\"$expr\" \"$n\" '*' 2`"
}
builtin '2*' two_star

two_slash() { # 2/
  pop n
  push "`\"$expr\" \"$n\" '/' 2`"
}
builtin '2/' two_slash

two_fetch() { # 2@
  dup; cell_plus; fetch; swap; fetch
}
builtin '2@' two_fetch

two_drop() { # 2drop
  pop x; pop x
}
builtin '2drop' two_drop

two_dup() { # 2dup
  pop x2
  pop x1
  push "$x1"
  push "$x2"
  push "$x1"
  push "$x2"
}
builtin '2dup' two_dup

two_over() { # 2over
  pop x4
  pop x3
  pop x2
  pop x1
  push "$x1"
  push "$x2"
  push "$x3"
  push "$x4"
  push "$x1"
  push "$x2"
}
builtin '2over' two_over

two_swap() { # 2swap
  pop x4
  pop x3
  pop x2
  pop x1
  push "$x3"
  push "$x4"
  push "$x1"
  push "$x2"
}
builtin '2swap' two_swap

colon() { # :
  create
  unset "$currdef"
  push "$dsp"
  poke $state 1
}
builtin ':' colon

semicolon() { # ;
  pop colon_sys
  push "_exit" ; comma
  eval "$currdef='interpret $colon_sys'"
  poke $state 0
}
builtin ';' semicolon
immediate

less_than() { # <
  pop n2
  pop n1
  if "$expr" "$n1" '<' "$n2" >/dev/null; then
    push -1
  else
    push 0
  fi
}
builtin '<' less_than

less_number_sign() { # less_number_sign
  hold_addr=$hold_base
}
builtin '<#' less_number_sign

equals() { # =
  pop n2
  pop n1
  if "$expr" "$n1" '=' "$n2" >/dev/null; then
    push -1
  else
    push 0
  fi
}
builtin '=' equals

greater_than() { # >
  pop n2
  pop n1
  if "$expr" "$n1" '>' "$n2" >/dev/null; then
    push -1
  else
    push 0
  fi
}
builtin '>' greater_than

to_body() { # >body
  pop n
  push `echo "$n" | "$sed" -e 's/^.*interpret //'`
}
builtin '>body' to_body

to_in() { # >in
  push $in_addr
}
builtin '>in' to_in

to_number() { # >number
  pop n2
  pop addr
  pop n1
  pop n1
  b="`peek $base_addr`"
  while "$expr" 0 '<' $n2 >/dev/null; do
    c=`peek $addr`
    if "$expr" 58 '>' "$c" >/dev/null; then
      c="`\"$expr\" \"$c\" - 48`"
    elif "$expr" 96 '<' "$c" >/dev/null; then
      c="`\"$expr\" \"$c\" - 87`"
    elif "$expr" 64 '<' "$c" >/dev/null; then
      c="`\"$expr\" \"$c\" - 55`"
    else
      break;
    fi
    if "$expr" 0 '>' "$c" >/dev/null || "$expr" "$b" '<=' "$c" >/dev/null; then
      break;
    fi
    n1=`"$expr" $n1 '*' "$b" + $c`
    addr="`\"$expr\" $addr + 1`"
    n2="`\"$expr\" $n2 - 1`"
  done
  push $n1
  push 0
  push $addr
  push $n2
}
builtin '>number' to_number

to_r() { # >r
  pop x
  rpush "$x"
}
builtin '>r' to_r

question_dupe() { # ?dup
  pop x
  push "$x"
  if test 0 != "$x"; then
    push "$x"
  fi
}
builtin '?dup' question_dupe

fetch() { # @ / c@
  pop addr
  push "`peek $addr`"
}
builtin '@' fetch
builtin 'c@' fetch

abort() {
  sp=0
  interpret "$quit"
}
builtin 'abort' abort

abort_quote() { # abort"
  if test 0 = `peek $state`; then
    pop n
    if test 0 = $n; then
      push 34; parse
      pop n
      pop n
    else
      dot_quote
      c_r; abort
    fi
  else
    push 'pop n; if test 0 = $n; then ip='"`\"$expr\" $dsp + 3`"'; fi'; comma
    dot_quote
    push "c_r; abort"; comma
  fi
}
builtin 'abort"' abort_quote
immediate

abs() {
  pop n
  if "$expr" 0 '>' "$n" >/dev/null; then
    push "`\"$expr\" 0 - \"$n\"`"
  else
    push "$n"
  fi
}
builtin 'abs' abs

accept() {
  pop n1
  pop c_addr
  n2=0
  while "$expr" 0 '<' $n1 >/dev/null; do
    readbyt
    if test 10 = $c; then
      n1=0
    else
      poke $c_addr $c
      c_addr="`\"$expr\" $c_addr + 1`"
      n1="`\"$expr\" $n1 - 1`"
      n2="`\"$expr\" $n2 + 1`"
    fi
  done
  push $n2
}
builtin 'accept' accept

align() {
  :
}
builtin 'align' align
builtin 'aligned' align

allot() {
  pop n
  dsp="`\"$expr\" $dsp + \"$n\"`"
}
builtin 'allot' allot

and() {
  pop n2
  pop n1
  push `"$expr" "$n1" \& "$n2"`
}
builtin 'and' and

base() {
  push $base_addr
}
builtin 'base' base

begin() {
  push "$dsp"
}
builtin 'begin' begin
immediate

b_l() {
  push 32
}
builtin 'bl' b_l

cell_plus() { # cell+ / char+
  pop n
  push "`\"$expr\" 1 + \"$n\"`"
}
builtin 'cell+' cell_plus
builtin 'char+' cell_plus

cells() { # cells / chars
  :
}
builtin 'cells' cells
builtin 'chars' cells

char() {
  push 32; word; pop addr
  x="`peek \"$addr\"`"
  if test 0 = "$x"; then
    push 0
  else
    addr="`\"$expr\" 1 + \"$addr\"`"
    push "`peek \"$addr\"`"
  fi
}
builtin 'char' char

constant() {
  pop val
  push 32; word; pop addr
  identifier "$addr"
  if eval "test ! -z \"\$$x\""; then
    echo "? word exists"
  else
    eval "$x=\"push $val\""
  fi
}
builtin 'constant' constant

count() {
  pop c_addr
  u=`peek $c_addr`
  c_addr="`\"$expr\" $c_addr + 1`"
  push $c_addr
  push $u
}
builtin 'count' count

c_r() {
  echo ""
}
builtin 'cr' c_r

create() {
  push "$dsp"
  constant
  currdef="$x"
}
builtin 'create' create

decimal() {
  poke $base_addr 10
}
builtin 'decimal' decimal

depth() {
  push "$sp"
}
builtin 'depth' depth

_do() {
  push 'swap; to_r; to_r'; comma
  push "$dsp"
  push ""
}
builtin 'do' _do
immediate

does() { # does>
  eval "$currdef=\"\$$currdef\"'; interpret $ip'"
  rpop ip
}
builtin 'does>' does

drop() { # drop
  pop x
}
builtin 'drop' drop

dup() {
  pop x
  push "$x"
  push "$x"
}
builtin 'dup' dup

_else() {
  pop n
  push $dsp
  push ':'; comma
  poke "$n" "ip=$dsp"
}
builtin 'else' _else
immediate

emit() {
  pop x
  eval "x=\"\$graphic_$x\""
  eval "$echo_nocr"
}
builtin 'emit' emit

environment_query() {
  pop n ; pop n
  push 0
}
builtin 'environment?' environment_query

number() {
 pop n_addr; push 0; push 0; push "$n_addr"; count
 to_number
 pop n2; pop tmp; pop n1; pop n1
 if test 0 = $n2; then
   push $n1
   if test `peek $state` != 0; then literal; fi
 else
   x='? undefined word '; eval "$echo_nocr"; push "$n_addr"; count; type_; c_r
   interpret "$quit"
   return
 fi
}

evaluate="$dsp"
  push 'pop inbuflen; pop inbuf; push 0; to_in; store;'; comma
  l="$dsp"
    push 'push 32; word;'; comma
    push 'if test `peek $wordbuf` = 0; then pop tmp; _exit; fi'; comma
    push find; comma
    push 'pop n; case $n in 0) number;; 1) execute;; -1) if test `peek $state` = 0; then execute; else comma; fi;; esac'; comma
  push "ip=$l"; comma
builtin 'evaluate' "interpret $evaluate"

execute() {
  pop xt
  eval "$xt"
}
builtin 'execute' execute

_exit() {
  rpop ip
}
builtin 'exit' _exit

fill() {
  pop c
  pop n
  pop addr
  while expr 0 '<' "$n" >/dev/null; do
    poke "$addr" "$c"
    addr="`\"$expr\" 1 + \"$addr\"`"
    n="`\"$expr\" \"$n\" - 1`"
  done
}
builtin 'fill' fill

find() {
  pop addr0
  identifier "$addr0"
  n="`eval 'echo $'$x`"
  if test -z "$n"; then
    push "$addr0"
    push 0
  else
    push "$n"
    if test -z "`eval 'echo $im'$x`"; then
      push -1
    else
      push 1
    fi
  fi
}
builtin 'find' find

here() {
  push $dsp
}
builtin 'here' here

hold() {
  pop x
  hold_addr=`"$expr" $hold_addr - 1`
  poke $hold_addr "$x"
}
builtin 'hold' hold

_i() {
  rpop i
  rpush "$i"
  push "$i"
}
builtin 'i' _i

_if() {
  push 'pop n; if test 0 != "$n"; then ip='"`\"$expr\" $dsp + 2`"'; fi'; comma
  push $dsp
  push ':'; comma
}
builtin 'if' _if
immediate

invert() {
  pop x
  push "`\"$expr\" -1 - \"$x\"`"
}
builtin 'invert' invert

_j() {
  rpop i
  rpop x
  rpop j
  rpush "$j"
  rpush "$x"
  rpush "$i"
  push "$j"
}
builtin 'j' _j

leave() {
  pop y
  push "$y $dsp"
  push ":"; comma
}
builtin 'leave' leave
immediate

literal() {
  pop x
  push "push '$x'"
  comma
}
builtin 'literal' literal
immediate

loop() {
  pop y
  pop x
  push 'rpop i; rpop limit; i="`\"$expr\" 1 + "$i"`"; if test x"$i" != x"$limit"; then rpush "$limit"; rpush "$i"; ip='"'$x'"'; fi'; comma
  for i in $y; do
    poke $i "rpop i; rpop limit; ip='$dsp'"
  done
}
builtin 'loop' loop
immediate

m_star() { # m*
  pop n2
  pop n1
  push `"$expr" "$n1" '*' "$n2"`  
  push 0
}
builtin 'm*' m_star

max() {
  pop n2
  pop n1
  if "$expr" "$n1" '>' "$n2" >/dev/null; then
    push "$n1"
  else
    push "$n2"
  fi
}
builtin 'max' max

min() {
  pop n2
  pop n1
  if "$expr" "$n1" '<' "$n2" >/dev/null; then
    push "$n1"
  else
    push "$n2"
  fi
}
builtin 'min' min

mod() {
  pop n2
  pop n1
  push `"$expr" "$n1" '%' "$n2"`
}
builtin 'mod' mod

move() {
  pop n
  pop c_addr
  pop addr
  while "$expr" 0 '<' "$n" >/dev/null; do
    poke "$c_addr" "`peek \"$addr\"`"
    addr="`\"$expr\" 1 + \"$addr\"`"
    c_addr="`\"$expr\" 1 + \"$c_addr\"`"
    n="`\"$expr\" $n - 1`"
  done
}
builtin 'move' move

negate() {
  pop x
  push "`\"$expr\" 0 - \"$x\"`"
}
builtin 'negate' negate

or() {
  pop n2
  pop n1
  push `"$expr" "$n1" \| "$n2"`
}
builtin 'or' or

over() {
  pop x2
  pop x1
  push "$x1"
  push "$x2"
  push "$x1"
}
builtin 'over' over

postpone() {
  push 32
  word
  pop p_addr
  push "$p_addr"
  find
  pop n
  if test 0 = "$n"; then
   x='? undefined word '; eval "$echo_nocr"; push "$p_addr"; count; type_; c_r
   interpret "$quit"
  else
    comma
  fi
}
builtin 'postpone' postpone
immediate

quit="$dsp"
  push 'rp=0; poke $state 0'; comma
  l="$dsp"
    push 'push $tib; push $tib; push $tibmax'; comma
    push accept; comma
    push "interpret $evaluate"; comma
    push 'if test `peek $state` = 0; then echo "ok"; fi'; comma
  push "ip=$l"; comma
builtin 'quit' "interpret $quit"

r_from() {
  rpop x
  push "$x"
}
builtin 'r>' r_from

r_fetch() {
  rpop x
  rpush "$x"
  push "$x"
}
builtin 'r@' r_fetch

recurse() {
  push "\$$currdef"; comma
}
builtin 'recurse' recurse
immediate

_repeat() {
  pop x2
  pop x1
  push "ip=$x2"; comma
  poke "$x1" "ip=$dsp"
}
builtin 'repeat' _repeat
immediate

rote() {
  pop x3
  pop x2
  pop x1
  push "$x2"
  push "$x3"
  push "$x1"
}
builtin 'rot' rote

s_quote() {
  push 34; parse
  pop x2; pop x1
  if test `peek $state` = 0; then
    push "$dsp"; push "$x2"
  else
    push "push `\"$expr\" 1 + \"$dsp\"`; push '$x2'; ip=`\"$expr\" 1 + \"$dsp\" + \"$x2\"`"; comma
  fi
  push "$x1"; push "$dsp"; push "$x2"
  move
  dsp="`\"$expr\" \"$dsp\" + \"$x2\"`"
}
builtin 's"' s_quote
immediate

s_to_d() {
  push 0
}
builtin 's>d' s_to_d

sign() {
  pop n
  if "$expr" 0 '>' "$n" >/dev/null; then
    push 45
    hold
  fi
}

source_() {
  push $inbuf
  push $inbuflen
}
builtin 'source' source_

space() {
  x=" "
  eval "$echo_nocr"
}
builtin 'space' space

spaces() {
  pop n
  while "$expr" 9 '<' $n >/dev/null; do
    x="          "
    eval "$echo_nocr"
    n="`\"$expr\" $n - 10`"
  done
  eval 'case "$n" in
    1) x=" " ;;
    2) x="  " ;;
    3) x="   " ;;
    4) x="    " ;;
    5) x="     " ;;
    6) x="      " ;;
    7) x="       " ;;
    8) x="        " ;;
    9) x="         " ;;
    *) x=""
  esac'
  eval "$echo_nocr"
}
builtin 'spaces' spaces

state_() { # state
   push "$state"
}
builtin 'state' state_

swap() {
  pop x2
  pop x1
  push "$x2"
  push "$x1"
}
builtin 'swap' swap

_then() {
  pop n
  poke "$n" "ip=$dsp"
}
builtin 'then' _then
immediate

type_() {
  pop u
  pop c_addr
  while "$expr" 0 '<' $u >/dev/null; do
    push `peek $c_addr`
    emit
    c_addr="`\"$expr\" $c_addr + 1`"
    u="`\"$expr\" $u - 1`"
  done
}
builtin 'type' type_

builtin 'u.' dot

builtin 'u<' less_than

builtin 'um*' m_star

unloop() {
  rpop i
  rpop limit
}
builtin 'unloop' unloop

_until() {
  pop n
  push 'pop n; if test 0 = "$n"; then ip='"$n"'; fi'; comma
}
builtin 'until' _until
immediate

variable() {
  create
  poke "$dsp" 0
  push 1; allot;
}
builtin 'variable' variable

_while() {
  push 'pop n; if test 0 != "$n"; then ip='"`\"$expr\" $dsp + 2`"'; fi'; comma
  pop x1
  push "$dsp"
  push "$x1"
  push ':'; comma
}
builtin 'while' _while
immediate

word() {
  pop c
  while inbufpeek xc; do
    if test $xc != $c; then
      break;
    else
      inbufadv
    fi
  done
  push "$c"
  parse
  pop n
  pop c_addr
  poke $wordbuf $n
  while test 0 != "$n"; do
    a="`\"$expr\" $c_addr + $n - 1`"
    poke "`\"$expr\" $wordbuf + $n`" "`peek $a`"
    n="`\"$expr\" $n - 1`"
  done
  push $wordbuf  
}
builtin 'word' word

left_bracket() { # [
  poke state 0
}
builtin '[' left_bracket
immediate

bracket_tick() { # [']
  tick; literal
}
builtin "[']" bracket_tick
immediate

bracket_char() { # [char]
  char
  literal
}
builtin '[char]' bracket_char
immediate

right_bracket() { # ]
  poke state 1
}
builtin ']' right_bracket

here ; pop tib
tibmax=1024
push $tibmax ; allot

here ; pop wordbuf
push $tibmax ; allot

here ; pop in_addr
push 1 ; allot

here ; pop base_addr
push 1 ; allot
decimal

here ; pop state
push 1 ; allot

push $tibmax ; allot
here ; pop hold_base
