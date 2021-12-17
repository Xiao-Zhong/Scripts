const fs = require('fs');

const inFasta = 'Nicotiana_tabacum_NC_001879.2.fa';

let head = fs.readFileSync(inFasta).toString().split("\n")[0].split(">")[1].split(" ")[0];
let seq = fs.readFileSync(inFasta).toString().split("\n")[1];

//console.log(head);
//console.log(seq);

let outPut = head + "\t" + seq + "\n";

fs.writeFile('fasta_output.txt', outPut);






