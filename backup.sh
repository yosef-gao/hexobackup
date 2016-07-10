#!/bin/bash

echo 'deploy...'
hexo g > /dev/null
hexo d >> log.txt 2>&1 

echo 'backup...'
git add -A .
git commit -m 'backup' >> /dev/null
git push >> log.txt 2>&1
