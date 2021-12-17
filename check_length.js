const fs = require('fs');

const in_new_assembly_table = process.argv[2];
const in_old_assembly_table = process.argv[3];

const oldLines = fs.readFileSync(in_old_assembly_table).toString().split('\n');
let oldAssemblySize = {};
for (let i=1; i<oldLines.length-1; i++){
  //console.log(oldLines[i]);
  let oldLength = oldLines[i].split(/\s+/);
  let id = oldLength[0].split(/\_/);
  //console.log(id[0] + "\t" + oldLength[1]);
  oldAssemblySize[id[0]] = oldLength[1];
}

const newLines = fs.readFileSync(in_new_assembly_table).toString().split('\n');
for (let i=0; i<newLines.length-1; i++){
  //console.log(newLines[i]);
  let newLength = newLines[i].split(/\s+/);
  //console.log(newLength[0] + "\t" + newLength[2]);
  if (Number(newLength[2])){
    //console.log(newLength[0] + "\t" + newLength[2] + "\t" + oldAssemblySize[newLength[0]]);
    let output =newLength[0] + "\t" + newLength[2] + "\t" + oldAssemblySize[newLength[0]];

    if(newLength[2] === oldAssemblySize[newLength[0]]){
      output +="\t" + "same";
    }else{
      output +="\t" + "diff";
    }
    
    console.log(output);
  }
}
