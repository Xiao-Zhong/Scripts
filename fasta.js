'use strict';
//console.log(process.argv[2]);

const fs = require('fs');

const ifile = process.argv[2];
let iLineLength = Number(process.argv[3]);
let complementRerverse = process.argv[4];

iLineLength = (iLineLength) ? iLineLength : 80;
//iLineLength = Number(iLineLength);

//let head = fs.readFileSync(ifile).toString().split("\n")[0].split(">")[1].split(" ")[0];
//let seq = fs.readFileSync(ifile).toString().split("\n").slice(1).join('');

let lines = fs.readFileSync(ifile).toString().split(">");
//console.log(lines[1]);
//console.log(lines.length);

let seqObj = [];
let seqObjObject = {};
//let totalLength = 0;
for(let i=1; i<lines.length; i++){
  //console.log(lines[i]);
  let id = lines[i].split("\n")[0].split(/\s+/)[0];
  //console.log(id);
  let seqOriginal = lines[i].split("\n").slice(1).join('');
  let seq = seqOriginal.replace(/\s+/g, '').toUpperCase().replace(/[^A|T|C|G]/g, 'N');
  //console.log(id + "\t" + seq.length);
  //totalLength += seq.length;
  seqObj.push([id, seq, seq.length]);

  //seqObjObject[id] = seq.length;
  //seqObjObject[id] = seq.length;
  //seqObjObject = [{key: id, val: seq.length}];
}

seqObj.sort(function(a, b){
  return b[2] - a[2];
});
//console.log(seqObj);
//console.log(seqObj[2]);
//console.log(seqObj.length);

for(let i=0; i<seqObj.length; i++){
  //console.log(">" + seqObj[i][0] + "\t" + seqObj[i][1] + "\n" + seqObj[i][2]);

  process.stdout.write(fasta_print(seqObj[i][0], seqObj[i][1]));

  if (complementRerverse){
    let complementSequence = complement_seq(seqObj[i][1])
    process.stdout.write(fasta_print(seqObj[i][0] + '_complement', complementSequence));
  }
}

function complement_seq(seq){
  function complement(base){
    return {A : 'T', T: 'A', G: 'C', C: 'G' }[base];
  }

  let compSeq = seq.toUpperCase().split('').reverse().map(complement).join('');
  return compSeq;
}

function fasta_print(id, seq){
  let output = ">" + id + "\n";

  for (let i=0; i<seq.length; i +=iLineLength){
    output += seq.substr(i, iLineLength).toUpperCase() + "\n";
  }
  //console.log(output);
  return output;
}

//console.log(totalLength);
//console.log(head);
//console.log(seq.length);

//let ofile = "fasta_output.txt";
//let outPut = head + "\t" + seq.length + "\n";
//console.log(outPut);

//fs.writeFileSync(ofile, outPut);
