const fs = require('fs');
const sh = require('shelljs');

const in_table =process.argv[2];

const lines= fs.readFileSync(in_table).toString().split('\n').slice(0, -1);

let rawContigPass = 0;
let rawAssemblyPass = 0;
let rawCirclePass = 0;
let correctedContigPass = 0;
let correctedAssemblyPass = 0;
let correctedCirclePass = 0;

let improved = 0;
let improvedLines = '';
let worsen = 0;
let worsenLines = '';

for (line of lines){
  //console.log(line);
  columns = line.split(/\t/);

  if (columns[1] === "NA" && columns[7] !=="NA"){
    //console.log(line);
    improved++;
    improvedLines += line + "\n";
  }
  if (columns[1] !== "NA" && columns[7] !=="NA" && Number.parseInt(columns[1]) > Number.parseInt(columns[7])){
    //console.log(line);
    improved++;
    improvedLines += line + "\n";
  }

  if (columns[1] !== "NA" && columns[7] ==="NA"){
    //console.log(line);
    worsen++;
    worsenLines += line + "\n";
  }
  if (columns[1] !== "NA" && columns[7] !=="NA" && Number.parseInt(columns[1]) < Number.parseInt(columns[7])){
    //console.log(line);
    worsen++;
    worsenLines += line + "\n";
  }

  if (columns[1] !== "NA"){
    rawContigPass++;
  }
  if (columns[3] !== "NA"){
    rawAssemblyPass++;
  }
  if (columns[5] !== "NA"){
    rawCirclePass++;
  }

  if (columns[7] !== "NA"){
    correctedContigPass++;
  }
  if (columns[9] !== "NA"){
    correctedAssemblyPass++;
  }
  if (columns[11] !== "NA"){
    correctedCirclePass++;
  }

}

// console.log(rawContigPass);
// console.log(rawAssemblyPass);
// console.log(rawCirclePass);
// console.log(correctedContigPass);
// console.log(correctedAssemblyPass);
// console.log(correctedCirclePass);

console.log("Assembly_using_raw_reads: #_of_contigs" + "\t" + rawContigPass + "\t" + "#_of_contigs_after_merged" +
"\t" + rawAssemblyPass + "\t" + "Circularized_assembly" + "\t" + rawCirclePass)
console.log("Assembly_using_corrected_reads: #_of_contigs" + "\t" + correctedContigPass + "\t" + "#_of_contigs_after_merged" +
"\t" + correctedAssemblyPass + "\t" + "Circularized_assembly" + "\t" + correctedCirclePass)

console.log("#_of_the_improved;" + "\t" + improved)
console.log("#_of_the_worsened;" + "\t" + worsen)

fs.writeFileSync("improved_lines.txt", improvedLines)
fs.writeFileSync("worsened_lines.txt", worsenLines)
