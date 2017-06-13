#! /bin/sh

builtin() {
  x="$1"
  n="$2"
  set `eval "$echo_nocr" | "$od" -t d1 -An`
  currdef="wrd_$#_`echo \"$@\" | \"$sed\" -e 's/ /_/g'`"
  eval "$currdef='$n'"
}

identifier() {
  addr="$1"
  n=`peek "$addr"`
  x="wrd_$n"
  addr="`\"$expr\" $addr + 1`"
  while expr 0 '<' $n >/dev/null; do
    x="${x}_`peek \"$addr\"`"
    addr="`\"$expr\" $addr + 1`"
    n="`\"$expr\" $n - 1`"
  done
}

interpret() {
  rpush "$ip"
  ip="$1"
}

run() {
  while :; do
    xt=`peek $ip`
    ip="`\"$expr\" 1 + $ip`"
    eval "$xt"
  done
}
