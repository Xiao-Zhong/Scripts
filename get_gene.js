const fs = require('fs');

const inFasta = process.argv[2];
const inGff = process.argv[3];
let lineLen = process.argv[4];


let lines = fs.readFileSync(inGff).toString().split("\n");

let exonLoci = {};
for(let i=0; i<lines.length; i++){
  //console.log(lines[i]);
  let column = lines[i].toString().split(/\s+/);
  //console.log(column[2] + "\t" + column[8]);
  if(column[2] === 'exon'){
    //console.log(column[2] + "\t" + column[8]);
    let description = column[8].match(/Parent=(\S+?);/);
    //let description = column[8].match(/Parent=(\S+?);/);
    //console.log(description[1] +  "\t" + column[3] + "\t" + column[4]);

    let id = column[0] + "_" + description[1];
    //console.log(id);
    if (exonLoci[id] === undefined){
      exonLoci[id] = [];
    }
    exonLoci[id].push(column);
  }
}

let seqDict = {};
//console.log(read_fasta(inFasta));
read_fasta(inFasta);

for (let gid in exonLoci){
  //console.log(gid);
  console.log(exonLoci[gid]);
  //console.log(geneLoci[gid][0][3]);
  //console.log(geneLoci[gid][0][4]);
  //console.log(geneLoci[gid][0][6]);
  //console.log(seqDict[geneLoci[gid][0]]);

  let genomeSeq = seqDict[exonLoci[gid][0][0]];
  let exonStrand = exonLoci[gid][0][6];

  exonLoci[gid].sort(function(a, b){ 
    return a[3] - b[3];
  })
  //console.log(exonLoci[gid]);

  let exonSeq = '';
  for (let i=0; i<exonLoci[gid].length; i++){
    let exonStart = exonLoci[gid][i][3];
    let exonStop = exonLoci[gid][i][4];
    //let exonStrand = exonLoci[gid][i][6];
    //let exonLen = exonStop - exonStart + 1;
    //console.log(exonLen);
    
    //exonSeq += genomeSeq.substr(exonStart-1, exonLen);
    exonSeq += genomeSeq.substr(exonStart-1, exonStop - exonStart + 1);
  }
  //console.log(">" + gid + "\n" + exonSeq);

  let finalOutput = ">" + gid + "\n"; 
  if(exonStrand === '-'){
    finalOutput += fasta_print(complement_seq(exonSeq));
  }else{
    finalOutput += fasta_print(exonSeq);
  }
  process.stdout.write(finalOutput);

  //let geneStart = geneLoci[gid][3];
  //let geneStop = geneLoci[gid][4];
  //let geneStrand = geneLoci[gid][6];

  //let genelen = geneStop - geneStart + 1;
  //let genomeSeq = seqDict[geneLoci[gid][0]];

  //let geneSeq = genomeSeq.substr(geneStart-1, genelen);
  //process.stdout.write("\>" + gid + "\t" + geneStart + "_" + geneStop + "_" +
  //geneStrand + "\tlength_" + genelen + "\n");
  //console.log(geneSeq);
  //if (geneStrand === '-'){
    //process.stdout.write(fasta_print(complement_seq(geneSeq)));
  //}else{
    //process.stdout.write(fasta_print(geneSeq));
  //}
}

// Functions arranged below
function complement_seq(seq){
  function complement (base){
    return {A : 'T', T: 'A', G: 'C', C: 'G' }[base];
  }

  let compSeq = seq.toUpperCase().split('').reverse().map(complement).join('');
  return compSeq;
}

function fasta_print(seq){
  lineLen = (lineLen) ? lineLen : 80;

  let output = '';
  for (let i=0; i<seq.length; i +=lineLen){
    output += seq.substr(i, lineLen).toUpperCase() + "\n";
  }
  //console.log(output);
  return output;
}

function read_fasta(inFastaFile){
  let faLines = fs.readFileSync(inFastaFile).toString().split(">");

  for(let i=1; i<faLines.length; i++){
    //console.log(lines[i]);
    let id = faLines[i].split("\n")[0].split(/\s+/)[0];
    //console.log(id);
    let seq = faLines[i].split("\n").slice(1).join('');
    //console.log(id + "\t" + seq.length);
    //totalLength += seq.length;

    //seqText.push([id, seq, seq.length]);
    seqDict[id] = seq;
  }
  //console.log(seqText);
  return seqDict;
}
//console.log(read_fasta(inFasta));
