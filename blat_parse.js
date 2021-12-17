const fs = require('fs');

const inBlatPsl = process.argv[2];

let pslLines = fs.readFileSync(inBlatPsl).toString().split('\n');

let pslObj = {};
let pslArrays = [];
for(let pslLine of pslLines){
  if(pslLine.match(/^\d+/)){
    //console.log(pslLine);
    let fields = pslLine.split(/\s+/);
    //console.log(fields[9] + "\t" + fields[13]);
    let genes = fields[9].match(/\S+\_(\S+)\_\d+/);
    //console.log(genes[1]);
    //let [species,gene,start] = fields[9].split('_');
    //start = Number.parseInt(start);
    //start = (+start);

    //pslArrays.push([fields[13], genes[1], fields[0], fields[9]]);
    let groupKey = fields[13] + "_" + genes[1];
    if (pslObj[groupKey] === undefined){
      pslObj[groupKey] = [];
    }
    //block_count   blockSizes      qStarts  tStarts
    //2       37,48,  0,37,   46893,47442,
    //pslObj[groupKey].push([fields[0], fields[1], fields[18], fields[20]]);
    pslObj[groupKey].push(fields)
  }
}

for(let pair in pslObj){
  //console.log(pair + "\t" + pslObj[pair]);

  pslObj[pair].sort(function(a, b){return b[0] - a[0] || a[1] - b[1]});

  let output = pslObj[pair][0][13] + "\tBLAT\tgene\t" + (Number.parseInt(pslObj[pair][0][15])+1) + "\t" +
  pslObj[pair][0][16] + "\t\.\t" + pslObj[pair][0][8] + "\t.\tID=" + pair + "_" + pslObj[pair][0][15] + ";\n";
  //console.log(output);
  //console.log(pair + "\t" + pslObj[pair]);
  //console.log(pair + "\t" + pslObj[pair][0]);
  //console.log(pair + "\t" + pslObj[pair][0][18]);
  let blockSizes = pslObj[pair][0][18].split(/,/);
  //console.log(blockSizes);
  let blockStarts = pslObj[pair][0][20].split(/,/);
  for(let i=0; i<blockStarts.length-1; i++){
    //console.log("TEST" + "\t" + blockStarts[i]);
    let blockStart = Number.parseInt(blockStarts[i]) + 1;
    let blockStop = Number.parseInt(blockStarts[i]) + Number.parseInt(blockSizes[i]);
    output += pslObj[pair][0][13] + "\tBLAT\texon\t" + blockStart + "\t" + blockStop +
    "\t\.\t" + pslObj[pair][0][8] + "\t.\tParent=" + pair + "_" + pslObj[pair][0][15] + ";\n";
  }
  //console.log(output);
  process.stdout.write(output);
}

/*
//let table = pslLines.map(line => line.split("\t").map(field => field.trim()))
//table = table.slice(3);
//table = table.filter(fields => fields.length == 21);

//console.log(pslArrays);
for(let pslArray of pslArrays){
  //console.log(pslArray);
}

for (let row of pslArrays) {
  row[2] = +row[2];
}

let groups = {};

for (let row of pslArrays)
{
    let group = row[0] + row[1];

    if (groups[group] === undefined)
    {
        //groups[group] = [];
        groups[group] = row;
    }
    else if (row[2] > groups[group][2]) {
        groups[group] = row;
    }
    //groups[group].push(row);
}

for (let row of Object.values(groups))
{
  console.log(row);
}

// for (let values of Object.values(groups))
// {
//     let biggest = values.sort(
//         function (a,b) {
//             if (a == b) return 0;
//             return b - a;
//         }
//     )[0];
//
// }
*/
