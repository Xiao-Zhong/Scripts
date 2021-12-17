const fs = require('fs');

const inputGene = process.argv[2];
const inputTable = process.argv[3];

let Genes = fs.readFileSync(inputGene).toString().split("\n");
let Lines = fs.readFileSync(inputTable).toString().split("\n");

for(let i=0; i<Genes.length; i++){
    //console.log(Genes[i]);
    let regExp2 = /^(\S+\.\d+)/;
    let geneOnly = regExp2.exec(Genes[i]);

    
    if(geneOnly){
       //console.log(geneOnly);
       //console.log(geneOnly[1]);   
       
       for (let j=0; j<Lines.length; j++){
           //console.log(Lines[j]);
           let regExp = /AT2G27530\.1/;
           let matchedGeneLine = regExp.exec(Lines[j]);
           //console.log(matchedGeneLine);

            if(matchedGeneLine){
                //console.log(matchedGeneLine);
                console.log(geneOnly[0] + "\tfound_in\t" + Lines[j])
            }
        }
        
    }
}