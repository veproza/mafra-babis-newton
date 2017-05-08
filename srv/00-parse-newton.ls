require! {
  "csv-parse": csv
  fs
  async
}
dir = "#__dirname/../data/zdroje"
files = fs.readdirSync dir
# files.length = 1
outFile = fs.createWriteStream "#__dirname/../data/clanky.tsv"
outFile.write "kauza\tdatum\tmedium\ttitulek\tstrana\trubrika\tautor\tdelka"
<~ async.eachSeries files, (file, cb) ->
  reader = csv!
  stream = fs.createReadStream "#dir/#file"
  kauza = file.split "." .0
  stream.pipe reader
  reader.on \data (record) ->
    return if record.0 == "KOD_TEM,C,4"
    [_, _, medium, date, titulek, strana, rubrika, autor, _, obsah] = record
    console.log record, file if not obsah
    outFile.write "\n" + ([kauza, date, medium, titulek, strana, rubrika, autor, obsah.length].join "\t")
  reader.on \end cb
console.log \done
