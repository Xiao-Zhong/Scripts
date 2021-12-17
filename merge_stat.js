const fs = require('fs');

const ifile = process.argv[2];

let ids = fs.readFileSync(ifile).toString().split("\n").slice(0, -1);

let output = '';
for (id of ids){
  //console.log(id + "_report.txt")
  output += id
  let lines = fs.readFileSync(id + "_report.txt").toString().split("\n").slice(0, -1);

  let ratesObj = [];
  for (line of lines){
    //console.log(line);
    //console.log("test")
    let columns = line.split(/\s+/);
    columns[6] = columns.slice(6).join('_');
    //console.log(columns[1] + " " + columns[6]);

    ratesObj[columns[6]] = columns[1];

    // if (columns[6] === 'unclassified'){
    //   //output += "\t" + columns[1];
    //   ratesObj[columns[6]] = columns[1];
    // }else if(columns[6] === 'root'){
    //   //output += "\t" + columns[1];
    //   ratesObj[columns[6]] = columns[1];
    // }else if(columns[6] === 'Viruses'){
    //   //output += "\t" + columns[1];
    //   ratesObj[columns[6]] = columns[1];
    // }else if(columns[6] === 'Bacteria'){
    //   //output += "\t" + columns[1];
    //   ratesObj[columns[6]] = columns[1];
    // }else if(columns[6] === 'Archaea'){
    //   //output += "\t" + columns[1];
    //   ratesObj[columns[6]] = columns[1];
    // }else if(columns[6] === 'Fungi'){
    //   //output += "\t" + columns[1];
    //   ratesObj[columns[6]] = columns[1];
    // }else if(columns[6] === 'Homo_sapiens'){
    //   //output += "\t" + columns[1];
    //   ratesObj[columns[6]] = columns[1];
    // }
  }

  output += "\t" + ratesObj['unclassified'] + "\t" + ratesObj['root'] + "\t" + ratesObj['Viruses'] +
  "\t" + ratesObj['Bacteria'] + "\t" + ratesObj['Archaea'] + "\t" + ratesObj['Fungi'] + "\t" +
  ratesObj['Homo_sapiens'] + "\n";
}

process.stdout.write(output);
