#! /bin/sh

dsp=0

poke() {
  eval "cell_$1='$2'"
}

peek() {
  eval "echo \$cell_$1"
}

lowercase() {
  if test 65 -le "$1" -a "$1" -le 90; then # 'A' <= $1 <= 'Z'
    echo `"$expr" "$1" + 32` # $1 + 'a' - 'A'
  else
    echo "$1"
  fi
}

sp=0

push() {
  eval "stk_$sp='$1'"
  sp="`\"$expr\" $sp + 1`"
}

pop() {
  if test 0 = $sp; then
    echo "? stack empty"
    eval "$1=0"
    interpret $quit
  else
    sp="`\"$expr\" $sp - 1`"
    eval "$1=\"\$stk_$sp\""
  fi
}

rp=0

rpush() {
  eval "rstk_$rp=$1"
  rp="`\"$expr\" $rp + 1`"
}

rpop() {
  if test 0 = $rp; then
    echo "? return stack empty"
    eval "$1=0"
    interpret $quit
  else
    rp="`\"$expr\" $rp - 1`"
    eval "$1=\$rstk_$rp"
  fi
}

