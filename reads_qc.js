const fs = require('fs');
const sh = require('shelljs');

const in_all_id =process.argv[2];
const in_reads_stat = process.argv[3];
const in_assembly_stat = process.argv[4];

const statLines = fs.readFileSync(in_assembly_stat).toString().split('\n');
let readsMapped = {};
for(let i=0; i<statLines.length-1; i++){
  //console.log(statLines[i]);
  let fields = statLines[i].split(/\s+/);
  //console.log(fields[0] + "\t" + fields[3]);
  readsMapped[fields[0]] = fields[3];
}

const readsLines = fs.readFileSync(in_reads_stat).toString().split('\n');
let readsCount = {};
for(let i=0; i<readsLines.length-1; i++){
  //console.log(readsLines[i]);
  let fields = readsLines[i].split(/\s+/);
  //console.log(fields[0]);
  fields[1]=fields[1].split(',').join('');
  //console.log(fields[2]);
  if(fields[2]){
    //console.log(fields[2]);
    fields[2]=fields[2].split(',').join('');
    readsCount[fields[0]] = [fields[1] + "\t" + fields[2]];
  }
}

const idLines = fs.readFileSync(in_all_id).toString().split('\n');
//let idArrays = [];
for(let i=0; i<idLines.length-1; i++){
  let id = idLines[i].match(/(\S+)/);
  //console.log(id[1] + "\t" + readsCount[id[1]] + "\t" + readsMapped[id[1]]);
  let output = '';
  output += id[1] + "\t" + readsCount[id[1]];

  let correctFile = "03_correct/" + id[1] + "_spades.log";
  const correctAllOutput = fs.readFileSync(correctFile).toString();
  let changedBases = correctAllOutput.match(/Changed (\d+) bases in \d+ reads\./);
  //console.log(changedBases[1]);
  output += "\t" + changedBases[1];

  let qcBeforeCorrectedR1 = sh.ls("04_qc/" + id[1] + "*_R1_fastqc/fastqc_data.txt");
  //console.log(qcBeforeCorrectedR1[0]);
  let qcBeforeCorrectedR2 = sh.ls("04_qc/" + id[1] + "*_R2_fastqc/fastqc_data.txt");
  let qcAfterCorrectedR1 = sh.ls("04_qc/" + id[1] + "*_R1.fastq.*_fastqc/fastqc_data.txt");
  let qcAfterCorrectedR2 = sh.ls("04_qc/" + id[1] + "*_R2.fastq.*_fastqc/fastqc_data.txt");

  let qualityBeforeCorrected = quality_calculation(qcBeforeCorrectedR1[0], qcBeforeCorrectedR2[0]);
  //console.log(qualityBeforeCorrected);
  let qualityAfterCorrected = quality_calculation(qcAfterCorrectedR1[0], qcAfterCorrectedR2[0]);
  output += "\t" + qualityBeforeCorrected + "\t" + qualityAfterCorrected;

  output += "\t" + readsMapped[id[1]];
  console.log(output);
}

function quality_calculation(qcOutputR1File, qcOutputR2File){
  let qualityCountR1 = read_quality(qcOutputR1File);
  //console.log(qualityCountR1[0] + "\t" + qualityCountR1[1]);
  let qualityCountR2 = read_quality(qcOutputR2File);

  let averageQuality = (qualityCountR1[0] + qualityCountR2[0]) / (qualityCountR1[1] + qualityCountR2[1]);
  //console.log(averageQuality.toFixed(4));
  return(averageQuality.toFixed(4));
}

function read_quality(qcOutputFile){
  const qcAllOutput = fs.readFileSync(qcOutputFile).toString();
  //console.log(qcAllOutput);
  let readQC = qcAllOutput.match(/#Quality.+Count([\s\S]*?)>>END_MODULE/);
  //console.log(readQC[1]);

  let qcLines = readQC[1].split('\n');
  let totalScore = 0, totalCount = 0;
  for(let i=0; i<qcLines.length; i++){
    if(qcLines[i].match(/^\d+/)){
      //console.log(qcLines[i]);
      let qualityCount = qcLines[i].split(/\t/);
      qualityCount[0] = Number.parseInt(qualityCount[0]);
      qualityCount[1] = Number.parseFloat(qualityCount[1]);
      //console.log(qualityCount[0]);
      //console.log(qualityCount[1]);
      totalScore += qualityCount[0] * qualityCount[1];
      totalCount += qualityCount[1];
    }
  }
  //console.log (totalScore + "\t" + totalCount + "\t" + qcOutputFile);
  return [totalScore, totalCount];
}
