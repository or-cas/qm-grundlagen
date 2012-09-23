#!/bin/sh

while (true); do `make clean`; echo `date +%T` `make`; sleep 10; done
