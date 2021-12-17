const fs = require('fs');
const sh = require('shelljs');

const indir = process.argv[2];

let infiles = sh.ls(indir + '/*.vmatch.txt');
//let ifiles = glob("idir/*.vmatch.txt");
for(let infile of infiles){
  //console.log(infile);
  let id = infile.match(/\.\/(\S+)_Cp*\.fa/);
  let output = id[1] + "\t";

  vmatchLines = fs.readFileSync(infile).toString().split('\n');

  let IRarray = [];
  let repeatsLoci = [];
  let repeatlLenMax = 0;
  for(let i=1; i<vmatchLines.length-1; i++){
    //console.log(vmatchLines[i]);
    //let fields = vmatchLines[i].split(/\s+/);
    let fields = vmatchLines[i].match(/(\d+)\s+\d+\s+(\d+)\s+(D|P)/);
    // do not recoginize "IR" as repeats;
    if (fields[3] === "P" && fields[1] > 10000){
      IRarray.push(fields[1]);
      //continue;
    }else{
      //console.log(fields[1] + "\t" + fields[2] + "\t" + fields[3]);
      let blockEnd = parseInt(fields[2]) + parseInt(fields[1]) - 1;
      repeatsLoci.push([parseInt(fields[2]), blockEnd, parseInt(fields[1])]);

      if(parseInt(fields[1]) > repeatlLenMax){
        repeatlLenMax = parseInt(fields[1]);
      }
    }
  }

  if (IRarray && IRarray.length > 0){
    for(let IRlength of IRarray){
      //console.log (IRlength);
      output +=IRlength + ",";
    }
    output = output.slice(0, -1);
  }else{
    output +="NA";
  }

  output +="\t" + repeatlLenMax;

  // it is necessary action before clustering and identifying overlaps;
  repeatsLoci.sort(function(a, b){ return a[0] - b[0]});

  let lenLongerThan100 = 0, lenLongerThan150 = 0, lenLongerThan200 = 0;
  let totalLength = repeatsLoci[0][1] - repeatsLoci[0][0];
  for(let i=0; i<repeatsLoci.length; i++){
    if (i<repeatsLoci.length-1){
      //console.log(repeatsLoci[i]);

      // the 2nd start point is located in internal region of the 1st block
      if (repeatsLoci[i+1][0] >= repeatsLoci[i][0] && repeatsLoci[i+1][0] <= repeatsLoci[i][1]){
        // the entire 2nd region is located.
        if (repeatsLoci[i+1][1] <= repeatsLoci[i][1]){
          //totalLength += repeatsLoci[i][1] - repeatsLoci[i][0];
        }else{
          totalLength += repeatsLoci[i+1][1] - repeatsLoci[i][1];
        }
        // the 2nd start point is located downstream.
      }else{
        totalLength += repeatsLoci[i+1][1] - repeatsLoci[i+1][0] + 1;
      }
      //console.log(repeatsLoci[i] + "\t" + totalLength);
    }

    //console.log(repeatsLoci[i][2])
    if (repeatsLoci[i][2] > 100) lenLongerThan100++;
    if (repeatsLoci[i][2] > 150) lenLongerThan150++;
    if (repeatsLoci[i][2] > 200) lenLongerThan200++;
  }
  //console.log(totalLength);
  //console.log(repeatsLoci.length);
  //console.log("longer\t" + lenLongerThan100);
  output += "\t" + (totalLength/repeatsLoci.length).toFixed(2) + "\t" + repeatsLoci.length + "\t" + totalLength+
  "\t" + lenLongerThan100 + "\t" + lenLongerThan150 + "\t" + lenLongerThan200;
  console.log(output);
}
