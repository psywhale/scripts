#!/bin/bash

mkdir $1 && cd $1
mkdir tasks handlers templates files vars meta
for i in defaults tasks vars handlers meta; do
        if [[ ! -f ${i}/main.yaml ]]; then
        echo creating file:  ${1}/${i}/main.yaml
        echo "---
# vim: set et ts=2 sw=2:
" > ${i}/main.yaml
        else
            echo ${i}/main.yaml exists skipping
        fi
done


cd ..
