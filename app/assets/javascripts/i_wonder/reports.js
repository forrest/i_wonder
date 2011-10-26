// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
//= require highcharts
//= require_self


$(function(){
  $("#chart_holder .calendar").datepicker({ dateFormat: 'yy/mm/dd' });
  $("#ui-datepicker-div").hide(); // this shouldn't be needed, but there seems to be a bug
  
  $("#chart_holder #chart_options input").change(function(){
    $(this).closest("form").submit();
  });
});