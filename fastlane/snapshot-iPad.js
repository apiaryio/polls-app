#import "SnapshotHelper.js"

var target = UIATarget.localTarget();
var app = target.frontMostApp();
var window = app.mainWindow();

target.delay(1);

window.tableViews()[0].cells()[2].tap();
captureLocalizedScreenshot("0-Question-List");

app.navigationBar().rightButton().tap();
window.tableViews()[2].cells()[0].textFields()[0].textFields()[0].tap();
app.keyboard().typeString("What's your favourite fruit?");
window.tableViews()[2].cells()[1].textFields()[0].textFields()[0].tap();
app.keyboard().typeString("Apples");
window.tableViews()[2].cells()[2].tap();
window.tableViews()[2].cells()[2].textFields()[0].textFields()[0].tap();
app.keyboard().typeString("Strawberries");

captureLocalizedScreenshot("1-Question-Create");

