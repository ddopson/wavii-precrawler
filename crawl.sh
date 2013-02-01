cat urls | parallel -j96 wget --restrict-file-names=nocontrol --directory-prefix=output --force-directories http://localhost:4567{} 2>log-parallel.txt
