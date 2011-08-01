// This is a test harness for your module
// You should do something interesting in this harness 
// to test out the module and to provide instructions 
// to users on how to use it by example.


// open a single window
var window = Ti.UI.createWindow({
  backgroundColor:'white'
});

var titleBar = Ti.UI.createView({width:300,height:50,backgroundColor:'#000',top:20});
window.add(titleBar);

var title_lbl = Ti.UI.createLabel({text:'Card Information:',color:'#FFF',height:40,left:10});
titleBar.add(title_lbl);

var info_vw = Ti.UI.createView({width:300,height:300,top:72,borderRadius:2});
window.add(info_vw);

var name_lbl = Ti.UI.createLabel({text:'Name: ',height:35,top:5});
info_vw.add(name_lbl);

var card_lbl = Ti.UI.createLabel({text:'#: ',height:35,top:45});
info_vw.add(card_lbl);

var exp_lbl = Ti.UI.createLabel({text:'Exp: ',height:35,top:85});
info_vw.add(exp_lbl);

var status_lbl = Ti.UI.createLabel({text:"Status: "});
window.add(status_lbl);

// TODO: write your module tests here
var magtek = require('ti.magtek');
//alert("module is => "+magtek);
 magtek.registerDevice('com.appcelerator.magtek');

magtek.addEventListener('connected', function(e) {
   status_lbl.text = 'Status: Connected';
});
magtek.addEventListener('disconnected', function(e) {
	name_lbl.text = 'Name: ';
	card_lbl.text = '#: ';
	exp_lbl.text = 'Exp: ';
	status_lbl.text = 'Status: Disconnected';
});
magtek.addEventListener('swipe', function(e) {
	name_lbl.text = 'Name: ' + e.name;
	card_lbl.text = '#: ' + e.cardnumber;
	exp_lbl.text = 'Exp: ' + e.expiration;
	status_lbl.text = "Status: GOOD SWIPE";
});

magtek.addEventListener('swipeError',function(e){
	status_lbl.text = "Status: ERROR";
	name_lbl.text = 'Name: ';
	card_lbl.text = '#: ';
	exp_lbl.text = 'Exp: ';
});

Titanium.App.addEventListener('resume',function(e)
{
	alert('RESUMED');
	magtek.resumeConnection();
});

window.open();