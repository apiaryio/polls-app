#import "SnapshotHelper.js"

var target = UIATarget.localTarget();
var app = target.frontMostApp();
var window = app.mainWindow();

target.delay(1);
captureLocalizedScreenshot("0-Question-List");

app.navigationBar().rightButton().tap();

target.frontMostApp().mainWindow().tableViews()[0].cells()[0].textFields()[0].textFields()[0].tap();
app.keyboard().typeString("What's your favourite fruit?");
target.frontMostApp().mainWindow().tableViews()[0].cells()[1].textFields()[0].textFields()[0].tap();
app.keyboard().typeString("Apples");
target.frontMostApp().mainWindow().tableViews()[0].cells()[2].tap();
target.frontMostApp().mainWindow().tableViews()[0].cells()[2].textFields()[0].textFields()[0].tap();
app.keyboard().typeString("Strawberries");

captureLocalizedScreenshot("2-Question-Create");


app.navigationBar().leftButton().tap();
target.delay(1);
window.tableViews()[0].cells()[0].tap();
captureLocalizedScreenshot("1-Question-Detail");


