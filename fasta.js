//'use strict';
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

let seqLength = [];
let seqLengthObject = {};
//let totalLength = 0;
for(let i=1; i<lines.length; i++){
  //console.log(lines[i]);
  let id = lines[i].split("\n")[0].split(/\s+/)[0];
  //console.log(id);
  let seq = lines[i].split("\n").slice(1).join('');
  //console.log(id + "\t" + seq.length);
  //totalLength += seq.length;
  seqLength.push([id, seq, seq.length]);

  //seqLengthObject[id] = seq.length;
  //seqLengthObject[id] = seq.length;
  //seqLengthObject = [{key: id, val: seq.length}];
}

seqLength.sort(function(a, b){
  return b[2] - a[2];
});
//console.log(seqLength);
//console.log(seqLength[2]);
//console.log(seqLength.length);

for(let i=0; i<seqLength.length; i++){
  //console.log(">" + seqLength[i][0] + "\t" + seqLength[i][1] + "\n" + seqLength[i][2]);

  process.stdout.write(fasta_print(seqLength[i][0], seqLength[i][1]));

  if (complementRerverse){
    let complementSequence = complement_seq(seqLength[i][1])
    process.stdout.write(fasta_print(seqLength[i][0] + '_complement', complementSequence));
  }
}

function complement_seq(seq){
  function complement (base){
    return {A : 'T', T: 'A', G: 'C', C: 'G' }[base];
  }

  let compSeq = seq.toUpperCase().split('').reverse().map(complement).join('');
  return compSeq;
}


function fasta_print(id, seq, lineLen){
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
