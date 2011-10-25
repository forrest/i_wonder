// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.


$(function(){
  $("#metric_collection_type").change(function(){
    $(".details_for_option").appendTo($("#unused_form_elements"));
    
    $("."+$(this).val()+"_details").appendTo($("#active_options_holder"));
  });
  
  $("#metric_takes_snapshots").change(function(){
    if($(this).prop('checked')){
      $(".snapshot_details").show();
    }else{
      $(".snapshot_details").hide();
    }
  });
})
