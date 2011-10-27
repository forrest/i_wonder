// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery-ui
//= require jquery_ujs
//= require_tree .



function nested_delete(raw_this){
   var row = $(raw_this).closest('.deletable_row');
   row.hide();
   row.find(".hidden_destroy").val("true");
}

//this is called when a new row is being inserted from a partial. 
//It will replace the "new_row_id" with the current timestamp.
function new_row_inserter(html){
  var timestamp = new Date().getTime();
  return html.replace(/new_row_id/g, timestamp)
}
