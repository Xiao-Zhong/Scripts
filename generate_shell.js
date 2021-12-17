const fs = require('fs');

const inputShell = process.argv[2];
const speciesList = process.argv[3];

let lines = fs.readFileSync(inputShell).toString().split("\n");
//console.log(lines.length);

let paramsList = [];
for(let i=0; i<lines.length-1; i++){
  //console.log(lines[i]);

  //let text2 = text.match(/d(!)$/);
  let regExp = /output\/ (.+) >/;
  let params = regExp.exec(lines[i]);
  //console.log(params[1]);

  //let params = lines[i].replace(regExp, '$1');
  //console.log(params);

  paramsList.push(params[1]);
  //let singleParams = params[1].split("\s+");
  //console.log(singleParams);
}
//console.log(paramsList);


let species = fs.readFileSync(speciesList).toString().split("\n");
//console.log(species);
for(let i=0; i<species.length-1; i++){
  //console.log("node push_pull_1by1.js features_" + species[i] + "/ genomes/ target/ output/");

  let output = '';
  for(let j=0; j<paramsList.length; j++){
    //console.log(paramsList[j]);
    let newParams = paramsList[j].split(" ").join("_");
    //console.log(newParams);
    output += "node push_pull_1by1.js features_" + species[i] +
    "/ genomes/ target/ output_" + species[i] + "/ " + paramsList[j] +
    " >align_" + newParams + ".log 2>align_" + newParams + ".err\n";
  }

  let ofile = species[i] + "_shells.txt";
  fs.writeFileSync(ofile, output);
}
