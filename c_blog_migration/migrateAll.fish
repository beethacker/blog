#!/usr/bin/fish

for entryPath in (find entries -type f)
  set newPath (string replace entries output $entryPath)
  set newDir (dirname $newPath)
  mkdir -p $newDir
  ./migrate.rb $entryPath > $newPath 
end
cp -r output/* ../content/posts


