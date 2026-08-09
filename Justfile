default:
    @just --list

check:
    nerd check main.n

build:
    @mkdir -p _bin
    nerd build --output _bin/main main.n

run *args:
    just build
    ./_bin/main {{args}}

clean:
    rm -rf _*

alias ch := check
alias b := build
alias r := run
alias c := clean
