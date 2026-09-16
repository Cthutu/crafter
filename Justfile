default:
    @just --list

check:
    nerd check main.n

build:
    @mkdir -p _bin
    nerd build --output _bin/crafter main.n

run *args:
    just build
    ./_bin/crafter {{args}}

clean:
    rm -rf _*

craft *args:
    just run --stack 64 atm10.txt {{args}}

alias ch := check
alias b := build
alias r := run
alias c := clean
