#!/bin/sh

for i in TestSuite/sem*.pas; do
    echo "testing $i"
    base=$(basename "$i" .pas)
    python parser.py < "$i" >> "Output/sem.out.txt"
done
