const fs = require('fs');
const sh = require('shelljs');

const in_all_id =process.argv[2];
const in_raw_reads_assembly_dir = process.argv[3];
const in_corrected_reads_assembly_dir = process.argv[4];

const ids = fs.readFileSync(in_all_id).toString().split('\n').slice(0, -1);
for (id of ids ){
  //console.log(id);
  let raw_reads_contigs_file = sh.ls(in_raw_reads_assembly_dir + "/" + "Contigs_1_" + id + "_chloro.fasta");
  //console.log(raw_reads_contigs_file);
  let raw_reads_assembly_file = sh.ls(in_raw_reads_assembly_dir + "/" + "Option_1_" + id + "_chloro.fasta");
  let raw_reads_Circularized_file = sh.ls(in_raw_reads_assembly_dir + "/" + "Circularized_assembly_1_" + id + "_chloro.fasta");

  let corrected_reads_contigs_file = sh.ls(in_corrected_reads_assembly_dir + "/" + "Contigs_1_" + id + "_chloro.fasta");
  let corrected_reads_assembly_file = sh.ls(in_corrected_reads_assembly_dir + "/" + "Option_1_" + id + "_chloro.fasta");
  let corrected_reads_Circularized_file = sh.ls(in_corrected_reads_assembly_dir + "/" + "Circularized_assembly_1_" + id + "_chloro.fasta");

  //console.log(id + "\t" + raw_reads_contigs_file[0]);

  let output = id;
  if (raw_reads_contigs_file[0]){
    //console.log(id + "\t" + read_fasta(raw_reads_contigs_file[0]));
    let seqLensArray = read_fasta(raw_reads_contigs_file[0]);

    if (seqLensArray.length > 0){
      output += "\t" + seqLensArray.length + "\t" + seqLensArray.join(',');
    }else{
      output += "\t" + "NA" + "\t" + "NA";
    }
    //console.log(seqid_length[0] + seqid_length[1]);
  }else{
    output += "\t" + "NA" + "\t" + "NA";
  }

  if (raw_reads_assembly_file[0]){
    //console.log(id + "\t" + read_fasta(raw_reads_contigs_file[0]));
    let seqLensArray = read_fasta(raw_reads_assembly_file[0]);

    if (seqLensArray.length > 0){
      output += "\t" + seqLensArray.length + "\t" + seqLensArray.join(',');
    }else{
      output += "\t" + "NA" + "\t" + "NA";
    }
    //console.log(seqid_length[0] + seqid_length[1]);
  }else{
  output += "\t" + "NA" + "\t" + "NA";
  }

  if (raw_reads_Circularized_file[0]){
    //console.log(id + "\t" + read_fasta(raw_reads_contigs_file[0]));
    let seqLensArray = read_fasta(raw_reads_Circularized_file[0]);

    if (seqLensArray.length > 0){
      output += "\t" + seqLensArray.length + "\t" + seqLensArray.join(',');
    }else{
      output += "\t" + "NA" + "\t" + "NA";
    }
    //console.log(seqid_length[0] + seqid_length[1]);
  }else{
    output += "\t" + "NA" + "\t" + "NA";
  }


  if (corrected_reads_contigs_file[0]){
    //console.log(id + "\t" + read_fasta(raw_reads_contigs_file[0]));
    let seqLensArray = read_fasta(corrected_reads_contigs_file[0]);

    if (seqLensArray.length > 0){
      output += "\t" + seqLensArray.length + "\t" + seqLensArray.join(',');
    }else{
      output += "\t" + "NA" + "\t" + "NA";
    }
    //console.log(seqid_length[0] + seqid_length[1]);
  }else{
    output += "\t" + "NA" + "\t" + "NA";
  }

  if (corrected_reads_assembly_file[0]){
    //console.log(id + "\t" + read_fasta(raw_reads_contigs_file[0]));
    let seqLensArray = read_fasta(corrected_reads_assembly_file[0]);

    if (seqLensArray.length > 0){
      output += "\t" + seqLensArray.length + "\t" + seqLensArray.join(',');
    }else{
      output += "\t" + "NA" + "\t" + "NA";
    }
    //console.log(seqid_length[0] + seqid_length[1]);
  }else{
    output += "\t" + "NA" + "\t" + "NA";
  }

  if (corrected_reads_Circularized_file[0]){
    //console.log(id + "\t" + read_fasta(raw_reads_contigs_file[0]));
    let seqLensArray = read_fasta(corrected_reads_Circularized_file[0]);

    if (seqLensArray.length > 0){
      output += "\t" + seqLensArray.length + "\t" + seqLensArray.join(',');
    }else{
      output += "\t" + "NA" + "\t" + "NA";
    }
    //console.log(seqid_length[0] + seqid_length[1]);
  }else{
    output += "\t" + "NA" + "\t" + "NA";
  }

  console.log(output);
}



function read_fasta(inFastaFile){
  let faLines = fs.readFileSync(inFastaFile).toString().split(">");

  let seqLens = [];
  for(let i=1; i<faLines.length; i++){
    //console.log(lines[i]);
    let id = faLines[i].split("\n")[0].split(/\s+/)[0];
    //console.log(id);
    let seq = faLines[i].split("\n").slice(1).join('');
    //console.log(id + "\t" + seq.length);
    //totalLength += seq.length;

    seqLens.push(seq.length);
    //seqDict[id] = seq.length;
  }
  return seqLens;
}
