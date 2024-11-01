var dialog = new Dialog("CHR");
dialog.addSeparator("Please choose the files you want to open to edit this level.");
var CHR = dialog.addFilePicker("Choose CHR:");
dialog.addNewRow();
var pal = dialog.addFilePicker("Choose palette (.pal):");
dialog.addNewRow();
var metatiles = dialog.addFilePicker("Choose metatiles.s file:");
dialog.addNewRow();

dialog.addButton("OK").clicked.connect(function(){
  var process = new Process();
  process.exec("for_tiled/studio-tiled-png.exe", [CHR.fileUrl, pal.fileUrl, metatiles.fileUrl]); 
  dialog.close();
});

dialog.show();