#import "SnapshotHelper.js"

var target = UIATarget.localTarget();
var app = target.frontMostApp();
var window = app.mainWindow();

target.delay(1);
captureLocalizedScreenshot("0-Question-List");

app.navigationBar().rightButton().tap();
captureLocalizedScreenshot("2-Question-Create");

app.navigationBar().leftButton().tap();
window.tableViews()[0].cells()[0].tap();
captureLocalizedScreenshot("1-Question-Detail");

