#!/usr/bin/env awk
BEGIN { FS="%%%"; } 
{ 
  fp="features/"$1".geojson";
  split(fp,a,"/");
  i=3;
  dir="mkdir -p "a[1];
  print(dir);
  while (a[i] != "") { 
    dir=dir"/"a[i-1];
    # print(dir);
    i+=1;
  }; 
  if (dir != "features") {
    # print(dir);
    system(dir);
  };
  system("touch "fp);
  print("writing "fp);
  print $2 > fp;
}